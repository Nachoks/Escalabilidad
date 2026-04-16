<?php

use Illuminate\Support\Facades\Route;
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
use App\Http\Controllers\InventarioController;
use App\Http\Controllers\ProductoController;
use App\Http\Controllers\ProveedorController;
use App\Http\Controllers\ReglaEscaneoController;


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
       
        // --- RUTAS DE HOJA DE TIEMPO PARA ADMINISTRADORES ---
        Route::prefix('hoja-tiempo')->group(function () {
            Route::get('/pendientes', [HojaTiempoController::class, 'pendientesAdmin']);
            Route::get('/historial', [HojaTiempoController::class, 'historialAdmin']);
            Route::post('/{id}/evaluar', [HojaTiempoController::class, 'evaluarHoja']);
           
            // ¡AQUÍ SE AGREGARON LAS RUTAS FALTANTES PARA EVALUAR POR DÍA!
            Route::get('/pendientes-diarias', [HojaTiempoController::class, 'pendientesDiariasAdmin']);
            Route::post('/dia/{id}/evaluar', [HojaTiempoController::class, 'evaluarDia']);
        });


        // --- RUTAS DE RENDICIONES PARA ADMINISTRADORES ---
        Route::get('/rendiciones', [RendicionController::class, 'pendientesDeValidacion']);
        Route::get('/historial-rendiciones', [RendicionController::class, 'historialGlobal']); // Cambiado nombre para evitar conflicto
        Route::get('/pendientes/count', [RendicionController::class, 'contarPendientes']);
       
        // Acciones de Validación Rendiciones
        Route::post('/rendiciones/{id}/validar', [RendicionController::class, 'procesarValidacion']);
        Route::post('/rendiciones/{id}/pagar', [RendicionController::class, 'pagar']);
        Route::post('/rendiciones/{id}/finalizar', [RendicionController::class, 'finalizarValidacion']);
        Route::patch('/gastos/{id}/evaluar', [GastoController::class, 'evaluarGasto']);
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
        Route::put('/{id}/reactivar', [ServicioController::class, 'reactivar']);


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




    // =================================================================
    // 5. RENDICIONES Y GASTOS (USUARIO)
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




    // =================================================================
    // 6. DROPDOWNS GENERALES
    // =================================================================
    Route::prefix('dropdowns')->group(function () {
        Route::get('/clientes', [HojaTiempoController::class, 'getClientes']);
        Route::get('/clientes/{id_cliente}/servicios', [HojaTiempoController::class, 'getServiciosPorCliente']);
        Route::get('/servicios/{id_servicio}/ocs', [HojaTiempoController::class, 'getOcsPorServicio']);
    });


    // =================================================================
    // 7. RUTAS DE HOJA DE TIEMPO PARA EL USUARIO / TÉCNICO
    // =================================================================
    Route::prefix('hoja-tiempo')->group(function () {
        Route::post('/crear', [HojaTiempoController::class, 'crearSemana']);
        Route::post('/mis-hojas', [HojaTiempoController::class, 'misHojas']);
        Route::get('/{id_hoja_semana}/detalle', [HojaTiempoController::class, 'detalleHoja']);
        Route::post('/dia/{id_hoja_diaria}/guardar', [HojaTiempoController::class, 'guardarDia']);
        Route::post('/dia/{id_hoja_diaria}/enviar', [HojaTiempoController::class, 'enviarDia']); // Para enviar un día específico
        Route::post('/{id}/enviar', [HojaTiempoController::class, 'enviarSemana']); // Para enviar la semana completa
    });


    // =================================================================
    // 8. MÓDULO DE INVENTARIO Y CATÁLOGO
    // =================================================================
   
    // --- INVENTARIO (ENTRADAS, SALIDAS Y CONSULTA DE SERIAL) ---
    Route::prefix('inventario')->group(function () {
        Route::post('/entrada', [InventarioController::class, 'registrarEntrada']);
        Route::post('/salida', [InventarioController::class, 'registrarSalida']);
        Route::get('/serial/{serial}', [InventarioController::class, 'consultarSerial']);
        Route::get('/stock', [InventarioController::class, 'obtenerStock']);
        Route::get('/entradas', [InventarioController::class, 'obtenerEntradas']);
        Route::get('/salidas', [InventarioController::class, 'obtenerSalidas']);
        Route::put('/stock/{id}/minimo', [InventarioController::class, 'actualizarStockMinimo']);


    });


    // --- CATÁLOGO DE PRODUCTOS ---
    Route::prefix('productos')->group(function () {
        Route::get('/verificar/{codigo}', [ProductoController::class, 'verificarCodigo']);
        Route::post('/nuevo', [ProductoController::class, 'store']);
        Route::put('/{id}', [ProductoController::class, 'update']);
    });


    // --- PROVEEDORES (CRUD COMPLETO) ---
    Route::prefix('proveedores')->group(function () {
        Route::get('/', [ProveedorController::class, 'index']); // Sustituye a la anterior /proveedores/lista
        Route::post('/', [ProveedorController::class, 'store']);
        Route::get('/{id}', [ProveedorController::class, 'show']);
        Route::put('/{id}', [ProveedorController::class, 'update']);
        Route::delete('/{id}', [ProveedorController::class, 'destroy']);
    });


    // 👇 RUTAS DEL MOTOR DINÁMICO DE ESCANEO 👇
    Route::prefix('reglas-escaneo')->group(function () {
        Route::get('/', [ReglaEscaneoController::class, 'index']);
        Route::post('/', [ReglaEscaneoController::class, 'store']);
        Route::get('/{id}', [ReglaEscaneoController::class, 'show']);
        Route::put('/{id}', [ReglaEscaneoController::class, 'update']);
        Route::delete('/{id}', [ReglaEscaneoController::class, 'destroy']);
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


