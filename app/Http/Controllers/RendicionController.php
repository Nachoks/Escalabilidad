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
     * 2. ACTUALIZAR BORRADOR (Opcional)
     * - Útil si el usuario se equivocó en el propósito o monto.
     * - YA NO EDITA LA FECHA.
     */
    public function update(Request $request, $id)
    {
        $rendicion = Rendicion::findOrFail($id);

        if ($rendicion->id_usuario != Auth::id()) return response()->json(['message' => 'No autorizado'], 403);
        if ($rendicion->estado != 'Borrador') return response()->json(['message' => 'Solo se editan borradores'], 403);

        $request->validate([
            'proposito'       => 'nullable|string|max:255',
            'monto_entregado' => 'nullable|integer',
        ]);

        $rendicion->update($request->only(['proposito', 'monto_entregado']));

        return response()->json(['success' => true, 'message' => 'Rendición actualizada', 'data' => $rendicion]);
    }

    /**
     * 3. ENVIAR A REVISIÓN
     * - Aquí se asigna la FECHA REAL (now).
     * - Cambia estado a 'Pendiente de Validación'.
     */
    public function enviar($id)
    {
        $rendicion = Rendicion::with('gastos')->findOrFail($id);

        if ($rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        // Validación: Debe tener gastos
        if ($rendicion->gastos()->count() == 0) {
            return response()->json(['message' => 'La rendición está vacía, agrega gastos antes de enviar.'], 400);
        }

        // Actualizamos Estado
        $rendicion->update([
            'estado' => 'Pendiente de Validación',
            // Opcional: Podrías actualizar la fecha de envío aquí si quisieras
            // 'fecha' => now() 
        ]);

        return response()->json(['success' => true, 'message' => 'Rendición enviada a revisión']);
    }

    // --- Métodos de lectura (sin cambios) ---
    public function misRendiciones()
    {
        $rendiciones = Rendicion::where('id_usuario', Auth::id())
                        ->with([
                            'servicio:id_servicio,nombre_servicio,centro_costo', 
                            'gastos' // <--- ESTO ES LO QUE FALTABA
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
        $request->validate([
            'comprobante' => 'required|file|mimes:jpg,jpeg,png,pdf|max:5120', // Máx 5MB
        ]);

        DB::beginTransaction();
        try {
            $rendicion = Rendicion::with('gastos')->findOrFail($id);
            
            // 1. Subir el archivo
            $file = $request->file('comprobante');
            $nombreFisico = time() . '_' . $file->getClientOriginalName();
            $ruta = $file->storeAs('public/comprobantes', $nombreFisico); // storage/app/public/comprobantes

            // 2. Crear el Registro de Pago
            $registro = new Registro();
            $registro->id_rendicion = $rendicion->id_rendicion;
            $registro->id_usuario_pagador = Auth::id(); // Quién pagó (el admin actual)
            $registro->fecha_pago = now();
            $registro->monto_pagado = $rendicion->total_gastado; // Asumimos pago total
            
            // Datos del archivo
            $registro->nombre_original = $file->getClientOriginalName();
            $registro->nombre_fisico = $nombreFisico;
            $registro->ruta_relativa = 'comprobantes/' . $nombreFisico;
            $registro->extension = $file->getClientOriginalExtension();
            $registro->peso_kb = round($file->getSize() / 1024, 2);
            
            $registro->save();

            // 3. Cambiar estado de la Rendición
            $rendicion->estado = 'Pagada';
            $rendicion->save();

            DB::commit();

            return response()->json([
                'success' => true, 
                'message' => 'Pago registrado correctamente'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Error al pagar: ' . $e->getMessage()], 500);
        }
    }
}