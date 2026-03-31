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
use App\Models\User;
use App\Services\OneSignalService;
use Illuminate\Support\Facades\Auth; // <--- IMPORTACIÓN NECESARIA PARA CAPTURAR AL VALIDADOR


class HojaTiempoController extends Controller
{
    // =========================================================================
    // 1. DROPDOWNS EN CASCADA (Clientes -> Servicios -> OC)
    // =========================================================================
   
    public function getClientes()
    {
        $clientes = Cliente::select('id_cliente', 'nombre_cliente')->get();
        return response()->json(['success' => true, 'data' => $clientes]);
    }


    public function getServiciosPorCliente($id_cliente)
    {
        $servicios = Servicio::where('id_cliente', $id_cliente)
            ->select('id_servicio', 'nombre_servicio', 'correlativo', 'centro_costo')
            ->get();
        return response()->json(['success' => true, 'data' => $servicios]);
    }


    public function getOcsPorServicio($id_servicio)
    {
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


            $servicio = \Illuminate\Support\Facades\DB::table('servicio')->where('id_servicio', $request->id_servicio)->first();
            $centroCostoFijo = $servicio->centro_costo ?? 'SIN-CENTRO-COSTO';
            $numeroFormateado = str_pad($request->numero_hct, 2, "0", STR_PAD_LEFT);
            $nombreHct = "{$centroCostoFijo}-HTC-{$numeroFormateado}";


            $fechaRef = \Carbon\Carbon::parse($request->fecha);
            $inicio = $fechaRef->startOfWeek()->format('Y-m-d');
            $fin = $fechaRef->endOfWeek()->format('Y-m-d');


            $semana = \App\Models\HojaTiempoSemana::create([
                'id_usuario' => $request->id_usuario,
                'id_servicio' => $request->id_servicio,
                'id_oc_cliente' => $request->id_oc_cliente,
                'numero_hct' => $request->numero_hct,
                'nombre_comprobante' => $nombreHct,
                'centro_costo' => $servicio->centro_costo,
                'numero_semana' => $fechaRef->weekOfYear,
                'fecha_inicio' => $inicio,
                'fecha_fin' => $fin,
                'estado' => 'Borrador',
            ]);


            $diasInsert = [];
            for ($i = 0; $i < 7; $i++) {
                $diasInsert[] = [
                    'id_hoja_semana' => $semana->id_hoja_semana,
                    'fecha' => \Carbon\Carbon::parse($inicio)->addDays($i)->format('Y-m-d'),
                    'lugar' => 'DESCANSO',
                    'tipo_dia' => 'NO_HABIL',
                    'viaje_horas' => 0,
                    'estado' => 'Borrador', // Estado inicial del día
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


        $hojas = \App\Models\HojaTiempoSemana::select(
                'hojas_tiempo_semanas.*',
                'cliente.nombre_cliente',
                'personal.nombre_personal as usuario_nombre',
                'personal.apellido_personal as usuario_apellido'
            )
            ->join('servicio', 'hojas_tiempo_semanas.id_servicio', '=', 'servicio.id_servicio')
            ->join('cliente', 'servicio.id_cliente', '=', 'cliente.id_cliente')
            ->leftJoin('usuarios', 'hojas_tiempo_semanas.id_usuario', '=', 'usuarios.id_usuario')
            ->leftJoin('personal', 'usuarios.id_personal', '=', 'personal.id_personal')
            ->with(['servicio', 'ocCliente'])
            ->where('hojas_tiempo_semanas.id_usuario', $request->id_usuario)
            ->orderBy('hojas_tiempo_semanas.fecha_inicio', 'desc')
            ->get();


        return response()->json(['success' => true, 'data' => $hojas]);
    }


   public function detalleHoja($id_hoja_semana)
    {
        $hoja = \App\Models\HojaTiempoSemana::select(
                'hojas_tiempo_semanas.*',
                'servicio.nombre_servicio',
                'cliente.nombre_cliente',
                'personal.nombre_personal as usuario_nombre',
                'personal.apellido_personal as usuario_apellido'
            )
            ->join('servicio', 'hojas_tiempo_semanas.id_servicio', '=', 'servicio.id_servicio')
            ->join('cliente', 'servicio.id_cliente', '=', 'cliente.id_cliente')
            ->leftJoin('usuarios', 'hojas_tiempo_semanas.id_usuario', '=', 'usuarios.id_usuario')
            ->leftJoin('personal', 'usuarios.id_personal', '=', 'personal.id_personal')
            // 👇 AQUÍ ESTÁ LA CORRECCIÓN: Agregamos 'dias.validador.personal' 👇
            ->with(['ocCliente', 'dias.actividades', 'validador.personal', 'dias.validador.personal'])
            ->where('hojas_tiempo_semanas.id_hoja_semana', $id_hoja_semana)
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
            'area' => 'nullable|string|max:255',
        ]);


        try {
            DB::beginTransaction();


            $dia = HojaTiempoDiaria::findOrFail($id_hoja_diaria);


            // Validación de Bloqueo: No permite guardar si ya fue enviado o aprobado
            if ($dia->estado === 'Enviada' || $dia->estado === 'Aprobada') {
                return response()->json([
                    'success' => false,
                    'error' => 'No puedes editar un día que se encuentra en revisión o aprobado.'
                ], 403);
            }


            $dia->update([
                'lugar' => $request->lugar,
                'tipo_dia' => $request->tipo_dia,
                'horario_inicio' => $request->horario_inicio,
                'horario_fin' => $request->horario_fin,
                'viaje_horas' => $request->viaje_horas ?? 0,
                'area' => $request->area,
                'estado' => 'Borrador', // Si estaba rechazada, vuelve a borrador al guardar cambios
            ]);


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
            return response()->json(['success' => true, 'message' => 'Guardado Correctamente']);


        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }


    // --- NUEVO: ENVIAR UN DÍA ESPECÍFICO A REVISIÓN ---
    public function enviarDia(Request $request, $id_hoja_diaria)
    {
        try {
            $dia = HojaTiempoDiaria::findOrFail($id_hoja_diaria);
            $hoja = HojaTiempoSemana::findOrFail($dia->id_hoja_semana);


            if ($dia->estado === 'Enviada' || $dia->estado === 'Aprobada') {
                return response()->json(['success' => false, 'error' => 'Este día ya se encuentra en validación o fue aprobado.'], 403);
            }


            $dia->estado = 'Enviada';
            $dia->save();


            // Notificación al administrador
            try {
                $trabajador = User::find($hoja->id_usuario);
                $nombreTrabajador = $trabajador ? ($trabajador->nombre_usuario) : 'Un trabajador';


                $validadoresIds = User::whereHas('roles', function($q) {
                    $q->whereIn('tipo_usuario', ['Administrador', 'Validador HT']);
                })->pluck('id_usuario')->toArray();


                OneSignalService::enviar(
                    $validadoresIds,
                    "Día Pendiente de Validación ⏱️",
                    "{$nombreTrabajador} ha enviado su registro del día {$dia->fecha} para ser validado.",
                    [
                        'id_hoja_diaria' => $dia->id_hoja_diaria,
                        'tipo' => 'hoja_tiempo_diaria_pendiente'
                    ]
                );
            } catch (\Exception $ex) {
                \Log::error("Error enviando notificación: " . $ex->getMessage());
            }


            return response()->json(['success' => true, 'message' => 'Día enviado a validación correctamente']);


        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }


    public function enviarSemana(Request $request, $id_hoja_semana)
    {
        $request->validate([
            'observacion' => 'nullable|string'
        ]);


        try {
            DB::beginTransaction();


            $hoja = \App\Models\HojaTiempoSemana::findOrFail($id_hoja_semana);
            $hoja->estado = 'Enviada';
            $hoja->observacion = $request->observacion;
            $hoja->save();


            // Al enviar la semana completa, todos los días que sigan en Borrador o Rechazados pasan a Enviada.
            HojaTiempoDiaria::where('id_hoja_semana', $id_hoja_semana)
                ->whereIn('estado', ['Borrador', 'Rechazada'])
                ->update(['estado' => 'Enviada']);


            DB::commit();


            try {
                $trabajador = User::find($hoja->id_usuario);
                $nombreTrabajador = $trabajador ? ($trabajador->nombre_usuario) : 'Un trabajador';


                $validadoresIds = User::whereHas('roles', function($q) {
                    $q->whereIn('tipo_usuario', ['Administrador', 'Validador HT']);
                })->pluck('id_usuario')->toArray();


                OneSignalService::enviar(
                    $validadoresIds,
                    "Semana Pendiente de Validación ⏱️",
                    "{$nombreTrabajador} ha enviado la semana número {$hoja->numero_semana} para ser validada.",
                    [
                        'id_hoja_semana' => $hoja->id_hoja_semana,
                        'tipo' => 'hoja_tiempo_pendiente'
                    ]
                );
            } catch (\Exception $ex) {
                \Log::error("Error enviando notificación OneSignal: " . $ex->getMessage());
            }


            return response()->json([
                'success' => true,
                'message' => 'Hoja y días pendientes enviados a validación correctamente',
                'data' => $hoja
            ]);


        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }


    // =========================================================================
    // 3. ADMINISTRACIÓN (Pendientes, Historial Global y Evaluar)
    // =========================================================================


// =========================================================
    // 1. Listado de SEMANAS Pendientes
    // =========================================================
    public function pendientesAdmin()
    {
        $hojas = \App\Models\HojaTiempoSemana::select(
                'hojas_tiempo_semanas.*',
                'cliente.nombre_cliente',
                'personal.nombre_personal as usuario_nombre',
                'personal.apellido_personal as usuario_apellido'
            )
            ->join('servicio', 'hojas_tiempo_semanas.id_servicio', '=', 'servicio.id_servicio')
            ->join('cliente', 'servicio.id_cliente', '=', 'cliente.id_cliente')
            ->leftJoin('usuarios', 'hojas_tiempo_semanas.id_usuario', '=', 'usuarios.id_usuario')
            ->leftJoin('personal', 'usuarios.id_personal', '=', 'personal.id_personal')
            ->with(['servicio', 'ocCliente'])
            ->where('hojas_tiempo_semanas.estado', 'Enviada')
            ->orderBy('hojas_tiempo_semanas.updated_at', 'asc')
            ->get();

        return response()->json(['success' => true, 'data' => $hojas]);
    }


    // =========================================================
    // 2. Listado de DÍAS Pendientes
    // =========================================================
    public function pendientesDiariasAdmin()
    {
        try {
            $dias = \App\Models\HojaTiempoDiaria::select(
                    'hojas_tiempo_diarias.*',
                    'hojas_tiempo_semanas.numero_hct',
                    'hojas_tiempo_semanas.numero_semana',
                    'hojas_tiempo_semanas.id_usuario',
                    'cliente.nombre_cliente',
                    'servicio.nombre_servicio',
                    'personal.nombre_personal as usuario_nombre',
                    'personal.apellido_personal as usuario_apellido'
                )
                ->join('hojas_tiempo_semanas', 'hojas_tiempo_diarias.id_hoja_semana', '=', 'hojas_tiempo_semanas.id_hoja_semana')
                ->join('servicio', 'hojas_tiempo_semanas.id_servicio', '=', 'servicio.id_servicio')
                ->join('cliente', 'servicio.id_cliente', '=', 'cliente.id_cliente')
                ->leftJoin('usuarios', 'hojas_tiempo_semanas.id_usuario', '=', 'usuarios.id_usuario')
                ->leftJoin('personal', 'usuarios.id_personal', '=', 'personal.id_personal')
                ->with(['actividades'])
                ->where('hojas_tiempo_diarias.estado', 'Enviada') // El día fue enviado...
                ->where('hojas_tiempo_semanas.estado', '!=', 'Enviada') // ...PERO ignoramos si la semana completa ya fue enviada
                ->orderBy('hojas_tiempo_diarias.fecha', 'asc')
                ->get();

            return response()->json(['success' => true, 'data' => $dias]);
            
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }




    public function historialAdmin()
    {
        try {
            $hojas = \App\Models\HojaTiempoSemana::select(
                    'hojas_tiempo_semanas.*',
                    'cliente.nombre_cliente',
                    'personal.nombre_personal as usuario_nombre',
                    'personal.apellido_personal as usuario_apellido',
                    'v_personal.nombre_personal as validador_nombre', // Nombres del validador
                    'v_personal.apellido_personal as validador_apellido'
                )
                ->join('servicio', 'hojas_tiempo_semanas.id_servicio', '=', 'servicio.id_servicio')
                ->join('cliente', 'servicio.id_cliente', '=', 'cliente.id_cliente')
                ->leftJoin('usuarios', 'hojas_tiempo_semanas.id_usuario', '=', 'usuarios.id_usuario')
                ->leftJoin('personal', 'usuarios.id_personal', '=', 'personal.id_personal')
                ->leftJoin('usuarios as validadores', 'hojas_tiempo_semanas.validador_id', '=', 'validadores.id_usuario')
                ->leftJoin('personal as v_personal', 'validadores.id_personal', '=', 'v_personal.id_personal')
                ->with(['servicio', 'ocCliente'])
                ->where('hojas_tiempo_semanas.estado', '!=', 'Borrador')
                ->orderBy('hojas_tiempo_semanas.updated_at', 'desc')
                ->get();


            return response()->json(['success' => true, 'data' => $hojas]);
           
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => 'Error al obtener historial: ' . $e->getMessage()], 500);
        }
    }


    // --- Evaluar un día específico ---
    public function evaluarDia(Request $request, $id)
    {
        $request->validate([
            'estado' => 'required|in:Aprobada,Rechazada',
            'observacion' => 'nullable|string'
        ]);


        try {
            $dia = \App\Models\HojaTiempoDiaria::findOrFail($id);
            $dia->estado = $request->estado;
           
            if ($request->filled('observacion')) {
                $dia->observacion = $request->observacion;
            } else {
                $dia->observacion = null;
            }


            $dia->validador_id = Auth::id();
            $dia->save();


            $hoja = \App\Models\HojaTiempoSemana::findOrFail($dia->id_hoja_semana);


            // Notificación al empleado
            try {
                $titulo = $request->estado === 'Aprobada' ? "Día Aprobado ✅" : "Día Rechazado ❌";
                $mensaje = $request->estado === 'Aprobada'
                    ? "Tu registro del día {$dia->fecha} ha sido aprobado."
                    : "Tu registro del día {$dia->fecha} ha sido rechazado. Revisa la observación.";


                OneSignalService::enviar(
                    [$hoja->id_usuario],
                    $titulo,
                    $mensaje,
                    [
                        'id_hoja_diaria' => $dia->id_hoja_diaria,
                        'tipo' => 'hoja_tiempo_diaria_evaluada'
                    ]
                );
            } catch (\Exception $ex) {
                \Log::error("Error enviando notificación evaluación: " . $ex->getMessage());
            }


            return response()->json([
                'success' => true,
                'message' => 'Día evaluado correctamente',
                'data' => $dia
            ]);


        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }


    // Evaluar la semana completa (Mantiene lógica anterior)
    public function evaluarHoja(Request $request, $id)
    {
        $request->validate([
            'estado' => 'required|in:Aprobada,Rechazada',
            'observacion' => 'nullable|string'
        ]);


        try {
            $hoja = \App\Models\HojaTiempoSemana::findOrFail($id);
            $hoja->estado = $request->estado;
           
            if ($request->filled('observacion')) {
                $hoja->observacion = $request->observacion;
            }


            $hoja->validador_id = Auth::id();
            $hoja->save();


            // Al evaluar la semana, reflejamos el mismo estado a los días que estén "Enviados"
            HojaTiempoDiaria::where('id_hoja_semana', $id)
                ->where('estado', 'Enviada')
                ->update([
                    'estado' => $request->estado,
                    'observacion' => $request->observacion ?? null,
                    'validador_id' => Auth::id() // TAMBIÉN MARCAMOS LOS DÍAS HIJOS CON EL VALIDADOR
                ]);


            try {
                $titulo = $request->estado === 'Aprobada' ? "Hoja Aprobada ✅" : "Hoja Rechazada ❌";
               
                $mensaje = $request->estado === 'Aprobada'
                    ? "Tu hoja de tiempo (Semana {$hoja->numero_semana}) ha sido aprobada."
                    : "Tu hoja de tiempo (Semana {$hoja->numero_semana}) ha sido rechazada. Revisa la observación.";


                OneSignalService::enviar(
                    [$hoja->id_usuario],
                    $titulo,
                    $mensaje,
                    [
                        'id_hoja_semana' => $hoja->id_hoja_semana,
                        'tipo' => 'hoja_tiempo_evaluada'
                    ]
                );


            } catch (\Exception $ex) {
                \Log::error("Error enviando notificación evaluación: " . $ex->getMessage());
            }


            return response()->json([
                'success' => true,
                'message' => 'Semana evaluada correctamente',
                'data' => $hoja
            ]);


        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }
}
