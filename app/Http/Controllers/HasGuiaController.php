<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Models\HasGuia;
use App\Models\HasGuiaArchivo;
use App\Models\OcCliente;

class HasGuiaController extends Controller
{
    // 1. LISTAR HAS POR OC
    public function indexByOc($idOc)
    {
        return response()->json(
            HasGuia::where('id_oc_cliente', $idOc)
                   ->with('archivos')
                   ->orderBy('id_has_guia', 'desc')
                   ->get()
        );
    }

    // 2. CREAR HAS (Solo texto + Validación de Unicidad)
    public function store(Request $request, $idOc)
    {
        // VALIDACIÓN: El código 'cod_has_guia' debe ser ÚNICO en la tabla 'has_guia'
        $request->validate([
            'cod_has_guia' => 'required|string|max:255|unique:has_guia,cod_has_guia'
        ], [
            'cod_has_guia.unique' => 'Ya existe una guía HAS con este código.'
        ]);

        if (!OcCliente::where('id_oc_cliente', $idOc)->exists()) {
            return response()->json(['message' => 'OC no encontrada'], 404);
        }

        try {
            $has = new HasGuia();
            $has->id_oc_cliente = $idOc;
            $has->cod_has_guia = $request->cod_has_guia;
            $has->save();

            return response()->json([
                'success' => true, 
                'message' => 'HAS creada', 
                'data' => $has->load('archivos')
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // 3. SUBIR IMAGEN (Nombre = CodigoHas.ext)
    public function subirArchivoHas(Request $request, $idHas)
    {
        $request->validate([
            'archivo' => 'required|file|mimes:jpg,jpeg,png,pdf|max:51200',
        ]);

        $has = HasGuia::find($idHas);
        if (!$has) return response()->json(['message' => 'HAS no encontrada'], 404);

        DB::beginTransaction();
        try {
            // Borrar archivo anterior si existe (para no dejar basura)
            $this->eliminarArchivoFisicoLogica($idHas);

            $has->load('oc.servicio.cliente');
            $oc = $has->oc;
            $servicio = $oc->servicio;
            $cliente = $servicio->cliente;

            // 1. Construir Ruta de Carpetas
            $folderCliente  = Str::slug($cliente->nombre_cliente, '_'); 
            $folderServicio = Str::slug($servicio->nombre_servicio, '_');
            $folderOc       = Str::slug($oc->cod_oc_cliente, '_');
            
            // Ruta: cliente/servicio/oc/
            $rutaRelativaCarpeta = "{$folderCliente}/{$folderServicio}/{$folderOc}";

            // 2. Preparar Nombre del Archivo
            $file = $request->file('archivo');
            $extension = $file->getClientOriginalExtension();
            
            // Nombre Físico: CODIGOHAS.ext (Ej: 123456.jpg)
            // Usamos Str::slug por seguridad (quita espacios y acentos), 
            // pero si el código es "123456", queda igual.
            $nombreFisico = Str::slug($has->cod_has_guia, '_') . '.' . $extension;

            // 3. Guardar en NAS
            // Resultado: .../cliente/servicio/oc/123456.jpg
            $pathGuardado = $file->storeAs($rutaRelativaCarpeta, $nombreFisico, 'nas_registros');

            if (!$pathGuardado) {
                throw new \Exception("No se pudo escribir en el NAS.");
            }

            // 4. Guardar BD
            $archivo = new HasGuiaArchivo();
            $archivo->id_has_guia     = $has->id_has_guia;
            $archivo->nombre_original = $file->getClientOriginalName();
            $archivo->nombre_fisico   = $nombreFisico;
            $archivo->ruta_relativa   = $pathGuardado;
            $archivo->extension       = $extension;
            $archivo->peso_kb         = round($file->getSize() / 1024);
            $archivo->save();

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Archivo guardado correctamente']);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 4. ELIMINAR SOLO LA IMAGEN
    public function eliminarArchivo($idHas)
    {
        try {
            $resultado = $this->eliminarArchivoFisicoLogica($idHas);
            
            if ($resultado) {
                return response()->json(['success' => true, 'message' => 'Imagen eliminada']);
            } else {
                return response()->json(['success' => false, 'message' => 'No había imagen para eliminar']);
            }
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // 5. ELIMINAR HAS COMPLETA
    public function destroy($id)
    {
        $has = HasGuia::find($id);
        if (!$has) return response()->json(['message' => 'HAS no encontrada'], 404);

        try {
            $this->eliminarArchivoFisicoLogica($id);
            $has->delete();
            return response()->json(['success' => true, 'message' => 'HAS eliminada correctamente']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // Helper privado
    private function eliminarArchivoFisicoLogica($idHas)
    {
        $archivo = HasGuiaArchivo::where('id_has_guia', $idHas)->first();
        
        if ($archivo) {
            if (Storage::disk('nas_registros')->exists($archivo->ruta_relativa)) {
                Storage::disk('nas_registros')->delete($archivo->ruta_relativa);
            }
            $archivo->delete();
            return true;
        }
        return false;
    }
}