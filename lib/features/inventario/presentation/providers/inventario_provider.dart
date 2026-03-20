import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/inventario/data/models/producto_model.dart';
import 'package:somnolence_app/features/inventario/data/models/proveedor_model.dart';
import 'package:somnolence_app/features/inventario/data/models/inventario_entrada_model.dart';
// 👇 Nuevas importaciones para la vista web
import 'package:somnolence_app/features/inventario/data/models/inventario_producto_model.dart';
import 'package:somnolence_app/features/inventario/data/models/inventario_salida_model.dart';

class InventarioProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Instancia de tu servicio
  final ApiService _api = ApiService();

  // ==========================================
  // VARIABLES DE ESTADO (MÓVIL)
  // ==========================================
  List<ProveedorModel> _proveedores = [];
  ProductoModel? _productoEscaneado;
  InventarioEntradaModel? _entradaConsultada;

  // ==========================================
  // VARIABLES DE ESTADO (WEB - TABLAS)
  // ==========================================
  List<InventarioProductoModel> _listaStock = [];
  List<InventarioEntradaModel> _listaEntradas = [];
  List<InventarioSalidaModel> _listaSalidas = [];

  // ==========================================
  // GETTERS
  // ==========================================
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ProveedorModel> get proveedores => _proveedores;
  ProductoModel? get productoEscaneado => _productoEscaneado;
  InventarioEntradaModel? get entradaConsultada => _entradaConsultada;

  List<InventarioProductoModel> get listaStock => _listaStock;
  List<InventarioEntradaModel> get listaEntradas => _listaEntradas;
  List<InventarioSalidaModel> get listaSalidas => _listaSalidas;

  // --- 1. VERIFICAR SI EL CÓDIGO DE PRODUCTO EXISTE ---
  Future<bool> verificarCodigoProducto(String codigo) async {
    _setLoading(true);
    try {
      final response = await _api.get('/productos/verificar/$codigo');
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['existe'] == true) {
        _productoEscaneado = ProductoModel.fromJson(data['producto']);
        _setLoading(false);
        return true;
      } else {
        _productoEscaneado = null;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al verificar el código: $e');
      return false;
    }
  }

  // --- 2. OBTENER PROVEEDORES PARA EL COMBOBOX ---
  Future<void> cargarProveedores() async {
    _setLoading(true);
    try {
      final response = await _api.get('/proveedores');
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> lista = data['data'];
        _proveedores = lista
            .map((json) => ProveedorModel.fromJson(json))
            .toList();
      } else {
        _setError(data['message'] ?? 'Error al cargar proveedores');
      }
    } catch (e) {
      _setError('Excepción al cargar proveedores: $e');
    } finally {
      _setLoading(false);
    }
  }

  // --- 3. CREAR PRODUCTO NUEVO (ON-THE-FLY) ---
  Future<bool> crearProductoRapido(Map<String, dynamic> datosProducto) async {
    _setLoading(true);
    try {
      final response = await _api.post('/productos/nuevo', datosProducto);
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        _productoEscaneado = ProductoModel.fromJson(data['data']);
        _setLoading(false);
        return true;
      }
      _setError(data['message'] ?? 'Error desconocido al crear producto');
      return false;
    } catch (e) {
      _setError('Error de conexión al crear producto: $e');
      return false;
    }
  }

  // --- 4. REGISTRAR ENTRADA DE INVENTARIO ---
  Future<bool> registrarEntrada({
    required String codigoProducto,
    required String serial,
    String? ocProveedor,
  }) async {
    _setLoading(true);
    try {
      final response = await _api.post('/inventario/entrada', {
        'codigo_producto': codigoProducto,
        'serial': serial,
        'oc_proveedor': ocProveedor,
      });

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        _setLoading(false);
        return true;
      }
      _setError(data['message'] ?? 'No se pudo registrar la entrada');
      return false;
    } catch (e) {
      _setError('Error de conexión en la entrada: $e');
      return false;
    }
  }

  // --- 5. REGISTRAR SALIDA DE INVENTARIO ---
  Future<bool> registrarSalida({
    required String serial,
    required int idCliente,
    String? ocCliente,
  }) async {
    _setLoading(true);
    try {
      final response = await _api.post('/inventario/salida', {
        'serial': serial,
        'id_cliente': idCliente,
        'oc_cliente': ocCliente,
      });

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        _setLoading(false);
        return true;
      }
      _setError(data['message'] ?? 'No se pudo registrar la salida');
      return false;
    } catch (e) {
      _setError('Error de conexión en la salida: $e');
      return false;
    }
  }

  // --- 6. CONSULTAR UN SERIAL ---
  Future<bool> consultarSerial(String serial) async {
    _setLoading(true);
    try {
      final response = await _api.get('/inventario/serial/$serial');
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _entradaConsultada = InventarioEntradaModel.fromJson(data['data']);
        _setLoading(false);
        return true;
      }
      _entradaConsultada = null;
      _setError(data['message'] ?? 'No se encontró el serial');
      return false;
    } catch (e) {
      _entradaConsultada = null;
      _setError('Error de conexión al consultar serial: $e');
      return false;
    }
  }

  // --- 7. CARGAR DATOS PARA LA VISTA WEB (TABLAS) ---
  Future<void> cargarTablasWeb() async {
    _setLoading(true);
    try {
      final resStock = await _api.get('/inventario/stock');
      final resEntradas = await _api.get('/inventario/entradas');
      final resSalidas = await _api.get('/inventario/salidas');

      if (resStock.statusCode == 200) {
        final data = jsonDecode(resStock.body)['data'] as List;
        _listaStock = data
            .map((e) => InventarioProductoModel.fromJson(e))
            .toList();
      }
      if (resEntradas.statusCode == 200) {
        final data = jsonDecode(resEntradas.body)['data'] as List;
        _listaEntradas = data
            .map((e) => InventarioEntradaModel.fromJson(e))
            .toList();
      }
      if (resSalidas.statusCode == 200) {
        final data = jsonDecode(resSalidas.body)['data'] as List;
        _listaSalidas = data
            .map((e) => InventarioSalidaModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _setError('Error al cargar tablas: $e');
    } finally {
      _setLoading(false);
    }
  }

  // --- Utilidades internas ---
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

  void limpiarError() {
    _errorMessage = null;
    notifyListeners();
  }
}
