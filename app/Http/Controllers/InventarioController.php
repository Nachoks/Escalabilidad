<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use App\Models\Producto;
use App\Models\InventarioProducto;
use App\Models\InventarioEntrada;
use App\Models\InventarioSalida;

class InventarioController extends Controller
{
    /**
     * 1. REGISTRAR ENTRADA (Llega un equipo nuevo del proveedor)
     */
    public function registrarEntrada(Request $request)
    {
        // 1. Validamos que el código de producto enviado por Flutter exista en el catálogo
        $request->validate([
            'codigo_producto' => 'required|string|exists:productos,codigo_producto',
            'serial'          => 'required|string|unique:inventario_entradas,serial',
            'oc_proveedor'    => 'nullable|string|max:50',
        ]);

        try {
            DB::beginTransaction(); // Iniciamos la transacción segura

            // 2. Buscamos el ID real del producto usando el código escaneado
            $producto = Producto::where('codigo_producto', $request->codigo_producto)->first();

            // 3. Crear el registro individual de entrada
            $entrada = InventarioEntrada::create([
                'id_producto'    => $producto->id_producto, // Usamos el ID encontrado
                'id_responsable' => Auth::id(), // El usuario logueado en la app
                'oc_proveedor'   => $request->oc_proveedor,
                'serial'         => $request->serial,
                'estado_serial'  => 'Disponible',
            ]);

            // 4. Actualizar el Stock Global (Tabla inventario_productos)
            // Usamos firstOrCreate por si es la primera vez que ingresa este producto
            $stockGlobal = InventarioProducto::firstOrCreate(
                ['id_producto' => $producto->id_producto],
                ['stock_actual' => 0, 'stock_minimo' => 0]
            );

            // Le sumamos 1 al stock actual
            $stockGlobal->increment('stock_actual', 1);

            DB::commit(); // Guardamos los cambios definitivamente

            return response()->json([
                'success' => true,
                'message' => 'Entrada registrada y stock actualizado.',
                'data'    => $entrada
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack(); // Si algo falla, deshacemos todo para evitar descuadres
            return response()->json([
                'success' => false, 
                'message' => 'Error al registrar entrada: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 2. REGISTRAR SALIDA (El equipo se entrega/vende al cliente)
     */
    public function registrarSalida(Request $request)
    {
        // 1. Validar la petición (Aquí no necesitamos el código del producto, solo el serial físico)
        $request->validate([
            'serial'     => 'required|string',
            'id_cliente' => 'required|exists:cliente,id_cliente',
            'oc_cliente' => 'nullable|string|max:50',
        ]);

        try {
            DB::beginTransaction();

            // 2. Buscar si el serial escaneado existe y si realmente está "Disponible" en bodega
            $entradaOriginal = InventarioEntrada::where('serial', $request->serial)->first();

            if (!$entradaOriginal) {
                return response()->json([
                    'success' => false, 
                    'message' => 'El número de serie no existe en el sistema.'
                ], 404);
            }

            if ($entradaOriginal->estado_serial !== 'Disponible') {
                return response()->json([
                    'success' => false, 
                    'message' => 'Este equipo ya fue entregado o se encuentra defectuoso.'
                ], 400);
            }

            // 3. Crear el registro de Salida
            $salida = InventarioSalida::create([
                'id_entrada'     => $entradaOriginal->id_entrada,
                'id_producto'    => $entradaOriginal->id_producto,
                'id_cliente'     => $request->id_cliente,
                'id_responsable' => Auth::id(),
                'oc_cliente'     => $request->oc_cliente,
                'serial'         => $request->serial, // Lo guardamos como respaldo
            ]);

            // 4. Cambiar el estado de la Entrada original a 'Entregado'
            $entradaOriginal->update(['estado_serial' => 'Entregado']);

            // 5. Restar 1 al Stock Global
            $stockGlobal = InventarioProducto::where('id_producto', $entradaOriginal->id_producto)->first();
            if ($stockGlobal && $stockGlobal->stock_actual > 0) {
                $stockGlobal->decrement('stock_actual', 1);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Salida registrada correctamente. Stock descontado.',
                'data'    => $salida
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false, 
                'message' => 'Error al registrar salida: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 3. CONSULTAR INFORMACIÓN DE UN SERIAL
     * Escaneas un código con la app y Laravel te devuelve qué producto es y si está disponible.
     */
    public function consultarSerial($serial)
    {
        // Traemos la entrada con la información de su producto asociado
        $equipo = InventarioEntrada::with('producto')->where('serial', $serial)->first();

        if (!$equipo) {
            return response()->json([
                'success' => false, 
                'message' => 'Serial no encontrado.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => $equipo
        ], 200);
    }

    /**
     * OBTENER STOCK GLOBAL (Para la Web)
     */
    public function obtenerStock()
    {
        $stock = InventarioProducto::with('producto')->get();
        
        // Calculamos los totales históricos al vuelo
        foreach ($stock as $item) {
            $item->total_entradas = InventarioEntrada::where('id_producto', $item->id_producto)->count();
            $item->total_salidas = InventarioSalida::where('id_producto', $item->id_producto)->count();
        }

        return response()->json(['success' => true, 'data' => $stock], 200);
    }

    /**
     * OBTENER HISTORIAL DE ENTRADAS (Para la Web)
     */
    public function obtenerEntradas()
    {
        // Traemos las entradas ordenadas de la más nueva a la más vieja, junto con el nombre del producto
        $entradas = InventarioEntrada::with(['producto', 'responsable'])->orderBy('created_at', 'desc')->get();
        return response()->json(['success' => true, 'data' => $entradas], 200);
    }

    /**
     * OBTENER HISTORIAL DE SALIDAS (Para la Web)
     */
    public function obtenerSalidas()
    {
        // Traemos las salidas con su producto asociado
        $salidas = InventarioSalida::with(['producto', 'responsable'])->orderBy('created_at', 'desc')->get();
        return response()->json(['success' => true, 'data' => $salidas], 200);
    }

    
}

