<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Cliente;

class ClienteController extends Controller
{
    // Guardar nuevo cliente (CON GENERACIÓN AUTOMÁTICA DE CÓDIGO)
    public function store(Request $request)
    {
        // 1. Validar
        // NOTA: Quitamos 'cod_cliente' de aquí porque el usuario ya no lo envía.
        $request->validate([
            'nombre_cliente' => 'required|string|max:255',
            'nombre_representante' => 'nullable|string|max:255',
            'correo_representante' => 'nullable|email|max:255',
        ]);

        // 2. Lógica para Generar el Código (XX) automáticamente
        // Buscamos el código más alto que exista en la base de datos
        $ultimoCliente = Cliente::orderBy('cod_cliente', 'desc')->first();

        if (!$ultimoCliente || !$ultimoCliente->cod_cliente) {
            // ESCENARIO A: Es el primer cliente del sistema
            $nuevoCodigo = "00"; 
        } else {
            // ESCENARIO B: Ya existen clientes (ej. "02")
            // Convertimos el texto "02" a número (2)
            $numeroActual = intval($ultimoCliente->cod_cliente);
            
            // Le sumamos 1 (2 + 1 = 3)
            $nuevoNumero = $numeroActual + 1;
            
            // Lo volvemos a convertir a texto con relleno de ceros (3 -> "03")
            $nuevoCodigo = str_pad($nuevoNumero, 2, "0", STR_PAD_LEFT);
        }

        // 3. Preparamos los datos para guardar
        $datosParaGuardar = $request->all();
        $datosParaGuardar['cod_cliente'] = $nuevoCodigo; // Inyectamos el código generado

        // 4. Crear en Base de Datos
        $cliente = Cliente::create($datosParaGuardar);

        // 5. Responder
        return response()->json([
            'success' => true,
            'message' => 'Cliente creado exitosamente',
            'data' => $cliente
        ], 201);
    }
    
    // Listar clientes
    public function index()
    {
        return response()->json(Cliente::orderBy('nombre_cliente')->get(), 200);
    }
}