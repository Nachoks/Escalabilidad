import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/main.dart'; // Para acceder al navigatorKey

class HttpHandler {
  static dynamic handleResponse(http.Response response) {
    // Si el servidor dice "No autorizado" (Token inválido o borrado por migrate:fresh)
    if (response.statusCode == 401) {
      // 1. Borramos token local
      ApiService.logout();

      // 2. Redirigimos forzosamente al Login usando la llave global
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login', // Asegúrate que esta sea tu ruta de login
        (route) => false, // Borra todo el historial de navegación
      );

      throw Exception("Sesión expirada. Por favor inicie sesión nuevamente.");
    }

    // Si es exitoso
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Si el cuerpo está vacío, retornamos true o map vacío
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    }

    // Otros errores (400, 500, etc)
    throw Exception("Error ${response.statusCode}: ${response.body}");
  }
}
