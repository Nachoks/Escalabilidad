<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Servicio;
use App\Models\Cliente;
use App\Models\AreaEmpresa;
use App\Models\OcCliente;
use App\Models\HasGuia;

class ServicioController extends Controller
{
    // 1. CREAR SERVICIO (Versión Simple - Solo datos básicos)
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
                'estado_servicio' => 'Activo',     // Nace activo
                'facturacion'     => 'No facturado', // Nace sin facturar
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

    // 2. MODIFICAR INFORMACIÓN (Botón: "Modificar fecha inicio y facturación")
    public function updateInfo(Request $request, $id)
    {
        $servicio = Servicio::findOrFail($id);

        $request->validate([
            'fecha_inicio' => 'nullable|date',
            'facturacion'  => 'nullable|string|in:Totalmente facturado,Parcialmente facturado,No facturado',
        ]);

        $servicio->update([
            'fecha_inicio' => $request->fecha_inicio, // Puede ser null si se borra
            'facturacion'  => $request->facturacion ?? $servicio->facturacion,
        ]);

        return response()->json(['success' => true, 'message' => 'Información actualizada', 'data' => $servicio]);
    }

    // 3. FINALIZAR SERVICIO (Botón: "Finalizar Servicio")
    public function finalizar(Request $request, $id)
    {
        $servicio = Servicio::findOrFail($id);

        $request->validate([
            'fecha_termino' => 'required|date', // Obligatorio para finalizar
        ]);

        $servicio->update([
            'fecha_termino'   => $request->fecha_termino,
            'estado_servicio' => 'Finalizado', // Cambia el estado para que se vea diferente en la lista
        ]);

        return response()->json(['success' => true, 'message' => 'Servicio finalizado exitosamente', 'data' => $servicio]);
    }

    // 4. AGREGAR UNA OC (Botón: "Agregar OC")
    public function agregarOc(Request $request, $id)
    {
        $request->validate(['cod_oc_cliente' => 'required|string|max:255']);

        $oc = OcCliente::create([
            'id_servicio'    => $id,
            'cod_oc_cliente' => $request->cod_oc_cliente
        ]);

        return response()->json(['success' => true, 'message' => 'OC agregada', 'data' => $oc]);
    }

    // 5. AGREGAR UNA HAS (Botón: "Agregar HAS")
    public function agregarHas(Request $request, $id)
    {
        $request->validate(['cod_has_guia' => 'required|string|max:255']);

        $has = HasGuia::create([
            'id_servicio'  => $id,
            'cod_has_guia' => $request->cod_has_guia
        ]);

        return response()->json(['success' => true, 'message' => 'HAS agregada', 'data' => $has]);
    }

    // 6. REACTIVAR SERVICIO (Nuevo Método)
    public function reactivar($id)
    {
        $servicio = Servicio::findOrFail($id);
        
        $servicio->update([
            'estado_servicio' => 'Activo',
            'fecha_termino'   => null // Borramos la fecha de término
        ]);

        return response()->json([
            'success' => true, 
            'message' => 'Servicio reactivado exitosamente', 
            'data' => $servicio
        ]);
    }
    
    // LISTAR POR CLIENTE (Con todos los detalles para la vista)
    public function byCliente($idCliente)
    {
        $servicios = Servicio::with(['area', 'ordenesCompra', 'guias']) 
                             ->where('id_cliente', $idCliente)
                             ->orderBy('id_servicio', 'desc')
                             ->get();
        return response()->json($servicios);
    }
}