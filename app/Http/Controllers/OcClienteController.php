<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\OcCliente;
use App\Models\Servicio;
use Illuminate\Support\Facades\Log; // Importante para debug

class OcClienteController extends Controller
{
    // Listar OCs de un servicio
    public function indexByServicio($id)
    {
        // Validamos que el servicio exista
        if (!Servicio::where('id_servicio', $id)->exists()) {
            return response()->json(['message' => 'Servicio no encontrado'], 404);
        }

        $ocs = OcCliente::where('id_servicio', $id)
                ->withCount('guias')
                ->get();
                
        return response()->json($ocs);
    }

    // Crear OC (Aquí suele estar el error)
    public function store(Request $request, $id)
    {
        // 1. Validar datos de entrada
        $request->validate([
            'cod_oc_cliente' => 'required|string|max:255',
        ]);

        try {
            // 2. Verificar que el servicio existe
            $servicio = Servicio::find($id);
            if (!$servicio) {
                return response()->json(['message' => 'El servicio ID: ' . $id . ' no existe.'], 404);
            }

            // 3. Crear la OC
            $oc = new OcCliente();
            $oc->id_servicio = $id;
            $oc->cod_oc_cliente = $request->cod_oc_cliente;
            $oc->save();

            return response()->json([
                'success' => true,
                'message' => 'OC creada correctamente',
                'data' => $oc
            ], 201);

        } catch (\Exception $e) {
            // Esto nos dirá si es error de SQL (tabla no existe) o de código
            return response()->json([
                'success' => false, 
                'message' => 'Error interno: ' . $e->getMessage()
            ], 500);
        }
    }

    // Editar OC
    public function update(Request $request, $id)
    {
        $request->validate(['cod_oc_cliente' => 'required|string|max:255']);
        
        $oc = OcCliente::find($id);
        if (!$oc) return response()->json(['message' => 'OC no encontrada'], 404);

        $oc->cod_oc_cliente = $request->cod_oc_cliente;
        $oc->save();

        return response()->json(['success' => true, 'message' => 'OC actualizada', 'data' => $oc]);
    }

    // Eliminar OC
    public function destroy($id)
    {
        $oc = OcCliente::find($id);
        if (!$oc) return response()->json(['message' => 'OC no encontrada'], 404);
        
        $oc->delete();
        return response()->json(['success' => true, 'message' => 'OC eliminada']);
    }
}