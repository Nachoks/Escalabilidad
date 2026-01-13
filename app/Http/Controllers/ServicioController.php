<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Servicio;
use App\Models\Cliente;
use App\Models\AreaEmpresa; // <--- Importamos el modelo correcto

class ServicioController extends Controller
{
    public function store(Request $request)
    {
        // 1. VALIDAR
        $request->validate([
            'id_cliente'      => 'required|exists:cliente,id_cliente',
            'id_area'         => 'required|exists:areas_empresa,id_area', 
            'nombre_servicio' => 'required|string|max:255',
            'fecha_inicio'    => 'nullable|date',
            'fecha_termino'   => 'nullable|date',
        ]);

        try {
            // --- PARTE 1: CÓDIGO CLIENTE (XX) ---
            $cliente = Cliente::findOrFail($request->id_cliente);
            $xx = $cliente->cod_cliente ?? "00";

            // --- PARTE 2: CÓDIGO ÁREA (Y) ---
            $area = AreaEmpresa::findOrFail($request->id_area);
            $y = $area->codigo_area; 

            // --- PARTE 3: CORRELATIVO (ZZZ) - ¡CORREGIDO! ---
            
            // Buscamos el último correlativo SOLO DE ESTE CLIENTE
            $ultimo = Servicio::where('id_cliente', $request->id_cliente)
                              ->max('correlativo');
                              
            // Si el cliente no tiene servicios ($ultimo es null), empezamos en 1.
            // Si tiene (ej: 5), sumamos 1 -> 6.
            $nuevo = $ultimo ? $ultimo + 1 : 1;
            
            $zzz = str_pad($nuevo, 3, "0", STR_PAD_LEFT);

            // --- RESULTADO (XX-Y-ZZZ) ---
            $centroCosto = "$xx-$y-$zzz";

            // 2. GUARDAR SERVICIO
            $servicio = Servicio::create([
                'nombre_servicio' => $request->nombre_servicio,
                'id_cliente'      => $request->id_cliente,
                'id_area'         => $request->id_area,
                'correlativo'     => $nuevo,
                'centro_costo'    => $centroCosto,
                'fecha_inicio'    => $request->fecha_inicio,
                'fecha_termino'   => $request->fecha_termino,
                'estado_servicio' => 'Activo', 
            ]);

            return response()->json([
                'success' => true, 
                'message' => 'Servicio creado. CC: ' . $centroCosto,
                'data' => $servicio
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // Método para listar servicios de un cliente (Útil para el Frontend después)
    public function byCliente($idCliente)
    {
        $servicios = Servicio::with(['area']) // Traemos info del área también
                             ->where('id_cliente', $idCliente)
                             ->orderBy('id_servicio', 'desc')
                             ->get();
        return response()->json($servicios);
    }
}