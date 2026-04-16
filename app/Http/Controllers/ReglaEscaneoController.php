<?php


namespace App\Http\Controllers;


use Illuminate\Http\Request;
use App\Models\ReglaEscaneo;


class ReglaEscaneoController extends Controller
{
    /**
     * 1. OBTENER TODAS LAS REGLAS
     */
    public function index()
    {
        // Traemos todas las reglas ordenadas alfabéticamente
        $reglas = ReglaEscaneo::orderBy('nombre_marca', 'asc')->get();
       
        return response()->json([
            'success' => true,
            'data'    => $reglas
        ], 200);
    }


    /**
     * 2. CREAR UNA NUEVA REGLA
     */
    public function store(Request $request)
    {
        $request->validate([
            'nombre_marca'      => 'required|string|max:100',
            'prefijo_codigo'    => 'nullable|string|max:50',
            'prefijo_serie'     => 'nullable|string|max:50',
            'separador_ignorar' => 'nullable|string|max:50',
        ]);


        try {
            $regla = ReglaEscaneo::create($request->all());


            return response()->json([
                'success' => true,
                'message' => 'Regla de escaneo creada exitosamente.',
                'data'    => $regla
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al crear la regla: ' . $e->getMessage()
            ], 500);
        }
    }


    /**
     * 3. VER UNA REGLA EN ESPECÍFICO
     */
    public function show($id)
    {
        $regla = ReglaEscaneo::find($id);


        if (!$regla) {
            return response()->json(['success' => false, 'message' => 'Regla no encontrada.'], 404);
        }


        return response()->json(['success' => true, 'data' => $regla], 200);
    }


    /**
     * 4. ACTUALIZAR UNA REGLA
     */
    public function update(Request $request, $id)
    {
        $regla = ReglaEscaneo::find($id);


        if (!$regla) {
            return response()->json(['success' => false, 'message' => 'Regla no encontrada.'], 404);
        }


        $request->validate([
            'nombre_marca'      => 'required|string|max:100',
            'prefijo_codigo'    => 'nullable|string|max:50',
            'prefijo_serie'     => 'nullable|string|max:50',
            'separador_ignorar' => 'nullable|string|max:50',
        ]);


        try {
            $regla->update($request->all());


            return response()->json([
                'success' => true,
                'message' => 'Regla de escaneo actualizada correctamente.',
                'data'    => $regla
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar: ' . $e->getMessage()
            ], 500);
        }
    }


    /**
     * 5. ELIMINAR UNA REGLA
     */
    public function destroy($id)
    {
        $regla = ReglaEscaneo::find($id);


        if (!$regla) {
            return response()->json(['success' => false, 'message' => 'Regla no encontrada.'], 404);
        }


        try {
            $regla->delete();


            return response()->json([
                'success' => true,
                'message' => 'Regla de escaneo eliminada correctamente.'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al eliminar: ' . $e->getMessage()
            ], 500);
        }
    }
}



