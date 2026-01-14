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

  // Lista de Servicios (del cliente seleccionado)
  List<ServicioModel> _servicios = [];
  List<ServicioModel> get servicios => _servicios;

  // Lista de Áreas (Para el Dropdown)
  List<AreaModel> _areas = [];
  List<AreaModel> get areas => _areas;

  // --- 1. CARGAR ÁREAS (Para el Dropdown) ---
  Future<void> cargarAreas() async {
    // Si ya tenemos áreas cargadas, no las pedimos de nuevo (Optimización)
    if (_areas.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/areas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _areas = data.map((json) => AreaModel.fromJson(json)).toList();
      } else {
        _error = "Error cargando áreas";
      }
    } catch (e) {
      _error = "Error de conexión: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. LISTAR SERVICIOS DE UN CLIENTE ---
  Future<void> cargarServiciosPorCliente(
    int idCliente, {
    int intento = 1,
    int maxIntentos = 2,
  }) async {
    _isLoading = true;
    _servicios = []; // Limpiamos visualmente
    _error = null; // Limpiamos errores viejos
    notifyListeners();

    print(
      "🔍 PROVIDER: Cargando servicios para Cliente ID: $idCliente (intento $intento)...",
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = '${ApiService.baseUrl}/servicios/cliente/$idCliente';
      print("📡 GET URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("📨 RESPUESTA CODE: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        print("📦 RESPUESTA BODY LENGTH: ${data.length}");

        _servicios = data.map((json) => ServicioModel.fromJson(json)).toList();
        print(
          "🎉 Lista procesada correctamente en Flutter. Total: ${_servicios.length}",
        );

        // Si la respuesta fue vacía y aún no llegamos al máximo de intentos, reintentamos
        if (_servicios.isEmpty && intento < maxIntentos) {
          print("⚠️ Respuesta vacía, reintentando en 600ms...");
          await Future.delayed(const Duration(milliseconds: 600));
          await cargarServiciosPorCliente(
            idCliente,
            intento: intento + 1,
            maxIntentos: maxIntentos,
          );
        }
      } else {
        _error =
            "Error ${response.statusCode}: No se pudieron cargar servicios";
        print("❌ ERROR BACKEND: $_error");

        // Si hubo error y podemos reintentar, lo hacemos
        if (intento < maxIntentos) {
          print(
            "⚠️ Error al cargar, reintentando en 600ms (intento ${intento + 1})...",
          );
          await Future.delayed(const Duration(milliseconds: 600));
          await cargarServiciosPorCliente(
            idCliente,
            intento: intento + 1,
            maxIntentos: maxIntentos,
          );
        }
      }
    } catch (e, stackTrace) {
      _error = "Error interno: $e";
      print("🔥 EXCEPCIÓN FLUTTER: $e");
      print(stackTrace);

      if (intento < maxIntentos) {
        print(
          "⚠️ Excepción, reintentando en 600ms (intento ${intento + 1})...",
        );
        await Future.delayed(const Duration(milliseconds: 600));
        await cargarServiciosPorCliente(
          idCliente,
          intento: intento + 1,
          maxIntentos: maxIntentos,
        );
      }
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/servicios'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(servicio.toJson()),
      );

      if (response.statusCode == 201) {
        // Recargamos la lista del cliente actual para ver el cambio
        await cargarServiciosPorCliente(servicio.idCliente);
        return true;
      } else {
        final resp = jsonDecode(response.body);
        _error = resp['message'] ?? "Error al crear servicio";
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
