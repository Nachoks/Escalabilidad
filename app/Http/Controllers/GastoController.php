<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Models\Gasto;
use App\Models\GastoArchivo;
use App\Models\Rendicion;
use Illuminate\Support\Facades\DB;

class GastoController extends Controller
{
    /**
     * PASO 1: Crear el Gasto (Solo datos, sin archivo)
     */
    public function store(Request $request)
    {
        // 1. Validaciones
        $request->validate([
            'id_rendicion'   => 'required|exists:rendicion,id_rendicion',
            'fecha'          => 'required|date',
            'monto'          => 'required|integer|min:1',
            'num_documento'  => 'nullable|string|max:255',
            'tipo_documento' => 'required|string|max:255', 
            'detalle'        => 'required|string|max:255', 
        ]);

        // 2. Validar Seguridad y Estado
        $rendicion = Rendicion::findOrFail($request->id_rendicion);
        
        if ($rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        if (!in_array($rendicion->estado, ['Borrador', 'Observada'])) {
            return response()->json(['message' => 'Rendición bloqueada'], 403);
        }

        try {
            // 3. Crear el registro en tabla GASTO
            $gasto = Gasto::create([
                'id_rendicion'   => $request->id_rendicion,
                'fecha'          => $request->fecha,
                'monto'          => $request->monto,
                'num_documento'  => $request->num_documento,
                'tipo_documento' => $request->tipo_documento,
                'detalle'        => $request->detalle,
                'estado_gasto'   => 'Pendiente',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Gasto creado. Ahora puedes adjuntar archivos.',
                'data'    => $gasto
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * PASO 2: Subir Archivo a un Gasto existente
     * Lógica NAS: Carpeta "001/gastos" -> Archivo "005-25990.jpg"
     */
    public function subirArchivo(Request $request)
    {
        // 1. Validar
        $request->validate([
            'id_gasto' => 'required|exists:gasto,id_gasto',
            'archivo'  => 'required|file|mimes:jpg,jpeg,png,pdf|max:10240', // 10MB
        ]);

        $gasto = Gasto::with('rendicion')->findOrFail($request->id_gasto);

        // 2. Validar Seguridad
        if ($gasto->rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }
        if (!in_array($gasto->rendicion->estado, ['Borrador', 'Observada'])) {
            return response()->json(['message' => 'No se pueden subir archivos a una rendición enviada'], 403);
        }

        try {
            $file = $request->file('archivo');
            $extension = $file->getClientOriginalExtension();
            $pesoKb = round($file->getSize() / 1024, 2);

            // --- LÓGICA DE NOMBRES Y RUTAS ---

            // A. Nombre Carpeta Rendición: ID con padding de 3 ceros (ej: 1 -> "001")
            $carpetaRendicion = str_pad($gasto->rendicion->id_rendicion, 3, '0', STR_PAD_LEFT);

            // B. Ruta destino (dentro del disco NAS)
            $pathDestino = $carpetaRendicion . '/gastos';

            // C. Nombre Archivo: ID_GASTO(pad 3) - MONTO . EXT
            // Ej: Gasto 5, Monto 5000 -> "005-5000.jpg"
            $idGastoPad = str_pad($gasto->id_gasto, 3, '0', STR_PAD_LEFT);
            $nombreFisico = $idGastoPad . '-' . $gasto->monto . '.' . $extension;

            // D. Guardar en el disco 'nas_rendiciones'
            $file->storeAs($pathDestino, $nombreFisico, 'nas_rendiciones');

            // E. Ruta relativa para la BD
            $rutaRelativa = $pathDestino . '/' . $nombreFisico;

            // 3. Crear registro en tabla GASTO_ARCHIVO
            $archivo = GastoArchivo::create([
                'id_gasto'        => $gasto->id_gasto,
                'nombre_original' => $file->getClientOriginalName(),
                'nombre_fisico'   => $nombreFisico,
                'ruta_relativa'   => $rutaRelativa,
                'extension'       => $extension,
                'peso_kb'         => $pesoKb,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Archivo adjuntado correctamente en NAS',
                'data'    => $archivo
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error al subir archivo: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Eliminar Gasto (y su archivo del NAS)
     */
    public function destroy($id)
    {
        $gasto = Gasto::with(['rendicion', 'archivos'])->findOrFail($id);

        // 1. Seguridad: Solo el dueño y en estado Borrador/Observada
        if ($gasto->rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }
        if (!in_array($gasto->rendicion->estado, ['Borrador', 'Observada'])) {
            return response()->json(['message' => 'No se puede eliminar gastos de una rendición enviada'], 403);
        }

        try {
            DB::beginTransaction();

            // 2. Borrar Archivos Físicos del NAS (Si existen)
            foreach ($gasto->archivos as $archivo) {
                if (Storage::disk('nas_rendiciones')->exists($archivo->ruta_relativa)) {
                    Storage::disk('nas_rendiciones')->delete($archivo->ruta_relativa);
                }
            }

            // 3. Borrar el Gasto (La BD se encarga de borrar los hijos 'gasto_archivo' si tienes ON DELETE CASCADE, sino Laravel lo hace)
            $gasto->delete();

            DB::commit();

            return response()->json(['success' => true, 'message' => 'Gasto eliminado']);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * ELIMINAR SOLO EL ARCHIVO (EVIDENCIA)
     * Mantiene el gasto, pero borra la foto del NAS y de la BD.
     */
    public function eliminarArchivo($idGasto)
    {
        $gasto = Gasto::with(['rendicion', 'archivos'])->findOrFail($idGasto);

        // 1. Validaciones de Seguridad
        if ($gasto->rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }
        if (!in_array($gasto->rendicion->estado, ['Borrador', 'Observada'])) {
            return response()->json(['message' => 'No se pueden eliminar archivos de una rendición enviada'], 403);
        }

        try {
            // 2. Borrar físicamente y de la BD
            foreach($gasto->archivos as $archivo) {
                // Borrar del NAS
                if (Storage::disk('nas_rendiciones')->exists($archivo->ruta_relativa)) {
                    Storage::disk('nas_rendiciones')->delete($archivo->ruta_relativa);
                }
                // Borrar registro de la tabla gasto_archivo
                $archivo->delete();
            }

            return response()->json(['success' => true, 'message' => 'Evidencia eliminada correctamente']);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }
}