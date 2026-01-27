<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use App\Models\Gasto;          // <--- ¡AGREGA ESTA LÍNEA!
use App\Models\GastoArchivo;
use App\Models\Rendicion;
use App\Models\Servicio;
use App\Models\Registro;
use App\Models\User;               // <--- Faltaba esta
use Illuminate\Support\Facades\Http;

class RendicionController extends Controller
{
    /**
     * 1. CREAR BORRADOR
     * - Fecha: NULL (Se asignará al enviar)
     * - Carpetas: Se crean basadas en el ID con 3 dígitos (ej: 001)
     */
    public function store(Request $request)
    {
        $request->validate([
            'id_servicio'     => 'required|exists:servicio,id_servicio',
            'proposito'       => 'required|string|max:255',
            'monto_entregado' => 'nullable|integer',
        ]);

        try {
            DB::beginTransaction();

            $servicio = Servicio::findOrFail($request->id_servicio);
            
            // 1. Crear en BD (Fecha NULL)
            $rendicion = Rendicion::create([
                'id_usuario'      => Auth::id(),
                'id_servicio'     => $request->id_servicio,
                'fecha'           => null, 
                'proposito'       => $request->proposito,
                'monto_entregado' => $request->monto_entregado ?? 0,
                'estado'          => 'Borrador',
                'centro_costo'    => $servicio->centro_costo,
            ]);

            // 2. Crear Carpetas NAS: ID con 3 ceros (ej: ID 1 -> "001")
            $nombreCarpeta = str_pad($rendicion->id_rendicion, 3, '0', STR_PAD_LEFT);

            Storage::disk('nas_rendiciones')->makeDirectory($nombreCarpeta . '/gastos');
            Storage::disk('nas_rendiciones')->makeDirectory($nombreCarpeta . '/pago');

            DB::commit();

            return response()->json([
                'success' => true, 
                'message' => 'Rendición borrador creada',
                'data' => $rendicion
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * ACTUALIZAR RENDICIÓN (Solo Borrador u Observada)
     */
    public function update(Request $request, $id)
    {
        // 1. Buscar
        $rendicion = Rendicion::findOrFail($id);

        // 2. Validar Dueño
        if ($rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        // 3. Validar Estado (Solo se pueden editar estos estados)
        if (!in_array($rendicion->estado, ['Borrador', 'Observada'])) {
            return response()->json(['message' => 'Solo se pueden editar rendiciones en Borrador u Observadas'], 400);
        }

        // 4. Validar Datos
        $request->validate([
            'proposito'       => 'required|string|max:255',
            'monto_entregado' => 'required|integer|min:0',
            // Agrega 'id_servicio' si permites cambiar el centro de costo
        ]);

        // 5. Actualizar
        // Si estaba "Observada", al editarla la volvemos a pasar a "Borrador"
        // para que el usuario tenga que volver a enviarla.
        $nuevoEstado = $rendicion->estado === 'Observada' ? 'Borrador' : $rendicion->estado;

        $rendicion->update([
            'proposito'       => $request->proposito,
            'monto_entregado' => $request->monto_entregado,
            'estado'          => $nuevoEstado, 
        ]);

        return response()->json([
            'success' => true, 
            'message' => 'Rendición actualizada correctamente', 
            'data'    => $rendicion
        ]);
    }

    /**
     * 3. ENVIAR A REVISIÓN
     * - Aquí se asigna la FECHA REAL (now).
     * - Cambia estado a 'Pendiente de Validación'.
     */
    public function enviar($id)
    {
        // 1. Cargar la rendición con sus gastos y el usuario dueño (para el nombre)
        $rendicion = Rendicion::with(['gastos', 'usuario'])->findOrFail($id);

        if ($rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        // Validación: Debe tener gastos
        if ($rendicion->gastos()->count() == 0) {
            return response()->json(['message' => 'La rendición está vacía, agrega gastos antes de enviar.'], 400);
        }

        // 2. Actualizar Estado
        $rendicion->update([
            'estado' => 'Pendiente de Validación',
            // 'fecha' => now(), // Descomenta si quieres actualizar la fecha de envío
        ]);

        // --- INICIO LÓGICA DE NOTIFICACIONES ---
        try {
            // A. Buscar IDs de usuarios con rol 'Validador' o 'Administrador'
            // Ajusta 'tipo_usuario' según cómo se llamen tus roles en la BD
            $validadoresIds = User::whereHas('roles', function($q) {
                $q->whereIn('tipo_usuario', ['Administrador', 'Validador']);
            })->pluck('id_usuario')->toArray();

            // B. Preparar el mensaje
            $nombreUsuario = $rendicion->usuario->nombre_usuario ?? 'Un usuario';
            $titulo = "Nueva Rendición por Validar";
            $mensaje = "{$nombreUsuario} ha enviado la rendición #{$rendicion->id_rendicion} para revisión.";

            // C. Enviar usando la función helper (asegúrate de tenerla en el controller o trait)
            $this->enviarNotificacionOneSignal(
                $validadoresIds, 
                $titulo, 
                $mensaje, 
                ['id_rendicion' => $rendicion->id_rendicion, 'tipo' => 'validacion_pendiente']
            );

        } catch (\Exception $e) {
            // Logueamos el error pero NO detenemos el flujo. 
            // Es mejor que la rendición se envíe aunque falle la notificación.
            \Log::error("Error enviando notificación OneSignal: " . $e->getMessage());
        }
        // --- FIN LÓGICA DE NOTIFICACIONES ---

        return response()->json(['success' => true, 'message' => 'Rendición enviada a revisión']);
    }

    // --- Métodos de lectura (sin cambios) ---
    public function misRendiciones()
    {
        $rendiciones = Rendicion::where('id_usuario', Auth::id())
         ->with([
                'servicio:id_servicio,nombre_servicio,centro_costo', 
                'gastos',
                'registros' // <--- IMPORTANTE: Cargar esto para que el accessor tenga datos
            ])
            ->orderByDesc('id_rendicion')
            ->get();

        return response()->json($rendiciones);
    }

    public function show($id)
    {
        $rendicion = Rendicion::with(['gastos.archivos', 'servicio'])->findOrFail($id);
        
        // 1. Verificar si es el dueño
        $esDuenio = $rendicion->id_usuario == Auth::id();

        // 2. Verificar si es Validador/Admin (Usando la relación 'roles' de tu modelo User)
        // Ajusta 'Administrador' y 'Validador' a los nombres EXACTOS que tengas en tu tabla 'tipo_usuario'
        $esValidador = Auth::user()->roles()
                        ->whereIn('tipo_usuario', ['Administrador', 'Validador'])
                        ->exists();

        // 3. La puerta lógica: Entras si eres dueño O si eres validador
        if (!$esDuenio && !$esValidador) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        return response()->json($rendicion);
    }

    public function destroy($id)
    {
        try {
            // Buscamos la rendición con sus gastos y archivos para poder borrar físicamente
            $rendicion = Rendicion::with(['gastos.archivos'])->findOrFail($id);

            // 1. Validar Autoría
            if ($rendicion->id_usuario != Auth::id()) {
                return response()->json(['message' => 'No autorizado'], 403);
            }

            // 2. Validar Estado (Solo Borrador u Observada se pueden borrar)
            if (!in_array($rendicion->estado, ['Borrador', 'Observada'])) {
                return response()->json(['message' => 'No se puede eliminar una rendición en proceso o aprobada'], 400);
            }

            DB::beginTransaction();

            // 3. Borrar Archivos Físicos (Loop profundo)
            foreach ($rendicion->gastos as $gasto) {
                foreach ($gasto->archivos as $archivo) {
                    if (Storage::disk('nas_rendiciones')->exists($archivo->ruta_relativa)) {
                        Storage::disk('nas_rendiciones')->delete($archivo->ruta_relativa);
                    }
                }
            }

            // 4. Borrar Carpetas Físicas (Opcional, si creaste carpetas por rendición)
            $nombreCarpeta = str_pad($rendicion->id_rendicion, 3, '0', STR_PAD_LEFT);
            if (Storage::disk('nas_rendiciones')->exists($nombreCarpeta)) {
                Storage::disk('nas_rendiciones')->deleteDirectory($nombreCarpeta);
            }

            // 5. Borrar Registro (La BD borrará los gastos en cascada si está configurada, sino Laravel lo hace)
            $rendicion->gastos()->delete(); // Borramos gastos hijos primero por seguridad
            $rendicion->delete();

            DB::commit();

            return response()->json(['success' => true, 'message' => 'Rendición eliminada correctamente']);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function pendientesDeValidacion()
    {
        $rendiciones = Rendicion::whereIn('estado', ['Pendiente de Validación', 'Aprobada'])
                        ->with([
                            'servicio:id_servicio,nombre_servicio,centro_costo', 
                            'usuario:id_usuario,nombre_usuario'
                        ])
                        // CAMBIO AQUÍ: Usamos withSum en vez de cargar toda la relación 'gastos'
                        ->withSum('gastos', 'monto') 
                        ->orderBy('fecha', 'asc') 
                        ->get();

        return response()->json($rendiciones);
    }


    public function historialGlobal()
    {
        $rendiciones = Rendicion::with(['usuario', 'gastos']) // Cargar relaciones es OBLIGATORIO
                        ->orderByDesc('id_rendicion') // Las más nuevas primero
                        ->get();

        return response()->json($rendiciones);
    }

    /**
     * PROCESAR VALIDACIÓN (ADMIN)
     * Recibe un array con la decisión de cada gasto.
     */
    public function procesarValidacion(Request $request, $idRendicion)
    {
        // Validamos que venga la lista de evaluaciones
        $request->validate([
            'evaluaciones' => 'required|array', 
            // Estructura esperada: [ { "id_gasto": 1, "estado": "Aprobado" }, { "id_gasto": 2, "estado": "Rechazado", "comentario": "Falta boleta" } ]
        ]);

        $rendicion = Rendicion::findOrFail($idRendicion);
        $evaluaciones = $request->evaluaciones;
        $hayRechazados = false;

        DB::beginTransaction();
        try {
            foreach ($evaluaciones as $eval) {
                $gasto = Gasto::find($eval['id_gasto']);
                
                if ($gasto) {
                    // 1. Actualizar estado del gasto
                    $gasto->estado_gasto = $eval['estado']; // 'Aprobado' o 'Rechazado'
                    
                    // 2. Guardar comentario si existe (solo si es rechazado usualmente, pero guardamos lo que venga)
                    if (isset($eval['comentario'])) {
                        $gasto->comentario_validador = $eval['comentario'];
                    } else {
                        // Limpiamos comentario si se aprueba para evitar confusiones futuras
                        $gasto->comentario_validador = null; 
                    }

                    // 3. Registrar QUIÉN validó (Auditoría)
                    $gasto->id_validador = Auth::id();
                    
                    $gasto->save();

                    // Detectar si hay rechazos para la lógica global
                    if ($eval['estado'] === 'Rechazado') {
                        $hayRechazados = true;
                    }
                }
            }

            // --- LÓGICA DE ESTADO GLOBAL ---
            if ($hayRechazados) {
                $rendicion->estado = 'Observada';
            } else {
                $rendicion->estado = 'Aprobada'; // Lista para pago
            }
            
            $rendicion->save();
            
            DB::commit();

            return response()->json([
                'success' => true, 
                'message' => $hayRechazados ? 'Rendición observada y devuelta al usuario' : 'Rendición aprobada exitosamente',
                'nuevo_estado' => $rendicion->estado
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * PAGAR RENDICIÓN (Subir comprobante)
     */
    public function pagar(Request $request, $id)
    {
        // 1. Validaciones
        $request->validate([
            'comprobante' => 'required|file|mimes:jpg,jpeg,png,pdf|max:10240',
        ]);

        try {
            DB::beginTransaction();

            // Cargamos la rendición
            $rendicion = Rendicion::withSum('gastos', 'monto')->findOrFail($id);

            if ($request->hasFile('comprobante')) {
                $file = $request->file('comprobante');
                $extension = $file->getClientOriginalExtension();
                $pesoKb = round($file->getSize() / 1024, 2);

                // --- LÓGICA DE RUTAS ---
                $carpetaRendicion = str_pad($rendicion->id_rendicion, 3, '0', STR_PAD_LEFT);
                $pathDestino = $carpetaRendicion . '/pago'; 
                $nombreFisico = 'PAGO_' . time() . '.' . $extension;

                // Guardar físico
                $file->storeAs($pathDestino, $nombreFisico, 'nas_rendiciones');
                $rutaRelativa = $pathDestino . '/' . $nombreFisico;

                // Crear Registro
                $registro = new Registro(); 
                $registro->id_rendicion = $id;
                $registro->id_usuario_pagador = Auth::id();
                $registro->fecha_pago = now();
                $registro->monto_pagado = $rendicion->gastos_sum_monto ?? 0;
                $registro->nombre_original = $file->getClientOriginalName();
                $registro->nombre_fisico = $nombreFisico;
                $registro->ruta_relativa = $rutaRelativa;
                $registro->extension = $extension;
                $registro->peso_kb = $pesoKb;
                $registro->save();

                // Actualizar Rendición
                $rendicion->estado = 'Pagada';
                $rendicion->save();

                DB::commit(); // <--- Confirmamos la transacción en BD primero

                // --- INICIO NOTIFICACIÓN AL DUEÑO ---
                try {
                    // Enviamos al dueño de la rendición ($rendicion->id_usuario)
                    $this->enviarNotificacionOneSignal(
                        [$rendicion->id_usuario], 
                        "¡Rendición Pagada! 💰", 
                        "Tu rendición #{$rendicion->id_rendicion} ha sido pagada. Puedes ver el comprobante en la App.", 
                        [
                            'id_rendicion' => $rendicion->id_rendicion, 
                            'tipo' => 'pago_realizado'
                        ]
                    );
                } catch (\Exception $e) {
                    // Si falla la notificación, solo lo registramos en el log
                    // No queremos que falle el pago real por culpa de una notificación
                    \Log::error("Error enviando notificación OneSignal al pagar: " . $e->getMessage());
                }
                // --- FIN NOTIFICACIÓN ---

                return response()->json([
                    'success' => true, 
                    'message' => 'Pago registrado correctamente',
                    'ruta' => $rutaRelativa
                ]);
            } else {
                return response()->json(['message' => 'No se recibió el archivo'], 400);
            }

        } catch (\Exception $e) {
            DB::rollBack();
            
            // Limpieza de archivo si falló
            if (isset($pathDestino) && isset($nombreFisico)) {
                Storage::disk('nas_rendiciones')->delete($pathDestino . '/' . $nombreFisico);
            }
            
            return response()->json(['message' => 'Error al pagar: ' . $e->getMessage()], 500);
        }
    }

    public function contarPendientes()
    {
        // Contamos las que están "Pendiente de Validación" o "Aprobada" (Por Pagar)
        $cantidad = Rendicion::whereIn('estado', ['Pendiente de Validación', 'Aprobada'])->count();
        return response()->json(['cantidad' => $cantidad]);
    }

    private function enviarNotificacionOneSignal($userIds, $titulo, $mensaje, $dataAdicional = [])
{
    // Buscamos los OneSignal IDs de los usuarios destino
    // OJO: $userIds debe ser un array de IDs de tu tabla users (ej: [1, 5])
    $destinatarios = User::whereIn('id_usuario', $userIds)
                         ->whereNotNull('onesignal_id')
                         ->pluck('onesignal_id')
                         ->toArray();

    if (empty($destinatarios)) return;
    
    $response = Http::withHeaders([
        'Content-Type' => 'application/json; charset=utf-8',
        'Authorization' => 'Basic os_v2_app_4xg7b2xncrf5jixe4dno42mpknstbgnysppupq52nqzvgazdmk3otudhs3a25gzfjpmy5qdd3oiy34vvyxbub2tmgbheb4jlgvwngvi' // <--- Sacar de OneSignal Dashboard
    ])->post('https://onesignal.com/api/v1/notifications', [
        'app_id' => 'e5cdf0ea-ed14-4bd4-a2e4-e0daee698f53', // <--- Sacar de OneSignal Dashboard
        'include_player_ids' => $destinatarios, // Array de IDs de OneSignal
        'headings' => ['en' => $titulo],
        'contents' => ['en' => $mensaje],
        'data' => $dataAdicional, // Ej: ['id_rendicion' => 123, 'pantalla' => 'detalle']
        'small_icon' => 'ic_stat_onesignal_default', // Icono en barra de estado
    ]);
    
}
}