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
        // CORREGIDO: 'contactos' en plural
        $proveedores = Proveedor::with('contactos')->orderBy('nombre_proveedor', 'asc')->get();
       
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
        // 👇 ACTUALIZADO: Se agregaron las validaciones para el contenido del arreglo 'contactos'
        $request->validate([
            'nombre_proveedor'              => 'required|string|max:100',
            'contactos'                     => 'nullable|array', 
            'contactos.*.nombre_contacto'   => 'required|string|max:100',
            'contactos.*.cargo'             => 'nullable|string|max:100', // <-- NUEVO CAMPO AGREGADO
            'contactos.*.telefono_contacto' => 'nullable|string|max:20',
            'contactos.*.correo_contacto'   => 'nullable|string|max:100',
        ]);


        try {
            $proveedor = Proveedor::create([
                'nombre_proveedor' => $request->nombre_proveedor
            ]);


            // CORREGIDO: Todo en plural ('contactos')
            if ($request->has('contactos') && is_array($request->contactos)) {
                $proveedor->contactos()->createMany($request->contactos);
            }


            $proveedor->load('contactos');


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
        // CORREGIDO: 'contactos' en plural
        $proveedor = Proveedor::with('contactos')->find($id);


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


        // 👇 ACTUALIZADO: Igual que en store, se agregaron las validaciones internas
        $request->validate([
            'nombre_proveedor'              => 'required|string|max:100',
            'contactos'                     => 'nullable|array', 
            'contactos.*.nombre_contacto'   => 'required|string|max:100',
            'contactos.*.cargo'             => 'nullable|string|max:100', // <-- NUEVO CAMPO AGREGADO
            'contactos.*.telefono_contacto' => 'nullable|string|max:20',
            'contactos.*.correo_contacto'   => 'nullable|string|max:100',
        ]);


        try {
            $proveedor->update([
                'nombre_proveedor' => $request->nombre_proveedor
            ]);


            // CORREGIDO: Todo en plural ('contactos')
            if ($request->has('contactos') && is_array($request->contactos)) {
                $proveedor->contactos()->delete(); // Borra los antiguos
                $proveedor->contactos()->createMany($request->contactos); // Crea los nuevos
            }


            // CORREGIDO: 'contactos' en plural
            $proveedor->load('contactos');


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


