import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';

class RendicionesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RendicionModel> _rendiciones = [];
  bool _isLoading = false;

  List<RendicionModel> get rendiciones => _rendiciones;
  bool get isLoading => _isLoading;

  // 1. CARGAR MIS RENDICIONES (GET)
  Future<void> cargarMisRendiciones() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/rendiciones');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _rendiciones = data
            .map((item) => RendicionModel.fromJson(item))
            .toList();
      } else {
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error cargando rendiciones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. CREAR NUEVA RENDICIÓN (POST)
  Future<bool> crearRendicion({
    required int idServicio, // Formato YYYY-MM-DD
    required String proposito,
    required int montoEntregado,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        "id_servicio": idServicio,
        "proposito": proposito,
        "monto_entregado": montoEntregado,
      };

      final response = await _apiService.post('/rendiciones', body);

      if (response.statusCode == 201) {
        await cargarMisRendiciones(); // Recargar lista tras éxito
        return true;
      } else {
        print('Error creando rendición: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción creando rendición: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
