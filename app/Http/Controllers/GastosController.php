<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Models\Gasto;
use App\Models\GastoArchivo;
use App\Models\Rendicion;

class GastoController extends Controller
{
    /**
     * PASO 1: Crear el Gasto (Solo datos, sin archivo)
     */
    public function store(Request $request)
    {
        // 1. Validaciones (Ya no pedimos imagen aquí)
        $request->validate([
            'id_rendicion'   => 'required|exists:rendicion,id_rendicion',
            'fecha'          => 'required|date',
            'monto'          => 'required|integer|min:1',
            'num_documento'  => 'nullable|string|max:255',
            
            // Campos de texto directo (según tu última indicación)
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
                // Sin proveedor ni categoria_otro, como pediste
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
     */
    public function subirArchivo(Request $request)
    {
        // 1. Validar que venga el archivo y el ID del gasto
        $request->validate([
            'id_gasto' => 'required|exists:gasto,id_gasto',
            'archivo'  => 'required|file|mimes:jpg,jpeg,png,pdf|max:10240', // 10MB
        ]);

        $gasto = Gasto::with('rendicion')->findOrFail($request->id_gasto);

        // 2. Validar Seguridad (Mismas reglas: dueño y estado borrador)
        if ($gasto->rendicion->id_usuario != Auth::id()) {
            return response()->json(['message' => 'No autorizado'], 403);
        }
        if (!in_array($gasto->rendicion->estado, ['Borrador', 'Observada'])) {
            return response()->json(['message' => 'No se pueden subir archivos a una rendición enviada'], 403);
        }

        try {
            $file = $request->file('archivo');

            // Metadatos para tu tabla gasto_archivo
            $nombreOriginal = $file->getClientOriginalName();
            $extension = $file->getClientOriginalExtension();
            $pesoKb = round($file->getSize() / 1024, 2);

            // Guardar físico: evidencias/rendicion_X/gasto_Y/nombre_unico.ext
            $nombreFisico = time() . '_' . uniqid() . '.' . $extension;
            $carpeta = 'evidencias/rendicion_' . $gasto->id_rendicion . '/gasto_' . $gasto->id_gasto;
            $rutaRelativa = $carpeta . '/' . $nombreFisico;

            $file->storeAs($carpeta, $nombreFisico, 'public');

            // 3. Crear registro en tabla GASTO_ARCHIVO
            $archivo = GastoArchivo::create([
                'id_gasto'        => $gasto->id_gasto,
                'nombre_original' => $nombreOriginal,
                'nombre_fisico'   => $nombreFisico,
                'ruta_relativa'   => $rutaRelativa,
                'extension'       => $extension,
                'peso_kb'         => $pesoKb,
                // 'id_validador' queda null
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Archivo adjuntado correctamente',
                'data'    => $archivo
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error al subir archivo: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Eliminar Gasto
     */
    public function destroy($id)
    {
        $gasto = Gasto::with(['rendicion', 'archivos'])->findOrFail($id);

        if ($gasto->rendicion->id_usuario != Auth::id()) return response()->json(['message' => 'No autorizado'], 403);
        if (!in_array($gasto->rendicion->estado, ['Borrador', 'Observada'])) return response()->json(['message' => 'Bloqueado'], 403);

        // Borrar archivos físicos
        foreach($gasto->archivos as $archivo) {
            if (Storage::disk('public')->exists($archivo->ruta_relativa)) {
                Storage::disk('public')->delete($archivo->ruta_relativa);
            }
        }
        $gasto->delete(); // Borra en cascada los registros de gasto_archivo

        return response()->json(['success' => true, 'message' => 'Gasto eliminado']);
    }
}