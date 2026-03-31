<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Proveedor;

class ProveedorController extends Controller
{
    /**
     * 1. OBTENER TODOS LOS PROVEEDORES (Listado para administrar)
     */
    public function index()
    {
        // Traemos todos ordenados alfabéticamente
        $proveedores = Proveedor::orderBy('nombre_proveedor', 'asc')->get();
        
        return response()->json([
            'success' => true,
            'data'    => $proveedores
        ], 200);
    }

    /**
     * 2. CREAR UN NUEVO PROVEEDOR
     */
    public function store(Request $request)
    {
        $request->validate([
            'nombre_proveedor' => 'required|string|max:100',
            'nombre_contacto'  => 'nullable|string|max:100',
            'numero_contacto'  => 'nullable|string|max:50',
            'correo_contacto'  => 'nullable|email|max:100',
        ]);

        try {
            $proveedor = Proveedor::create($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Proveedor creado exitosamente.',
                'data'    => $proveedor
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error al crear proveedor: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 3. VER UN PROVEEDOR EN ESPECÍFICO
     */
    public function show($id)
    {
        $proveedor = Proveedor::find($id);

        if (!$proveedor) {
            return response()->json(['success' => false, 'message' => 'Proveedor no encontrado.'], 404);
        }

        return response()->json(['success' => true, 'data' => $proveedor], 200);
    }

    /**
     * 4. ACTUALIZAR UN PROVEEDOR
     */
    public function update(Request $request, $id)
    {
        $proveedor = Proveedor::find($id);

        if (!$proveedor) {
            return response()->json(['success' => false, 'message' => 'Proveedor no encontrado.'], 404);
        }

        $request->validate([
            'nombre_proveedor' => 'required|string|max:100',
            'nombre_contacto'  => 'nullable|string|max:100',
            'numero_contacto'  => 'nullable|string|max:50',
            'correo_contacto'  => 'nullable|email|max:100',
        ]);

        try {
            $proveedor->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Proveedor actualizado correctamente.',
                'data'    => $proveedor
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error al actualizar: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 5. ELIMINAR UN PROVEEDOR
     */
    public function destroy($id)
    {
        $proveedor = Proveedor::find($id);

        if (!$proveedor) {
            return response()->json(['success' => false, 'message' => 'Proveedor no encontrado.'], 404);
        }

        // VALIDACIÓN CLAVE: No podemos borrar un proveedor si tiene productos amarrados
        if ($proveedor->productos()->count() > 0) {
            return response()->json([
                'success' => false, 
                'message' => 'No puedes eliminar este proveedor porque tiene productos asociados en el catálogo.'
            ], 400);
        }

        try {
            $proveedor->delete();

            return response()->json([
                'success' => true,
                'message' => 'Proveedor eliminado correctamente.'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error al eliminar: ' . $e->getMessage()
            ], 500);
        }
    }
}


