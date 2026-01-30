<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
// Modelos
use App\Models\Gasto;
use App\Models\GastoArchivo;
use App\Models\Rendicion;
use App\Models\Servicio;
use App\Models\Registro;
use App\Models\User;
// Servicio de Notificaciones
use App\Services\OneSignalService;

class RendicionController extends Controller
{
    /**
     * 1. CREAR BORRADOR
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

            // 2. Crear Carpetas NAS
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
     * ACTUALIZAR RENDICIÓN
     */
    public function update(Request $request, $id)
    {
        $rendicion = Rendicion::findOrFail($id);

        if ($rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        if (!in_array($rendicion->estado, ['Borrador', 'Observada'])) {
            return response()->json(['message' => 'Solo se pueden editar rendiciones en Borrador u Observadas'], 400);
        }

        $request->validate([
            'proposito'       => 'required|string|max:255',
            'monto_entregado' => 'required|integer|min:0',
        ]);

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
     */
    public function enviar($id)
    {
        // 1. Buscar la rendición
        $rendicion = Rendicion::with(['gastos', 'usuario'])->findOrFail($id);

        // 2. Validar que sea del usuario autenticado
        if ($rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        // 3. Validar que tenga gastos
        if ($rendicion->gastos()->count() == 0) {
            return response()->json(['message' => 'La rendición está vacía, agrega gastos antes de enviar.'], 400);
        }

        // 4. Actualizar Estado y capturar FECHA actual
        // Aquí agregamos el campo 'fecha' con la hora del servidor (now())
        $rendicion->update([
            'estado' => 'Pendiente de Validación',
            'fecha'  => now(), 
        ]);

        // --- NOTIFICAR A VALIDADORES (Tu lógica original intacta) ---
        try {
            $validadoresIds = User::whereHas('roles', function($q) {
                $q->whereIn('tipo_usuario', ['Administrador', 'Validador']);
            })->pluck('id_usuario')->toArray();

            $nombreUsuario = $rendicion->usuario->nombre_usuario ?? 'Un usuario';
            
            OneSignalService::enviar(
                $validadoresIds, 
                "Nueva Rendición por Validar", 
                "{$nombreUsuario} ha enviado la rendición #{$rendicion->id_rendicion} para revisión.", 
                ['id_rendicion' => $rendicion->id_rendicion, 'tipo' => 'validacion_pendiente']
            );

        } catch (\Exception $e) {
            \Log::error("Error enviando notificación OneSignal: " . $e->getMessage());
        }

        return response()->json(['success' => true, 'message' => 'Rendición enviada a revisión']);
    }

    // --- Métodos de lectura ---
    public function misRendiciones()
    {
        $rendiciones = Rendicion::where('id_usuario', Auth::id())
            ->with([
                'servicio:id_servicio,nombre_servicio,centro_costo', 
                'gastos',
                'registros'
            ])
            ->orderByDesc('id_rendicion')
            ->get();

        return response()->json($rendiciones);
    }

    public function show($id)
    {
        $rendicion = Rendicion::with(['gastos.archivos', 'servicio'])->findOrFail($id);
        
        $esDuenio = $rendicion->id_usuario == Auth::id();
        $esValidador = Auth::user()->roles()
                        ->whereIn('tipo_usuario', ['Administrador', 'Validador'])
                        ->exists();

        if (!$esDuenio && !$esValidador) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        return response()->json($rendicion);
    }

    public function destroy($id)
    {
        try {
            $rendicion = Rendicion::with(['gastos.archivos'])->findOrFail($id);

            if ($rendicion->id_usuario != Auth::id()) {
                return response()->json(['message' => 'No autorizado'], 403);
            }

            if (!in_array($rendicion->estado, ['Borrador', 'Observada'])) {
                return response()->json(['message' => 'No se puede eliminar una rendición en proceso o aprobada'], 400);
            }

            DB::beginTransaction();

            // Borrar Archivos Físicos
            foreach ($rendicion->gastos as $gasto) {
                foreach ($gasto->archivos as $archivo) {
                    if (Storage::disk('nas_rendiciones')->exists($archivo->ruta_relativa)) {
                        Storage::disk('nas_rendiciones')->delete($archivo->ruta_relativa);
                    }
                }
            }

            $nombreCarpeta = str_pad($rendicion->id_rendicion, 3, '0', STR_PAD_LEFT);
            if (Storage::disk('nas_rendiciones')->exists($nombreCarpeta)) {
                Storage::disk('nas_rendiciones')->deleteDirectory($nombreCarpeta);
            }

            $rendicion->gastos()->delete();
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
                        ->withSum('gastos', 'monto') 
                        ->orderBy('fecha', 'asc') 
                        ->get();

        return response()->json($rendiciones);
    }

    public function historialGlobal()
    {
        $rendiciones = Rendicion::with(['usuario', 'gastos'])
                        ->orderByDesc('id_rendicion')
                        ->get();

        return response()->json($rendiciones);
    }

    /**
     * PROCESAR VALIDACIÓN (ADMIN)
     * Ahora notifica al usuario el resultado.
     */
    public function procesarValidacion(Request $request, $idRendicion)
    {
        $request->validate([
            'evaluaciones' => 'required|array', 
        ]);

        $rendicion = Rendicion::findOrFail($idRendicion);
        $evaluaciones = $request->evaluaciones;
        $hayRechazados = false;

        DB::beginTransaction();
        try {
            foreach ($evaluaciones as $eval) {
                $gasto = Gasto::find($eval['id_gasto']);
                
                if ($gasto) {
                    $gasto->estado_gasto = $eval['estado'];
                    
                    if (isset($eval['comentario'])) {
                        $gasto->comentario_validador = $eval['comentario'];
                    } else {
                        $gasto->comentario_validador = null; 
                    }

                    $gasto->id_validador = Auth::id();
                    $gasto->save();

                    if ($eval['estado'] === 'Rechazado') {
                        $hayRechazados = true;
                    }
                }
            }

            if ($hayRechazados) {
                $rendicion->estado = 'Observada';
            } else {
                $rendicion->estado = 'Aprobada'; 
            }
            
            $rendicion->save();
            DB::commit();

            // --- NOTIFICAR AL DUEÑO DE LA RENDICIÓN ---
            try {
                $titulo = $hayRechazados ? "Rendición Observada ⚠️" : "Rendición Aprobada ✅";
                $mensaje = $hayRechazados 
                    ? "Tu rendición #{$rendicion->id_rendicion} tiene gastos rechazados. Por favor revísala en la App." 
                    : "¡Felicidades! Tu rendición #{$rendicion->id_rendicion} ha sido aprobada y está lista para pago.";

                OneSignalService::enviar(
                    [$rendicion->id_usuario], // ID del dueño
                    $titulo,
                    $mensaje,
                    [
                        'id_rendicion' => $rendicion->id_rendicion, 
                        'tipo' => 'validacion_finalizada' // Esto te sirve para redirigir en la app si quieres
                    ]
                );
            } catch (\Exception $e) {
                \Log::error("Error notificando validación: " . $e->getMessage());
            }
            // ------------------------------------------

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
     * PAGAR RENDICIÓN
     */
    public function pagar(Request $request, $id)
    {
        $request->validate([
            'comprobante' => 'required|file|mimes:jpg,jpeg,png,pdf|max:10240',
        ]);

        try {
            DB::beginTransaction();

            $rendicion = Rendicion::withSum('gastos', 'monto')->findOrFail($id);

            if ($request->hasFile('comprobante')) {
                $file = $request->file('comprobante');
                $extension = $file->getClientOriginalExtension();
                $pesoKb = round($file->getSize() / 1024, 2);

                $carpetaRendicion = str_pad($rendicion->id_rendicion, 3, '0', STR_PAD_LEFT);
                $pathDestino = $carpetaRendicion . '/pago'; 
                $nombreFisico = 'PAGO_' . time() . '.' . $extension;

                $file->storeAs($pathDestino, $nombreFisico, 'nas_rendiciones');
                $rutaRelativa = $pathDestino . '/' . $nombreFisico;

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

                $rendicion->estado = 'Pagada';
                $rendicion->save();

                DB::commit();

                // --- NOTIFICAR PAGO ---
                try {
                    OneSignalService::enviar(
                        [$rendicion->id_usuario], 
                        "¡Rendición Pagada! 💰", 
                        "Tu rendición #{$rendicion->id_rendicion} ha sido pagada. Puedes ver el comprobante en la App.", 
                        [
                            'id_rendicion' => $rendicion->id_rendicion, 
                            'tipo' => 'pago_realizado'
                        ]
                    );
                } catch (\Exception $e) {
                    \Log::error("Error enviando notificación OneSignal al pagar: " . $e->getMessage());
                }

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
            
            if (isset($pathDestino) && isset($nombreFisico)) {
                Storage::disk('nas_rendiciones')->delete($pathDestino . '/' . $nombreFisico);
            }
            
            return response()->json(['message' => 'Error al pagar: ' . $e->getMessage()], 500);
        }
    }

    public function contarPendientes()
    {
        $cantidad = Rendicion::whereIn('estado', ['Pendiente de Validación', 'Aprobada'])->count();
        return response()->json(['cantidad' => $cantidad]);
    }
}