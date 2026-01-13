import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_service.dart';
import '../../data/models/cliente_model.dart';

class ClienteProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Lista local de clientes para mostrar en la vista
  List<ClienteModel> _clientes = [];
  List<ClienteModel> get clientes => _clientes;

  String? _error;
  String? get error => _error;

  // --- VALIDAR CÓDIGO CLIENTE (LOCAL) ---
  bool existeCodigo(String codigo) {
    // Si la lista está vacía, no podemos validar localmente (asumimos false)
    if (_clientes.isEmpty) return false;

    final codigoNormalizado = codigo.trim().toUpperCase();

    return _clientes.any(
      (cliente) => cliente.codCliente?.toUpperCase() == codigoNormalizado,
    );
  }

  // --- LISTAR CLIENTES (GET) ---
  Future<void> cargarClientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/clientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _clientes = data.map((json) => ClienteModel.fromJson(json)).toList();
      } else {
        _error = "Error al cargar clientes: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Error de conexión: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CREAR CLIENTE (POST) ---
  Future<bool> crearCliente(ClienteModel cliente) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/clientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(cliente.toJson()),
      );

      if (response.statusCode == 201) {
        // Si se crea con éxito, recargamos la lista automáticamente
        await cargarClientes();
        return true;
      } else {
        _error = "Error al crear: ${response.body}";
        return false;
      }
    } catch (e) {
      _error = "Error de conexión: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
