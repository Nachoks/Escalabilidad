<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\HojaTiempoSemana;
use App\Models\HojaTiempoDiaria;
use App\Models\Servicio;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class HojaTiempoController extends Controller
{
    /**
     * Crear una nueva Semana con sus 7 días en blanco.
     */
    public function crearSemana(Request $request)
    {
        // 1. Validar que la App nos envíe los datos mínimos requeridos
        $request->validate([
            'id_usuario' => 'required|exists:usuarios,id_usuario', // Verifica que el usuario exista
            'id_servicio' => 'required|exists:servicio,id_servicio', // Verifica que el servicio exista
            'id_oc_cliente' => 'required|exists:oc_cliente,id_oc_cliente', // Verifica que la OC exista
            'fecha' => 'required|date', // Una fecha cualquiera de la semana (ej: 2026-02-12)
        ]);

        try {
            // Iniciamos una transacción: Si algo falla, no se guarda nada a medias.
            DB::beginTransaction();

            // 2. MAGIA DE FECHAS (Usando Carbon)
            $fechaSeleccionada = Carbon::parse($request->fecha);
            
            // Forzamos a buscar el Lunes y el Domingo de esa fecha
            $lunes = $fechaSeleccionada->copy()->startOfWeek(Carbon::MONDAY);
            $domingo = $fechaSeleccionada->copy()->endOfWeek(Carbon::SUNDAY);
            
            // Calculamos el número de semana ISO (Ej: 7)
            $numeroSemana = $lunes->isoWeek();

            // 3. REGLA DE NEGOCIO: Evitar duplicados
            // Verificamos si este usuario ya tiene una hoja creada para este mismo Lunes
            $existe = HojaTiempoSemana::where('id_usuario', $request->id_usuario)
                ->where('fecha_inicio', $lunes->format('Y-m-d'))
                ->first();

            if ($existe) {
                return response()->json([
                    'success' => false,
                    'message' => 'El usuario ya tiene una hoja de tiempo creada para esta semana.',
                    'data' => $existe
                ], 400);
            }

            // 4. RESCATAR EL CENTRO DE COSTO DEL SERVICIO
            $servicio = Servicio::findOrFail($request->id_servicio);
            // IMPORTANTE: Si en tu tabla 'servicio' la columna se llama diferente (ej: 'correlativo'), cámbialo aquí abajo.
            $centroCosto = $servicio->centro_costo ?? 'S/N'; 

            // 5. CREAR LA SEMANA (El Encabezado)
            $semana = HojaTiempoSemana::create([
                'id_usuario' => $request->id_usuario,
                'id_servicio' => $request->id_servicio,
                'id_oc_cliente' => $request->id_oc_cliente,
                'centro_costo' => $centroCosto,
                'numero_semana' => $numeroSemana,
                'fecha_inicio' => $lunes->format('Y-m-d'),
                'fecha_fin' => $domingo->format('Y-m-d'),
                'estado' => 'Borrador'
            ]);

            // 6. CREAR LOS 7 DÍAS EN BLANCO (Lunes a Domingo)
            $diasInsertar = [];
            for ($i = 0; $i < 7; $i++) {
                $fechaDia = $lunes->copy()->addDays($i); // Suma días al Lunes: 0=Lun, 1=Mar... 6=Dom
                
                $diasInsertar[] = [
                    'id_hoja_semana' => $semana->id_hoja_semana,
                    'fecha' => $fechaDia->format('Y-m-d'),
                    'lugar' => 'DESCANSO',   // Por defecto
                    'tipo_dia' => 'NO_HABIL', // Por defecto
                    'viaje_horas' => 0,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
            
            // Insertamos los 7 días de un solo golpe para mayor velocidad
            HojaTiempoDiaria::insert($diasInsertar);

            // Confirmamos que todo salió bien y guardamos en la base de datos
            DB::commit();

            // Cargamos los días recién creados para devolverlos en la respuesta a la App
            $semana->load('dias');

            return response()->json([
                'success' => true,
                'message' => 'Semana creada exitosamente',
                'data' => $semana
            ], 201);

        } catch (\Exception $e) {
            // Si hubo un error (ej. se cayó la base de datos), deshacemos todo
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Error al crear la hoja de tiempo.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Obtener el listado de hojas de tiempo de un usuario específico
     */
    public function misHojas(Request $request)
    {
        $request->validate([
            'id_usuario' => 'required|exists:usuarios,id_usuario'
        ]);

        // Buscamos las hojas y traemos también los datos del servicio y la OC
        $hojas = HojaTiempoSemana::with(['servicio', 'ocCliente'])
            ->where('id_usuario', $request->id_usuario)
            ->orderBy('fecha_inicio', 'desc') // Las más nuevas primero
            ->get();

        return response()->json([
            'success' => true,
            'data' => $hojas
        ]);
    }

    /**
     * Obtener el detalle completo de una semana (Días y Actividades)
     */
    public function detalleHoja($id_hoja_semana)
    {
        // Traemos la hoja con toda su descendencia: Días y, dentro de los días, las Actividades
        $hoja = HojaTiempoSemana::with(['servicio', 'ocCliente', 'dias.actividades'])
            ->where('id_hoja_semana', $id_hoja_semana)
            ->first();

        if (!$hoja) {
            return response()->json([
                'success' => false,
                'message' => 'Hoja de tiempo no encontrada'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $hoja
        ]);
    }

    /**
     * Guardar la información de un día específico (Configuración + Actividades)
     */
    public function guardarDia(Request $request, $id_hoja_diaria)
    {
        // 1. Validamos que la App envíe la estructura correcta
        $request->validate([
            'lugar' => 'required|in:OFICINA,TERRENO,DESCANSO',
            'tipo_dia' => 'required|in:HABIL,NO_HABIL,FERIADO',
            'viaje_horas' => 'nullable|numeric|min:0',
            'horario_inicio' => 'nullable|date_format:H:i',
            'horario_fin' => 'nullable|date_format:H:i',
            
            // Las actividades son un arreglo (lista) de tramos trabajados
            'actividades' => 'nullable|array',
            'actividades.*.hora_inicio' => 'required|date_format:H:i',
            'actividades.*.hora_fin' => 'required|date_format:H:i',
            'actividades.*.descripcion' => 'required|string',
            
            // Horas calculadas desde la App (opcional, por defecto 0)
            'actividades.*.horas_habiles' => 'nullable|numeric',
            'actividades.*.horas_no_habiles' => 'nullable|numeric',
            'actividades.*.horas_festivas' => 'nullable|numeric',
        ]);

        try {
            DB::beginTransaction();

            // 2. Buscamos el día que queremos editar
            $dia = HojaTiempoDiaria::findOrFail($id_hoja_diaria);

            // 3. Actualizamos la configuración general del día
            $dia->update([
                'lugar' => $request->lugar,
                'tipo_dia' => $request->tipo_dia,
                'horario_inicio' => $request->horario_inicio,
                'horario_fin' => $request->horario_fin,
                'viaje_horas' => $request->viaje_horas ?? 0,
            ]);

            // 4. LÓGICA DE REEMPLAZO: Para evitar duplicados si el técnico edita el día,
            // primero borramos las actividades viejas de este día y luego insertamos las nuevas.
            $dia->actividades()->delete();

            // 5. Insertamos las nuevas actividades (si es que envió alguna)
            if ($request->has('actividades') && count($request->actividades) > 0) {
                $actividadesNuevas = [];
                foreach ($request->actividades as $act) {
                    $actividadesNuevas[] = [
                        'id_hoja_diaria' => $dia->id_hoja_diaria,
                        'hora_inicio' => $act['hora_inicio'],
                        'hora_fin' => $act['hora_fin'],
                        'descripcion' => $act['descripcion'],
                        'horas_habiles' => $act['horas_habiles'] ?? 0,
                        'horas_no_habiles' => $act['horas_no_habiles'] ?? 0,
                        'horas_festivas' => $act['horas_festivas'] ?? 0,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                }
                \App\Models\HojaTiempoActividad::insert($actividadesNuevas);
            }

            DB::commit();

            // 6. Recargamos el día con sus nuevas actividades para devolverlo
            $dia->load('actividades');

            return response()->json([
                'success' => true,
                'message' => 'Día guardado exitosamente',
                'data' => $dia
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Error al guardar el día',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Obtener todos los clientes
    public function getClientes()
    {
        // Ajusta 'clientes' y los nombres de columnas según tu base de datos real
        $clientes = \Illuminate\Support\Facades\DB::table('cliente')
            ->select('id_cliente', 'nombre_cliente') // Cambia 'nombre' si tu columna se llama diferente (ej: razon_social)
            ->get();
            
        return response()->json(['success' => true, 'data' => $clientes]);
    }

    // Obtener servicios de un cliente específico
    public function getServiciosPorCliente($id_cliente)
    {
        $servicios = \Illuminate\Support\Facades\DB::table('servicio')
            ->where('id_cliente', $id_cliente)
            ->select('id_servicio', 'nombre_servicio') // Ajusta las columnas
            ->get();
            
        return response()->json(['success' => true, 'data' => $servicios]);
    }

    // Obtener OC de un servicio específico
    public function getOcsPorServicio($id_servicio)
    {
        $ocs = \Illuminate\Support\Facades\DB::table('oc_cliente')
            ->where('id_servicio', $id_servicio)
            ->select('id_oc_cliente', 'cod_oc_cliente') // Ajusta las columnas
            ->get();
            
        return response()->json(['success' => true, 'data' => $ocs]);
    }
}