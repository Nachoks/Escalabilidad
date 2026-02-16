<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\HojaTiempoSemana;
use App\Models\HojaTiempoDiaria;
use App\Models\HojaTiempoActividad;
use App\Models\Servicio;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Models\Cliente;
use App\Models\OcCliente;

class HojaTiempoController extends Controller
{
    // =========================================================================
    // 1. DROPDOWNS EN CASCADA (Clientes -> Servicios -> OC)
    // =========================================================================
    
    public function getClientes()
    {
        // Usamos el Modelo Cliente. Asegúrate de que en App\Models\Cliente
        // tengas definido: protected $table = 'clientes'; (o el nombre real de tu tabla)
        $clientes = Cliente::select('id_cliente', 'nombre_cliente')->get();
        
        return response()->json(['success' => true, 'data' => $clientes]);
    }

    public function getServiciosPorCliente($id_cliente)
    {
        // Usamos el Modelo Servicio
        $servicios = Servicio::where('id_cliente', $id_cliente)
            ->select('id_servicio', 'nombre_servicio', 'correlativo', 'centro_costo')
            ->get();
            
        return response()->json(['success' => true, 'data' => $servicios]);
    }

    public function getOcsPorServicio($id_servicio)
    {
        // Usamos el Modelo OcCliente
        $ocs = OcCliente::where('id_servicio', $id_servicio)
            ->select('id_oc_cliente', 'cod_oc_cliente')
            ->get();
            
        return response()->json(['success' => true, 'data' => $ocs]);
    }

    // =========================================================================
    // 2. GESTIÓN DE HOJAS DE TIEMPO (Crear, Listar, Detalle, Guardar Día)
    // =========================================================================

    public function crearSemana(Request $request)
    {
        $request->validate([
            'id_usuario' => 'required',
            'id_servicio' => 'required',
            'id_oc_cliente' => 'required',
            'fecha' => 'required|date',
            'numero_hct' => 'required|integer|between:1,99',
        ]);

        // Regla de unicidad
        $existe = \App\Models\HojaTiempoSemana::where('id_servicio', $request->id_servicio)
            ->where('numero_hct', $request->numero_hct)
            ->exists();

        if ($existe) {
            return response()->json([
                'success' => false, 
                'message' => "La HCT N°{$request->numero_hct} ya existe para este servicio."
            ], 422);
        }

        try {
            \Illuminate\Support\Facades\DB::beginTransaction();

            // 1. Buscamos el servicio
            $servicio = \Illuminate\Support\Facades\DB::table('servicio')->where('id_servicio', $request->id_servicio)->first();
            
            // 2. ¡AQUÍ ESTÁ EL CAMBIO! Usamos centro_costo en lugar de correlativo.
            $centroCostoFijo = $servicio->centro_costo ?? 'SIN-CENTRO-COSTO';
            
            // 3. Formateamos estrictamente el número ingresado para que tenga 2 dígitos (Ej: 3 -> "03")
            $numeroFormateado = str_pad($request->numero_hct, 2, "0", STR_PAD_LEFT);

            // 4. Armamos la cadena final: Centro de Costo + HTC + Número
            $nombreHct = "{$centroCostoFijo}-HTC-{$numeroFormateado}";

            // Fechas
            $fechaRef = \Carbon\Carbon::parse($request->fecha);
            $inicio = $fechaRef->startOfWeek()->format('Y-m-d');
            $fin = $fechaRef->endOfWeek()->format('Y-m-d');

            // Crear Semana (Padre)
            $semana = \App\Models\HojaTiempoSemana::create([
                'id_usuario' => $request->id_usuario,
                'id_servicio' => $request->id_servicio,
                'id_oc_cliente' => $request->id_oc_cliente,
                'numero_hct' => $request->numero_hct,
                'nombre_comprobante' => $nombreHct,
                'centro_costo' => $servicio->centro_costo, // Esto se sigue guardando igual
                'numero_semana' => $fechaRef->weekOfYear,
                'fecha_inicio' => $inicio,
                'fecha_fin' => $fin,
                'estado' => 'Borrador',
            ]);

            // Crear los 7 Días (Hijos)
            $diasInsert = [];
            for ($i = 0; $i < 7; $i++) {
                $diasInsert[] = [
                    'id_hoja_semana' => $semana->id_hoja_semana,
                    'fecha' => \Carbon\Carbon::parse($inicio)->addDays($i)->format('Y-m-d'),
                    'lugar' => 'DESCANSO', // Valor por defecto
                    'tipo_dia' => 'NO_HABIL', // Valor por defecto
                    'viaje_horas' => 0,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
            \App\Models\HojaTiempoDiaria::insert($diasInsert);

            \Illuminate\Support\Facades\DB::commit();

            return response()->json([
                'success' => true, 
                'message' => 'Semana creada',
                'data' => $semana
            ], 201);

        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error al crear', 'error' => $e->getMessage()], 500);
        }
    }

    public function misHojas(Request $request)
    {
        $request->validate(['id_usuario' => 'required']);

        // Hacemos un JOIN con servicio y cliente para traer el nombre_cliente a la primera capa del JSON
        $hojas = \App\Models\HojaTiempoSemana::select('hojas_tiempo_semanas.*', 'cliente.nombre_cliente')
            ->join('servicio', 'hojas_tiempo_semanas.id_servicio', '=', 'servicio.id_servicio')
            ->join('cliente', 'servicio.id_cliente', '=', 'cliente.id_cliente')
            ->with(['servicio', 'ocCliente'])
            ->where('hojas_tiempo_semanas.id_usuario', $request->id_usuario)
            ->orderBy('hojas_tiempo_semanas.fecha_inicio', 'desc')
            ->get();

        return response()->json(['success' => true, 'data' => $hojas]);
    }

    public function detalleHoja($id_hoja_semana)
    {
        // Trae la semana, con sus días, y las actividades de cada día. Todo en 1 consulta eficiente.
        $hoja = HojaTiempoSemana::with(['servicio', 'ocCliente', 'dias.actividades'])
            ->where('id_hoja_semana', $id_hoja_semana)
            ->first();

        if (!$hoja) {
            return response()->json(['success' => false, 'message' => 'No encontrada'], 404);
        }

        return response()->json(['success' => true, 'data' => $hoja]);
    }

    public function guardarDia(Request $request, $id_hoja_diaria)
    {
        $request->validate([
            'lugar' => 'required|in:OFICINA,TERRENO,DESCANSO',
            'tipo_dia' => 'required|in:HABIL,NO_HABIL,FERIADO',
            'viaje_horas' => 'nullable|numeric|min:0',
            'actividades' => 'nullable|array',
        ]);

        try {
            DB::beginTransaction();

            // 1. Actualizar el Día
            $dia = HojaTiempoDiaria::findOrFail($id_hoja_diaria);
            $dia->update([
                'lugar' => $request->lugar,
                'tipo_dia' => $request->tipo_dia,
                'horario_inicio' => $request->horario_inicio,
                'horario_fin' => $request->horario_fin,
                'viaje_horas' => $request->viaje_horas ?? 0,
            ]);

            // 2. Reemplazar Actividades (Borramos las viejas, insertamos las nuevas)
            $dia->actividades()->delete();

            if ($request->has('actividades') && count($request->actividades) > 0) {
                $acts = [];
                foreach ($request->actividades as $act) {
                    $acts[] = [
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
                HojaTiempoActividad::insert($acts);
            }

            DB::commit();

            // Devolver el día actualizado con sus nuevas actividades
            return response()->json(['success' => true, 'data' => $dia->load('actividades')]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }
}