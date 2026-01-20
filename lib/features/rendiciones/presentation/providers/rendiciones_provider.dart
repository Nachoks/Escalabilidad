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

  // 3. BORRAR RENDICIÓN (DELETE)
  Future<bool> borrarRendicion(int idRendicion) async {
    _isLoading = true;
    notifyListeners();

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
        // Actualización Optimista: Quitamos de la lista local
        _rendiciones.removeWhere((r) => r.idRendicion == idRendicion);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error al borrar rendición: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ... dentro de RendicionesProvider ...

  Future<bool> enviarRendicion(int idRendicion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(
        '${AppConstants.apiUrl}/rendiciones/$idRendicion/enviar',
      );

      final response = await http.put(
        // Usamos PUT según tus rutas
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Actualizar estado localmente sin recargar todo
        final index = _rendiciones.indexWhere(
          (r) => r.idRendicion == idRendicion,
        );
        if (index != -1) {
          // Creamos una copia con el nuevo estado
          // Nota: RendicionModel debe tener copyWith o crealo manual
          // Aquí lo hacemos manual para el ejemplo rápido:
          //final vieja = _rendiciones[index];
          // Asumimos que tienes un constructor o setters, o recreamos:
          // Esto es solo visual, al recargar se trae todo bien.
          // Para simplificar, recargaremos la lista completa al final.
        }

        // Recargar lista para asegurar sincronía
        await cargarMisRendiciones();

        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarHistorialGlobal() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token =
          await AuthService.getToken(); // Asegúrate de tener tu servicio de auth
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
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarBandejaValidacion() async {
    // 1. Activamos el estado de carga
    _isLoading = true;
    notifyListeners();

    try {
      // 2. Obtenemos el token de seguridad
      final token = await AuthService.getToken();
      if (token == null) throw Exception("No hay token de autenticación");

      // 3. Llamamos al endpoint que definiste en api.php
      final url = Uri.parse('${AppConstants.apiUrl}/admin/rendiciones');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // 4. Procesamos la respuesta
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Convertimos el JSON a objetos RendicionModel
        _rendicionesPorValidar = data
            .map((json) => RendicionModel.fromJson(json))
            .toList();

        print(
          "✅ Bandeja cargada: ${_rendicionesPorValidar.length} rendiciones.",
        );
      } else {
        print(
          "❌ Error al cargar bandeja: ${response.statusCode} - ${response.body}",
        );
        _rendicionesPorValidar = []; // Limpiamos en caso de error
      }
    } catch (e) {
      print("❌ Excepción en cargarBandejaValidacion: $e");
      _rendicionesPorValidar = [];
    } finally {
      // 5. Desactivamos carga y notificamos a la vista
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ENVIAR VALIDACIÓN MASIVA ---
  Future<bool> enviarValidacionAdmin(
    int idRendicion,
    List<Map<String, dynamic>> evaluaciones,
  ) async {
    _isLoading = true;
    notifyListeners();

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
        // Si fue exitoso, recargamos la bandeja para que desaparezca de "Pendientes"
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
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- PAGAR RENDICIÓN (SUBIR COMPROBANTE) ---
  Future<bool> pagarRendicion(int idRendicion, String filePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(
        '${AppConstants.apiUrl}/admin/rendiciones/$idRendicion/pagar',
      );

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Adjuntar archivo
      request.files.add(
        await http.MultipartFile.fromPath('comprobante', filePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Recargar la lista para que desaparezca de "Por Pagar"
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
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... otros métodos y propiedades ...
}
