import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somnolence_app/core/constants/app_constants.dart';
import '../../data/models/proveedor_model.dart';
// Asegúrate de importar el modelo de contacto si está en un archivo separado
// import '../../data/models/contacto_proveedor_model.dart';

class ProveedorProvider extends ChangeNotifier {
  List<ProveedorModel> _proveedores = [];
  List<ProveedorModel> _proveedoresFiltrados = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<ProveedorModel> get proveedores => _proveedoresFiltrados;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get _baseUrl {
    String url = AppConstants.apiUrl;
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return url;
  }

  // Obtenemos los headers con el Token de autorización
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> cargarProveedores() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/proveedores');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'] ?? [];
        _proveedores = data.map((e) => ProveedorModel.fromJson(e)).toList();
        _aplicarFiltro();
      } else {
        _errorMessage = 'Error al cargar proveedores';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void buscarProveedor(String query) {
    _searchQuery = query.toLowerCase();
    _aplicarFiltro();
    notifyListeners();
  }

  void _aplicarFiltro() {
    if (_searchQuery.isEmpty) {
      _proveedoresFiltrados = List.from(_proveedores);
    } else {
      _proveedoresFiltrados = _proveedores.where((prov) {
        // 1. Buscamos por el nombre del proveedor
        final matchProveedor = prov.nombreProveedor.toLowerCase().contains(
          _searchQuery,
        );

        // 2. Buscamos dentro de la lista de sus contactos
        final matchContacto = prov.contactos.any((contacto) {
          final nombre = contacto.nombreContacto.toLowerCase();
          final correo = contacto.correoContacto?.toLowerCase() ?? '';
          final numero = contacto.numeroContacto?.toLowerCase() ?? '';

          return nombre.contains(_searchQuery) ||
              correo.contains(_searchQuery) ||
              numero.contains(_searchQuery);
        });

        // Si coincide el nombre de la empresa O alguno de sus contactos, lo mostramos
        return matchProveedor || matchContacto;
      }).toList();
    }
  }

  // Esta función envía el JSON completo, el backend se encarga de vaciar
  // los contactos viejos y guardar la lista de contactos nuevos enviada.
  Future<bool> guardarProveedor(ProveedorModel proveedor) async {
    _isLoading = true;
    notifyListeners();

    try {
      final isEditing = proveedor.idProveedor > 0;
      final url = isEditing
          ? Uri.parse('$_baseUrl/proveedores/${proveedor.idProveedor}')
          : Uri.parse('$_baseUrl/proveedores');

      final body = jsonEncode(proveedor.toJson());
      final headers = await _getHeaders();

      final response = isEditing
          ? await http.put(url, headers: headers, body: body)
          : await http.post(url, headers: headers, body: body);

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await cargarProveedores();
        return true;
      } else {
        _errorMessage = decoded['message'] ?? 'Error al guardar';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarProveedor(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/proveedores/$id');
      final response = await http.delete(url, headers: await _getHeaders());
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await cargarProveedores();
        return true;
      } else {
        _errorMessage = decoded['message'] ?? 'Error al eliminar';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
