<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Producto;
use App\Models\Proveedor;

class ProductoController extends Controller
{
    /**
     * 1. VERIFICAR SI EL CÓDIGO EXISTE
     * Flutter llamará a esta ruta en silencio apenas extraiga el código del QR.
     */
    public function verificarCodigo($codigo)
    {
        // Buscamos si el código de producto ya está registrado en el catálogo
        $producto = Producto::where('codigo_producto', $codigo)->first();

        if ($producto) {
            // Si existe, le decimos a Flutter que puede continuar directo a registrar la entrada
            return response()->json([
                'existe'   => true,
                'producto' => $producto
            ], 200);
        }

        // Si no existe, Flutter abrirá el Pop-up para agregarlo
        return response()->json([
            'existe'  => false,
            'mensaje' => 'El producto no existe en el catálogo. Por favor, regístrelo.'
        ], 200); 
    }

    /**
     * 2. OBTENER LISTA DE PROVEEDORES
     * Sirve para llenar el Combobox (Dropdown) en la pantalla de Flutter.
     */
    public function obtenerProveedores()
    {
        // Traemos solo los campos necesarios para no sobrecargar el celular
        $proveedores = Proveedor::select('id_proveedor', 'nombre_proveedor')->get();
        
        return response()->json([
            'success' => true,
            'data'    => $proveedores
        ], 200);
    }

    /**
     * 3. GUARDAR PRODUCTO NUEVO (On-the-fly)
     * Flutter envía los datos desde el Pop-up para registrar el nuevo modelo.
     */
    public function store(Request $request)
    {
        // 1. Validamos que nos envíen todos los datos y que el código no se repita
        $request->validate([
            'codigo_producto' => 'required|string|unique:productos,codigo_producto',
            'nombre_producto' => 'required|string|max:100',
            'marca'           => 'required|string|max:50',
            'id_proveedor'    => 'required|exists:proveedores,id_proveedor',
        ]);

        try {
            // 2. Creamos el producto en el catálogo
            $producto = Producto::create([
                'codigo_producto' => $request->codigo_producto,
                'nombre_producto' => $request->nombre_producto,
                'marca'           => $request->marca,
                'id_proveedor'    => $request->id_proveedor,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Producto agregado al catálogo exitosamente.',
                'data'    => $producto
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error al guardar el producto: ' . $e->getMessage()
            ], 500);
        }
    }
}

