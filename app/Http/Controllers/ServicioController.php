<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Servicio;
use App\Models\Cliente;
use App\Models\AreaEmpresa;
// Nota: OcCliente y HasGuia ya no se usan directamente aquí para agregar, 
// pero los dejamos por si acaso o limpieza futura.

class ServicioController extends Controller
{
    // 1. CREAR SERVICIO (Se mantiene igual, solo ajustamos imports si fuera necesario)
    public function store(Request $request)
    {
        $request->validate([
            'id_cliente'      => 'required|exists:cliente,id_cliente',
            'id_area'         => 'required|exists:areas_empresa,id_area', 
            'nombre_servicio' => 'required|string|max:255',
        ]);

        try {
            // Generación de Centro de Costo (XX-Y-ZZZ)
            $cliente = Cliente::findOrFail($request->id_cliente);
            $xx = $cliente->cod_cliente ?? "00";
            
            $area = AreaEmpresa::findOrFail($request->id_area);
            $y = $area->codigo_area; 
            
            $ultimo = Servicio::where('id_cliente', $request->id_cliente)->max('correlativo');
            $nuevo = $ultimo ? $ultimo + 1 : 1;
            $zzz = str_pad($nuevo, 3, "0", STR_PAD_LEFT);
            $centroCosto = "$xx-$y-$zzz";

            $servicio = Servicio::create([
                'nombre_servicio' => $request->nombre_servicio,
                'id_cliente'      => $request->id_cliente,
                'id_area'         => $request->id_area,
                'correlativo'     => $nuevo,
                'centro_costo'    => $centroCosto,
                'estado_servicio' => 'Activo',     
                'facturacion'     => 'No facturado', 
            ]);

            return response()->json([
                'success' => true, 
                'message' => 'Servicio creado. CC: ' . $centroCosto,
                'data' => $servicio
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // 2. MODIFICAR INFORMACIÓN (Se mantiene igual)
    public function updateInfo(Request $request, $id)
    {
        $servicio = Servicio::findOrFail($id);

        $request->validate([
            'fecha_inicio' => 'nullable|date',
            'facturacion'  => 'nullable|string',
        ]);

        $servicio->update([
            'fecha_inicio' => $request->fecha_inicio,
            'facturacion'  => $request->facturacion ?? $servicio->facturacion,
        ]);

        return response()->json(['success' => true, 'message' => 'Información actualizada', 'data' => $servicio]);
    }

    // 3. FINALIZAR SERVICIO (Se mantiene igual)
    public function finalizar(Request $request, $id)
    {
        $servicio = Servicio::findOrFail($id);

        $request->validate([
            'fecha_termino' => 'required|date',
        ]);

        $servicio->update([
            'fecha_termino'   => $request->fecha_termino,
            'estado_servicio' => 'Finalizado',
        ]);

        return response()->json(['success' => true, 'message' => 'Servicio finalizado exitosamente', 'data' => $servicio]);
    }

    // 4. REACTIVAR SERVICIO (Se mantiene igual)
    public function reactivar($id)
    {
        $servicio = Servicio::findOrFail($id);
        
        $servicio->update([
            'estado_servicio' => 'Activo',
            'fecha_termino'   => null 
        ]);

        return response()->json([
            'success' => true, 
            'message' => 'Servicio reactivado exitosamente', 
            'data' => $servicio
        ]);
    }
    
    // 5. LISTAR POR CLIENTE (CORREGIDO)
    public function byCliente($idCliente)
    {
        // CAMBIOS IMPORTANTES AQUÍ:
        // 1. Usamos 'ocs' en lugar de 'ordenesCompra' (coherencia con modelo y frontend)
        // 2. Cargamos 'ocs.guias' para traer el árbol completo en una sola consulta
        // 3. Mantenemos 'guias' (que ahora usa hasManyThrough en el modelo) por si acaso las necesitas planas
        
        $servicios = Servicio::with(['area', 'ocs.guias', 'guias']) 
                             ->where('id_cliente', $idCliente)
                             ->orderBy('id_servicio', 'desc')
                             ->get();
                             
        return response()->json($servicios);
    }

    // 6. ACTUALIZAR SOLO NOMBRE DEL SERVICIO
    public function updateNombre(Request $request, $id)
    {
        $servicio = Servicio::findOrFail($id);

        $request->validate([
            'nombre_servicio' => 'required|string|max:255',
        ]);

        try {
            $servicio->update([
                'nombre_servicio' => $request->nombre_servicio,
            ]);

            return response()->json([
                'success' => true, 
                'message' => 'Nombre del servicio actualizado', 
                'data' => $servicio
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error al actualizar: ' . $e->getMessage()
            ], 500);
        }
    }
}