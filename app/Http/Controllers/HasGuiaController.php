<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use App\Models\HasGuia;
use App\Models\HasGuiaArchivo;
use App\Models\OcCliente;

class HasGuiaController extends Controller
{
    // 1. Obtener todas las HAS de una OC específica
    public function indexByOc($idOc)
    {
        $guias = HasGuia::where('id_oc_cliente', $idOc)
                    ->with('archivos') 
                    ->get();
        
        return response()->json($guias);
    }

    // 2. Crear una HAS y subir archivo (Transacción)
    public function store(Request $request, $idOc)
    {
        // Validación
        $request->validate([
            'cod_has_guia' => 'required|string|max:255',
            'archivo' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:10240', // 10MB Máx
        ]);

        // Verificar que la OC existe
        if (!OcCliente::where('id_oc_cliente', $idOc)->exists()) {
            return response()->json(['message' => 'OC no encontrada'], 404);
        }

        DB::beginTransaction();
        try {
            // A. Crear la Guía en BD
            $has = new HasGuia();
            $has->id_oc_cliente = $idOc;
            $has->cod_has_guia = $request->cod_has_guia;
            $has->save();

            // B. Procesar Archivo si viene uno
            if ($request->hasFile('archivo')) {
                $file = $request->file('archivo');

                // Generar nombres únicos
                $nombreOriginal = $file->getClientOriginalName();
                $extension = $file->getClientOriginalExtension();
                $nombreFisico = time() . '_' . uniqid() . '.' . $extension;
                
                // Definir carpeta: has/ID_OC/ID_HAS/
                $rutaRelativaCarpeta = 'has/' . $idOc . '/' . $has->id_has_guia;
                
                // Guardar físicamente en disco 'public'
                $file->storeAs($rutaRelativaCarpeta, $nombreFisico, 'public');

                // Guardar registro en BD
                $archivoModel = new HasGuiaArchivo();
                $archivoModel->id_has_guia = $has->id_has_guia;
                $archivoModel->nombre_original = $nombreOriginal;
                $archivoModel->nombre_fisico = $nombreFisico;
                $archivoModel->ruta_relativa = $rutaRelativaCarpeta . '/' . $nombreFisico;
                $archivoModel->extension = $extension;
                $archivoModel->peso_kb = round($file->getSize() / 1024);
                $archivoModel->save();
            }

            DB::commit();
            
            // Devolver respuesta con los archivos cargados
            $has->load('archivos');
            return response()->json([
                'success' => true, 
                'message' => 'HAS creada correctamente',
                'data' => $has
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 3. Ver Archivo (Túnel para ver imagen privada/publica)
    public function verArchivo($idArchivo)
    {
        $archivo = HasGuiaArchivo::find($idArchivo);
        if (!$archivo) return response()->json(['message' => 'Archivo no encontrado'], 404);

        // Verifica si existe en el disco
        if (!Storage::disk('public')->exists($archivo->ruta_relativa)) {
            return response()->json(['message' => 'Archivo físico no encontrado'], 404);
        }

        // Devuelve el archivo al navegador/app
        return response()->file(storage_path('app/public/' . $archivo->ruta_relativa));
    }

    // 4. Editar HAS (Reemplaza archivo si se sube uno nuevo)
    public function update(Request $request, $id)
    {
        $request->validate([
            'cod_has_guia' => 'required|string|max:255',
            'archivo' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:10240',
        ]);

        $has = HasGuia::find($id);
        if (!$has) return response()->json(['message' => 'HAS no encontrada'], 404);

        DB::beginTransaction();
        try {
            // Actualizar código
            $has->cod_has_guia = $request->cod_has_guia;
            $has->save();

            // Si hay archivo nuevo, reemplazar
            if ($request->hasFile('archivo')) {
                // A. Borrar archivo viejo
                $archivoAntiguo = HasGuiaArchivo::where('id_has_guia', $has->id_has_guia)->first();
                if ($archivoAntiguo) {
                    if (Storage::disk('public')->exists($archivoAntiguo->ruta_relativa)) {
                        Storage::disk('public')->delete($archivoAntiguo->ruta_relativa);
                    }
                    $archivoAntiguo->delete();
                }

                // B. Subir nuevo
                $file = $request->file('archivo');
                $nombreOriginal = $file->getClientOriginalName();
                $extension = $file->getClientOriginalExtension();
                $nombreFisico = time() . '_' . uniqid() . '.' . $extension;
                $rutaRelativaCarpeta = 'has/' . $has->id_oc_cliente . '/' . $has->id_has_guia;
                
                $file->storeAs($rutaRelativaCarpeta, $nombreFisico, 'public');

                $archivoModel = new HasGuiaArchivo();
                $archivoModel->id_has_guia = $has->id_has_guia;
                $archivoModel->nombre_original = $nombreOriginal;
                $archivoModel->nombre_fisico = $nombreFisico;
                $archivoModel->ruta_relativa = $rutaRelativaCarpeta . '/' . $nombreFisico;
                $archivoModel->extension = $extension;
                $archivoModel->peso_kb = round($file->getSize() / 1024);
                $archivoModel->save();
            }

            DB::commit();
            $has->load('archivos');
            return response()->json(['success' => true, 'message' => 'HAS actualizada', 'data' => $has]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // 5. Eliminar HAS y sus archivos físicos
    public function destroy($id)
    {
        $has = HasGuia::with('archivos')->find($id);
        if (!$has) return response()->json(['message' => 'HAS no encontrada'], 404);
        
        // Borrar físicos del disco
        foreach ($has->archivos as $archivo) {
            if (Storage::disk('public')->exists($archivo->ruta_relativa)) {
                Storage::disk('public')->delete($archivo->ruta_relativa);
            }
        }

        // Borrar de BD (Cascade se encarga de los hijos, pero el delete del padre es necesario)
        $has->delete();
        
        return response()->json(['success' => true, 'message' => 'HAS eliminada correctamente']);
    }
}