import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/core/constants/app_constants.dart';
import 'package:somnolence_app/core/services/auth_services.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';

class RendicionesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<RendicionModel> _rendiciones = [];
  bool _isLoading = false;
  List<RendicionModel> get rendiciones => _rendiciones;
  bool get isLoading => _isLoading;
  List<RendicionModel> _rendicionesPorValidar = [];
  List<RendicionModel> get rendicionesPorValidar => _rendicionesPorValidar;
  // Lista para el Historial
  List<RendicionModel> _historialGlobal = [];
  List<RendicionModel> get historialGlobal => _historialGlobal;
  int _cantidadPendientes = 0;
  int get cantidadPendientes => _cantidadPendientes;

  // --- HELPER: CONTROL DE CARGA ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 1. CARGAR MIS RENDICIONES (GET)
  Future<void> cargarMisRendiciones() async {
    _setLoading(true);

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
      _setLoading(false);
    }
  }

  // 2. CREAR NUEVA RENDICIÓN (POST)
  Future<bool> crearRendicion({
    required int idServicio,
    required String proposito,
    required int montoEntregado,
  }) async {
    _setLoading(true);

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
      _setLoading(false);
    }
  }

  // 3. EDITAR RENDICIÓN (PUT) - CORREGIDO
  Future<void> editarRendicion(
    int idRendicion,
    String proposito,
    int monto,
  ) async {
    _setLoading(true);
    try {
      // 1. Obtener Token
      final token = await AuthService.getToken();

      // 2. URL (Usamos /rendiciones/ plural para ser consistentes con el delete)
      final url = Uri.parse('${AppConstants.apiUrl}/rendiciones/$idRendicion');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({'proposito': proposito, 'monto_entregado': monto}),
      );

      if (response.statusCode == 200) {
        // Recargar toda la lista para actualizar la UI
        await cargarMisRendiciones();
      } else {
        throw Exception('Error al editar: ${response.body}');
      }
    } catch (e) {
      print("Error editando: $e");
      rethrow; // Re-lanzamos para que el Dialog muestre el error
    } finally {
      _setLoading(false);
    }
  }

  // 4. BORRAR RENDICIÓN (DELETE)
  Future<bool> borrarRendicion(int idRendicion) async {
    _setLoading(true);

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('${AppConstants.apiUrl}/rendiciones/$idRendicion');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _rendiciones.removeWhere((r) => r.idRendicion == idRendicion);
        _setLoading(false); // Importante cerrar carga aquí antes del return
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print("Error al borrar rendición: $e");
      _setLoading(false);
      return false;
    }
  }

  // 5. ENVIAR A REVISIÓN
  Future<bool> enviarRendicion(int idRendicion) async {
    _setLoading(true);

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(
        '${AppConstants.apiUrl}/rendiciones/$idRendicion/enviar',
      );

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await cargarMisRendiciones();
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // --- SECCIÓN ADMIN ---

  Future<void> cargarHistorialGlobal() async {
    _setLoading(true);

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('${AppConstants.apiUrl}/admin/historial');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _historialGlobal = data.map((x) => RendicionModel.fromJson(x)).toList();
      } else {
        print("Error Server: ${response.statusCode}");
      }
    } catch (e) {
      print("Error Provider: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarBandejaValidacion() async {
    _setLoading(true);

    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception("No hay token de autenticación");

      final url = Uri.parse('${AppConstants.apiUrl}/admin/rendiciones');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _rendicionesPorValidar = data
            .map((json) => RendicionModel.fromJson(json))
            .toList();
      } else {
        _rendicionesPorValidar = [];
      }
    } catch (e) {
      print("❌ Excepción en cargarBandejaValidacion: $e");
      _rendicionesPorValidar = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> enviarValidacionAdmin(
    int idRendicion,
    List<Map<String, dynamic>> evaluaciones,
  ) async {
    _setLoading(true);

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(
        '${AppConstants.apiUrl}/admin/rendiciones/$idRendicion/validar',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'evaluaciones': evaluaciones}),
      );

      if (response.statusCode == 200) {
        await cargarBandejaValidacion();
        return true;
      } else {
        print("Error validación: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error provider validación: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> pagarRendicion(int idRendicion, String filePath) async {
    _setLoading(true);

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(
        '${AppConstants.apiUrl}/admin/rendiciones/$idRendicion/pagar',
      );

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath('comprobante', filePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await cargarBandejaValidacion();
        return true;
      } else {
        print("Error pago: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Excepción pago: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> actualizarContadorPendientes() async {
    try {
      final token = await AuthService.getToken();
      // Ajusta la URL a tu endpoint nuevo
      final url = Uri.parse('${AppConstants.apiUrl}/admin/pendientes/count');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cantidadPendientes = data['cantidad'] ?? 0;
        notifyListeners(); // ¡Avisar a la UI!
      }
    } catch (e) {
      print("Error contando pendientes: $e");
    }
  }
}
