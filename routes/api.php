<?php

use Illuminate\Support\Facades\Route;

// --- IMPORTACIÓN DE CONTROLADORES ---
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\ServicioController;
use App\Http\Controllers\OcClienteController;
use App\Http\Controllers\HasGuiaController;
use App\Http\Controllers\RendicionController;
use App\Http\Controllers\GastoController;
use App\Http\Controllers\ClienteController;
use App\Http\Controllers\AreaController;
use App\Http\Controllers\VehiculoController;
use App\Http\Controllers\ViajeController;
use App\Http\Controllers\HojaTiempoController;

/*
|--------------------------------------------------------------------------
| RUTAS PÚBLICAS (Sin Autenticación)
|--------------------------------------------------------------------------
*/
Route::post('/login', [AuthController::class, 'login']);
Route::post('/viajes/registrar', [ViajeController::class, 'registrar']);
Route::get('/ping', function () {
    return response()->json(['status' => 'ok']);
});
// Acceso a imágenes de evidencia (Ruta pública controlada)
Route::get('evidencia/{ruta}', [GastoController::class, 'verEvidencia'])
    ->where('ruta', '.*');
Route::post('/hoja-tiempo/crear', [HojaTiempoController::class, 'crearSemana']);
Route::post('/hoja-tiempo/mis-hojas', [HojaTiempoController::class, 'misHojas']);
Route::get('/hoja-tiempo/{id}/detalle', [HojaTiempoController::class, 'detalleHoja']);
Route::post('/hoja-tiempo/dia/{id}/guardar', [HojaTiempoController::class, 'guardarDia']);
Route::get('/dropdowns/clientes', [HojaTiempoController::class, 'getClientes']);
Route::get('/dropdowns/clientes/{id}/servicios', [HojaTiempoController::class, 'getServiciosPorCliente']);
Route::get('/dropdowns/servicios/{id}/ocs', [HojaTiempoController::class, 'getOcsPorServicio']);
/*
|--------------------------------------------------------------------------
| RUTAS PROTEGIDAS (Requieren Token Bearer)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // =================================================================
    // 1. GESTIÓN DE CUENTA Y PERFIL
    // =================================================================
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);
    Route::post('/update-device', [AuthController::class, 'updateDevice']);


    // =================================================================
    // 2. ADMINISTRACIÓN DEL SISTEMA (Usuarios y Config)
    // =================================================================
    Route::prefix('admin')->group(function () {
        Route::get('/users', [AdminController::class, 'listarUsuarios']);
        Route::post('/usuarios', [AdminController::class, 'crearUsuario']);
        Route::put('/usuarios/{id}', [AdminController::class, 'actualizarUsuario']);
        Route::put('/usuarios/{id}/estado', [AdminController::class, 'cambiarEstadoUsuario']);
        Route::get('/empresas', [AdminController::class, 'listarEmpresas']);
        Route::get('/areas', [AreaController::class, 'index']);
    });
    
    // Dropdowns y Utilitarios
    Route::get('/vehiculos/patentes', [VehiculoController::class, 'obtenerPatentes']);


    // =================================================================
    // 3. GESTIÓN COMERCIAL (Clientes)
    // =================================================================
    Route::get('/clientes', [ClienteController::class, 'index']);
    Route::post('/clientes', [ClienteController::class, 'store']);
    Route::put('/clientes/{id}', [ClienteController::class, 'update']);


    // =================================================================
    // 4. OPERACIONES: SERVICIOS -> OCs -> HAS (Estructura Jerárquica)
    // =================================================================
    
    // A. Servicios (Nivel Padre)
    Route::prefix('servicios')->group(function () {
        // CRUD Básico
        Route::post('/', [ServicioController::class, 'store']);
        Route::get('/cliente/{id}', [ServicioController::class, 'byCliente']);
        Route::put('/{id}/info', [ServicioController::class, 'updateInfo']);
        Route::put('/{id}/nombre', [ServicioController::class, 'updateNombre']);
        // Cambios de Estado
        Route::put('/{id}/finalizar', [ServicioController::class, 'finalizar']);
        Route::put('/{id}/reactivar', [ServicioController::class, 'reactivar']); // <--- AQUÍ ESTÁ LA RUTA QUE FALTABA

        // Relación: Servicios -> OCs
        Route::get('/{id}/ocs', [OcClienteController::class, 'indexByServicio']);
        Route::post('/{id}/ocs', [OcClienteController::class, 'store']);
    });

    // B. Órdenes de Compra (Nivel Hijo)
    // Editar y Eliminar OC por su ID directo
    Route::put('/ocs/{id}', [OcClienteController::class, 'update']);
    Route::delete('/ocs/{id}', [OcClienteController::class, 'destroy']);

    // Relación: OCs -> HAS (Ver y Crear HAS dentro de una OC)
    Route::get('/ocs/{id}/has', [HasGuiaController::class, 'indexByOc']);
    Route::post('/ocs/{id}/has', [HasGuiaController::class, 'store']);

    // C. Hojas de Aceptación HAS (Nivel Nieto)
    // Gestión directa de la HAS
    Route::post('/has/{idHas}/archivo', [HasGuiaController::class, 'subirArchivoHas']);
    Route::delete('/has/{idHas}/archivo', [HasGuiaController::class, 'eliminarArchivo']);
    Route::delete('/has/{id}', [HasGuiaController::class, 'destroy']);
    Route::post('/has/{idHas}/archivo', [HasGuiaController::class, 'subirArchivoHas']);


    // =================================================================
    // 5. RENDICIONES Y GASTOS
    // =================================================================
    
    // Rutas para el Usuario (Rendidor)
    Route::get('/rendiciones', [RendicionController::class, 'misRendiciones']);
    Route::post('/rendiciones', [RendicionController::class, 'store']);
    Route::get('/rendiciones/{id}', [RendicionController::class, 'show']);
    Route::put('/rendiciones/{id}', [RendicionController::class, 'update']);
    Route::delete('/rendiciones/{id}', [RendicionController::class, 'destroy']);
    Route::put('/rendiciones/{id}/enviar', [RendicionController::class, 'enviar']);

    // Rutas para Gastos (Detalle de Rendición)
    Route::post('/gastos', [GastoController::class, 'store']);
    Route::post('/gastos/archivo', [GastoController::class, 'subirArchivo']);
    Route::delete('/gastos/{id}', [GastoController::class, 'destroy']);
    Route::delete('/gastos/{idGasto}/archivo', [GastoController::class, 'eliminarArchivo']);

    // Rutas para el Admin (Validador)
    Route::prefix('admin')->group(function () {
        Route::get('/rendiciones', [RendicionController::class, 'pendientesDeValidacion']);
        Route::get('/historial', [RendicionController::class, 'historialGlobal']);
        Route::get('/pendientes/count', [RendicionController::class, 'contarPendientes']);
        
        // Acciones de Validación
        Route::post('/rendiciones/{id}/validar', [RendicionController::class, 'procesarValidacion']);
        Route::post('/rendiciones/{id}/pagar', [RendicionController::class, 'pagar']);
        Route::post('/rendiciones/{id}/finalizar', [RendicionController::class, 'finalizarValidacion']);
        Route::patch('/gastos/{id}/evaluar', [GastoController::class, 'evaluarGasto']);
    });
    


});

// --- RUTA DE TEST ---
Route::get('/test-db', function () {
    try {
        \DB::connection()->getPdo();
        return response()->json(['msg' => 'CONEXION EXITOSA: ' . \DB::connection()->getDatabaseName()]);
    } catch (\Exception $e) {
        return response()->json(['msg' => 'ERROR: ' . $e->getMessage()], 500);
    }
});