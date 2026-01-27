<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ViajeController;
use App\Http\Controllers\VehiculoController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\ClienteController;
use App\Http\Controllers\AreaController;
use App\Http\Controllers\ServicioController;
use App\Http\Controllers\RendicionController; // <--- AGREGAR
use App\Http\Controllers\GastoController;

// Rutas públicas
Route::post('/login', [AuthController::class, 'login']);
Route::post('/viajes/registrar', [ViajeController::class, 'registrar']);
Route::get('/ping', function () {
    return response()->json(['status' => 'ok']);
});

Route::get('evidencia/{ruta}', [GastoController::class, 'verEvidencia'])
    ->where('ruta', '.*');

// Rutas protegidas (Token Requerido)
Route::middleware('auth:sanctum')->group(function () {
    // --- AUTENTICACIÓN Y PERFIL ---
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);
    Route::post('/update-device', [AuthController::class, 'updateDeviceId']);
    
    // --- VEHÍCULOS ---
    Route::get('/vehiculos/patentes', [VehiculoController::class, 'obtenerPatentes']);

    // --- ZONA ADMIN (USUARIOS) ---
    Route::get('/admin/users', [AdminController::class, 'listarUsuarios']);
    Route::get('/admin/empresas', [AdminController::class, 'listarEmpresas']); 
    Route::post('/admin/usuarios', [AdminController::class, 'crearUsuario']);  
    Route::put('/admin/usuarios/{id}/estado', [AdminController::class, 'cambiarEstadoUsuario']);
    Route::put('/admin/usuarios/{id}', [AdminController::class, 'actualizarUsuario']);
    Route::get('/admin/historial', [RendicionController::class, 'historialGlobal']);
    Route::post('/admin/rendiciones/{id}/pagar', [RendicionController::class, 'pagar']);
    Route::get('/admin/rendiciones', [RendicionController::class, 'pendientesDeValidacion']);
    Route::patch('/admin/gastos/{id}/evaluar', [GastoController::class, 'evaluarGasto']);
    Route::post('/admin/rendiciones/{id}/finalizar', [RendicionController::class, 'finalizarValidacion']);
    Route::post('/admin/rendiciones/{id}/validar', [RendicionController::class, 'procesarValidacion']);
    Route::get('/admin/pendientes/count', [RendicionController::class, 'contarPendientes']);
    // --- CLIENTES ---
    Route::get('/clientes', [ClienteController::class, 'index']); 
    Route::post('/clientes', [ClienteController::class, 'store']); 
    Route::put('/clientes/{id}', [ClienteController::class, 'update']);

    // --- GESTIÓN DE SERVICIOS ---
    
    // 1. Áreas (Dropdown)
    Route::get('/admin/areas', [AreaController::class, 'index']);

    // 2. Operaciones de Servicios
    Route::prefix('servicios')->group(function () {
        // Rutas Base
        Route::post('/', [ServicioController::class, 'store']);                  // Crear servicio simple
        Route::get('/cliente/{id}', [ServicioController::class, 'byCliente']);  // Listar servicios de un cliente
        Route::put('/{id}/info', [ServicioController::class, 'updateInfo']);      // Modificar Fechas/Facturación
        Route::put('/{id}/finalizar', [ServicioController::class, 'finalizar']);    // Finalizar Servicio
        Route::put('/{id}/reactivar', [ServicioController::class, 'reactivar']); // Reactivar Servicio
        Route::post('/{id}/oc', [ServicioController::class, 'agregarOc']);        // Agregar una OC
        Route::post('/{id}/has', [ServicioController::class, 'agregarHas']);      // Agregar una HAS
    });

    Route::get('/rendiciones', [RendicionController::class, 'misRendiciones']); // Listar historial
    Route::post('/rendiciones', [RendicionController::class, 'store']); // Crear nueva (Borrador)
    Route::get('/rendiciones/{id}', [RendicionController::class, 'show']); // Ver detalle
    Route::delete('/rendiciones/{id}', [RendicionController::class, 'destroy']);
    Route::put('/rendiciones/{id}', [RendicionController::class, 'update']);
    
    // (Opcional) Ruta para cambiar estado a "Pendiente"
    Route::put('/rendiciones/{id}/enviar', [RendicionController::class, 'enviar']); 

    // --- GASTOS (Detalle + Fotos) ---
    Route::post('/gastos', [GastoController::class, 'store']);           // 1. Crear Gasto (Texto)
    Route::post('/gastos/archivo', [GastoController::class, 'subirArchivo']); // 2. Subir Archivo (Multipart)
    Route::delete('/gastos/{id}', [GastoController::class, 'destroy']);
    Route::delete('/gastos/{idGasto}/archivo', [GastoController::class, 'eliminarArchivo']);

});

Route::get('/test-db', function () {
    try {
        \DB::connection()->getPdo();
        return response()->json(['msg' => 'CONEXION EXITOSA: ' . \DB::connection()->getDatabaseName()]);
    } catch (\Exception $e) {
        return response()->json(['msg' => 'ERROR: ' . $e->getMessage()], 500);
    }
});