import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/inventario/data/models/regla_escaneo_model.dart';

class ReglaEscaneoProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<ReglaEscaneoModel> _reglas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReglaEscaneoModel> get reglas => _reglas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. CARGAR REGLAS DESDE LARAVEL
  Future<void> cargarReglas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get('/reglas-escaneo');
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> listaJson = data['data'];
        _reglas = listaJson
            .map((json) => ReglaEscaneoModel.fromJson(json))
            .toList();
      } else {
        _errorMessage = data['message'] ?? 'Error al cargar reglas';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. CREAR REGLA (Para la pantalla de Administrador)
  Future<bool> crearRegla(Map<String, dynamic> datos) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post('/reglas-escaneo', datos);
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        await cargarReglas(); // Recargamos la lista
        return true;
      }
      _errorMessage = data['message'] ?? 'Error al crear regla';
      return false;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. ELIMINAR REGLA
  Future<bool> eliminarRegla(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.delete('/reglas-escaneo/$id');
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await cargarReglas();
        return true;
      }
      _errorMessage = data['message'] ?? 'Error al eliminar regla';
      return false;
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
