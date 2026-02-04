import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somnolence_app/features/admin/data/models/servicio_model.dart';
import '../../../../core/api/api_service.dart';
import '../../data/models/area_model.dart';

class ServicioProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<ServicioModel> _servicios = [];
  List<ServicioModel> get servicios => _servicios;

  List<AreaModel> _areas = [];
  List<AreaModel> get areas => _areas;

  // --- FUNCIÓN PRIVADA PARA HEADERS ---
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // --- 1. CARGAR ÁREAS ---
  Future<void> cargarAreas() async {
    if (_areas.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/areas'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _areas = data.map((json) => AreaModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error cargando áreas: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. LISTAR SERVICIOS (CON LOGS DE DEPURACIÓN) ---
  Future<void> cargarServiciosPorCliente(
    int idCliente, {
    int intento = 1,
    int maxIntentos = 2,
  }) async {
    _isLoading = true;
    _error = null;
    // NOTA: Ya NO borramos la lista al inicio para evitar pantalla blanca si falla
    // _servicios = [];
    notifyListeners();

    try {
      final url = '${ApiService.baseUrl}/servicios/cliente/$idCliente';
      print("📡 GET Solicitando: $url"); // DEBUG

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      print("📨 Respuesta Status: ${response.statusCode}"); // DEBUG

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Mapeamos los datos
        _servicios = data.map((json) => ServicioModel.fromJson(json)).toList();
        print("✅ Servicios cargados: ${_servicios.length}"); // DEBUG
      } else {
        // Si falla, mostramos el cuerpo del error para saber qué pasó en Laravel
        print("❌ Error Backend Body: ${response.body}");
        _error =
            "Error ${response.statusCode}: No se pudieron cargar servicios";
      }
    } catch (e, stack) {
      _error = "Error interno: $e";
      print("🔥 Excepción en Flutter: $e");
      print(stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 3. CREAR SERVICIO ---
  Future<bool> crearServicio(ServicioModel servicio) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("📤 Enviando servicio: ${jsonEncode(servicio.toJson())}"); // DEBUG

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/servicios'),
        headers: await _getHeaders(),
        body: jsonEncode(servicio.toJson()),
      );

      print("📨 Crear Status: ${response.statusCode}"); // DEBUG

      if (response.statusCode == 201) {
        print("✅ Servicio creado, recargando lista...");
        // Recargamos la lista
        await cargarServiciosPorCliente(servicio.idCliente);
        return true;
      } else {
        print("❌ Error Crear Body: ${response.body}");
        final resp = jsonDecode(response.body);
        _error = resp['message'] ?? "Error al crear servicio";
        return false;
      }
    } catch (e) {
      print("🔥 Error conexión crear: $e");
      _error = "Error de conexión: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 4. ACTUALIZAR NOMBRE ---
  Future<bool> actualizarNombreServicio(
    int idServicio,
    String nuevoNombre,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/servicios/$idServicio/nombre'),
        headers: await _getHeaders(),
        body: jsonEncode({'nombre_servicio': nuevoNombre}),
      );

      if (response.statusCode == 200) {
        final index = _servicios.indexWhere((s) => s.idServicio == idServicio);
        if (index != -1) {
          // Recargamos usando el ID de cliente que ya tenemos en memoria
          await cargarServiciosPorCliente(_servicios[index].idCliente);
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Error actualizando nombre: $e");
      return false;
    }
  }
}
