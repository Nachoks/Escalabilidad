<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ViajeController;
use App\Http\Controllers\VehiculoController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\ClienteController;
// 👇 AGREGAMOS ESTOS DOS CONTROLADORES NUEVOS
use App\Http\Controllers\AreaController;
use App\Http\Controllers\ServicioController;

// Rutas públicas
Route::post('/login', [AuthController::class, 'login']);
Route::post('/viajes/registrar', [ViajeController::class, 'registrar']);
Route::get('/ping', function () {
    return response()->json(['status' => 'ok']);
});

// Rutas protegidas (Token Requerido)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    
    Route::get('/vehiculos/patentes', [VehiculoController::class, 'obtenerPatentes']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);

    // --- ZONA ADMIN (USUARIOS Y CLIENTES) ---
    Route::get('/admin/users', [AdminController::class, 'listarUsuarios']);
    Route::get('/admin/empresas', [AdminController::class, 'listarEmpresas']); 
    Route::post('/admin/usuarios', [AdminController::class, 'crearUsuario']);  
    Route::put('/admin/usuarios/{id}/estado', [AdminController::class, 'cambiarEstadoUsuario']);
    Route::put('/admin/usuarios/{id}', [AdminController::class, 'actualizarUsuario']);
    
    Route::get('/clientes', [ClienteController::class, 'index']); 
    Route::post('/clientes', [ClienteController::class, 'store']); 

    // --- GESTIÓN DE SERVICIOS (ADMIN) ---
    // 1. Áreas: Para llenar el dropdown al crear servicio
    Route::get('/admin/areas', [AreaController::class, 'index']);

    // 2. Servicios: Creación y Listado
    Route::post('/servicios', [ServicioController::class, 'store']); // Crear (genera centro costo)
    Route::get('/servicios/cliente/{id}', [ServicioController::class, 'byCliente']); // Ver servicios de un cliente
    
});

Route::get('/test-db', function () {
    try {
        \DB::connection()->getPdo();
        return response()->json(['msg' => 'CONEXION EXITOSA: ' . \DB::connection()->getDatabaseName()]);
    } catch (\Exception $e) {
        return response()->json(['msg' => 'ERROR: ' . $e->getMessage()], 500);
    }
});