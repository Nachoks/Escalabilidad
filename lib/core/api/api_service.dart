import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somnolence_app/core/constants/app_constants.dart';
import 'package:somnolence_app/features/admin/data/models/has_guia_model.dart';
import 'package:somnolence_app/main.dart';

class ApiService {
  static const String baseUrl = 'https://iaaspa.synology.me:8090/api';
  //static const String baseUrl = 'https://192.168.0.24:8090/api';
  // static const String baseUrl = 'https://localhost:8090/api';

  static Future<void> inicializarConexion() async {
    print("🚀 API Configurada en: $baseUrl");
  }

  // Login
  static Future<Map<String, dynamic>> login(
    String usuario,
    String password,
  ) async {
    Future<http.Response> _hacerPeticion() {
      return http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre_usuario': usuario, 'password': password}),
      );
    }

    try {
      print("🔑 Conectando a: $baseUrl/login");
      http.Response response;

      try {
        response = await _hacerPeticion().timeout(const Duration(seconds: 10));
      } catch (e) {
        print("⚠️ Timeout. Reintentando...");
        response = await _hacerPeticion().timeout(const Duration(seconds: 10));
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Error: Respuesta inválida del servidor ($baseUrl)',
        };
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('usuario', jsonEncode(data['usuario']));
        return {
          'success': true,
          'message': data['message'],
          'usuario': data['usuario'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Credenciales incorrectas',
        };
      }
    } catch (e) {
      print("ERROR CRÍTICO: $e");
      return {
        'success': false,
        'message': 'Error de conexión con el servidor seguro.',
      };
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Intentar avisar al servidor (Best Effort)
    try {
      final token = prefs.getString('token');
      if (token != null) {
        // No esperamos el await mucho tiempo o ignoramos error si el token ya no existe
        await http
            .post(
              Uri.parse('$baseUrl/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(
              const Duration(seconds: 2),
            ); // Timeout corto para no trabar la app
      }
    } catch (e) {
      print(
        "Error avisando logout al servidor (posiblemente token ya vencido): $e",
      );
    } finally {
      // 2. Limpieza Local (OBLIGATORIO)
      // Esto se ejecuta sí o sí, haya error en el servidor o no.
      await prefs.clear(); // O remove('token') y remove('usuario')

      // 3. Redirección Forzada (LA CLAVE)
      // Usamos la llave global para navegar sin contexto
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login', // Asegúrate que esta ruta esté definida en tu main.dart
        (route) => false, // Elimina todas las pantallas anteriores de la pila
      );
    }
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Obtener Usuario Local
  static Future<Map<String, dynamic>?> getUsuarioLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioStr = prefs.getString('usuario');
    if (usuarioStr != null) return jsonDecode(usuarioStr);
    return null;
  }

  // Verificar si el token es válido en el servidor (no solo que exista localmente)
  static Future<bool> verificarTokenValido() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return false;

      // Hacemos una petición ligera, por ejemplo a /user o /perfil
      // Ajusta la URL a una ruta que requiera autenticación en tu backend
      final url = Uri.parse('${AppConstants.apiUrl}/user');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 5),
          ); // Timeout corto para no demorar el inicio

      if (response.statusCode == 200) {
        return true; // El token es real y el servidor lo acepta
      } else {
        return false; // El token existe localmente pero el servidor lo rechaza (401)
      }
    } catch (e) {
      // Si hay error de conexión (servidor apagado), asumimos false por seguridad
      // o true si quieres permitir modo offline (depende de tu negocio)
      print("Error verificando token: $e");
      return false;
    }
  }
  // =============================================================
  // MÉTODOS DE NEGOCIO
  // =============================================================

  // Obtener Patentes de Vehículos
  static Future<List<String>> obtenerPatentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$baseUrl/vehiculos/patentes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obtener todos los usuarios (Admin)
  static Future<List<Map<String, dynamic>>> obtenerTodosLosUsuarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Error al obtener usuarios: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  // Obtener Empresas para Dropdown
  static Future<List<dynamic>> obtenerEmpresas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/empresas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error API empresas: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Excepción obteniendo empresas: $e");
      return [];
    }
  }

  // Crear Usuario
  static Future<Map<String, dynamic>> crearUsuario(
    Map<String, dynamic> datos,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(datos),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Usuario creado exitosamente'};
      } else if (response.statusCode == 422) {
        final errors = data['errors'];
        String mensajeError = data['message'];

        if (errors != null && errors is Map) {
          mensajeError = errors.values.first[0];
        }
        return {'success': false, 'message': mensajeError};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Cambiar Estado (PUT)
  static Future<bool> cambiarEstadoUsuario(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/admin/usuarios/$id/estado'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Excepción cambiando estado: $e");
      return false;
    }
  }

  // Editar Usuario (PUT)
  static Future<bool> actualizarUsuario(
    int id,
    Map<String, dynamic> datos,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/admin/usuarios/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(datos),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Excepción actualizando usuario: $e");
      return false;
    }
  }

  // Cambiar Password
  static Future<Map<String, dynamic>> cambiarPassword(
    String actual,
    String nueva,
    String confirmacion,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'current_password': actual,
          'new_password': nueva,
          'new_password_confirmation': confirmacion,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar contraseña',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar Información de Servicio
  static Future<bool> updateServiceInfo(
    int id,
    String? fechaInicio,
    String facturacion,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/servicios/$id/info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fecha_inicio': fechaInicio,
          'facturacion': facturacion,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updateServiceInfo: $e");
      return false;
    }
  }

  // Finalizar Servicio
  static Future<bool> finalizarServicio(int id, String fechaTermino) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/servicios/$id/finalizar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'fecha_termino': fechaTermino}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error finalizarServicio: $e");
      return false;
    }
  }

  // Agregar OC a Servicio
  // Modifica esta función para que devuelva int? (el ID)
  static Future<int?> agregarOc(int idServicio, String codigoOc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/servicios/$idServicio/ocs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'cod_oc_cliente': codigoOc}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // AQUÍ ESTÁ LA CLAVE: Devolvemos el ID real de la base de datos
        // Asegúrate que tu backend devuelva 'data' y dentro el objeto con 'id_oc_cliente'
        return data['data']['id_oc_cliente'];
      }
      return null;
    } catch (e) {
      print("Error agregarOc: $e");
      return null;
    }
  }

  // Eliminar OC
  static Future<bool> eliminarOc(int idOc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Ruta basada en tu OcClienteController::destroy
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/ocs/$idOc',
        ), // Asegúrate que esta ruta exista en routes/api.php
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error eliminando OC: $e");
      return false;
    }
  }

  // Agregar HAS a Servicio
  static Future<List<HasGuiaModel>> getHasByOc(int idOc) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print("🔍 BUSCANDO HAS EN: $baseUrl/ocs/$idOc/has"); // LOG DE DEBUG

      final response = await http.get(
        Uri.parse('$baseUrl/ocs/$idOc/has'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(
        "📥 RESPUESTA HAS (${response.statusCode}): ${response.body}",
      ); // LOG DE DEBUG

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data;

        // VERIFICACIÓN DE FORMATO (Aquí estaba el problema de visualización)
        if (decoded is List) {
          data = decoded; // El backend mandó directamente [...]
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data']; // El backend mandó {"data": [...]}
        } else {
          print("⚠️ Formato de respuesta no reconocido para HAS");
          return [];
        }

        return data.map((e) => HasGuiaModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error CRÍTICO en getHasByOc: $e");
      return [];
    }
  }

  // SUBIR IMAGEN A HAS
  static Future<bool> subirArchivoHas(int idHas, File archivo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Ajusta la URL si es necesario
      final uri = Uri.parse('$baseUrl/has/$idHas/archivo');

      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // 'archivo' es el nombre que espera el controlador: $request->file('archivo')
      request.files.add(
        await http.MultipartFile.fromPath('archivo', archivo.path),
      );

      print('📤 Subiendo archivo a HAS ID: $idHas');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📥 Respuesta Server: ${response.statusCode} - ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("❌ Error subiendo archivo: $e");
      return false;
    }
  }

  // Agregar HAS (Con logs de error detallados)
  static Future<bool> agregarHas(int idOc, String codigoHas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('$baseUrl/ocs/$idOc/has');
      print("📤 ENVIANDO HAS A: $url");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'cod_has_guia': codigoHas}),
      );

      print("RESPUESTA AGREGAR HAS: ${response.statusCode} - ${response.body}");

      // Aceptamos 200, 201 y también manejamos errores comunes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Error CRÍTICO al agregar HAS: $e");
      return false;
    }
  }

  // Eliminar HAS
  static Future<bool> deleteHas(int idHas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('$baseUrl/has/$idHas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error borrando has: $e");
      return false;
    }
  }

  // ELIMINAR SOLO LA IMAGEN DE LA HAS
  static Future<bool> deleteArchivoHas(int idHas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('$baseUrl/has/$idHas/archivo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error borrando archivo: $e");
      return false;
    }
  }

  // Reactivar Servicio
  static Future<bool> reactivarServicio(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('$baseUrl/servicios/$id/reactivar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error reactivarServicio: $e");
      return false;
    }
  }

  // Editar Cliente
  static Future<bool> editCliente(int id, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.put(
        Uri.parse('$baseUrl/clientes/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // NUEVA FUNCIÓN PARA SUBIR ARCHIVOS DESDE LA WEB
  static Future<bool> subirArchivoHasWeb(
    int idHas,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Asegúrate de poner tu URL correcta aquí
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/has/$idHas/archivo'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // La diferencia clave: usamos fromBytes en lugar de fromPath
      request.files.add(
        http.MultipartFile.fromBytes(
          'archivo', // El nombre del campo que espera tu Laravel en el Request
          bytes,
          filename: fileName,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Error subiendo archivo web: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Excepción al subir archivo web: $e");
      return false;
    }
  }

  // =============================================================
  // MÉTODOS GENÉRICOS
  // =============================================================

  // GET Genérico
  Future<http.Response> get(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse('$baseUrl$endpoint');

      return await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      print('❌ Error en GET Genérico: $e');
      rethrow;
    }
  }

  // POST Genérico
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse('$baseUrl$endpoint');

      return await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      print('❌ Error en POST Genérico: $e');
      rethrow;
    }
  }

  // PUT Genérico
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse('$baseUrl$endpoint');

      return await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      print('❌ Error en PUT Genérico: $e');
      rethrow;
    }
  }

  // DELETE Genérico
  Future<http.Response> delete(String endpoint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse('$baseUrl$endpoint');

      return await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      print('❌ Error en DELETE Genérico: $e');
      rethrow;
    }
  }

  // POST Multipart Genérico
  Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields,
    String? filePath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uri = Uri.parse('$baseUrl$endpoint');

      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll(fields);

      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('archivo', filePath),
        );
      }

      print('📡 UPLOADING a $uri con archivo: $filePath');
      return await request.send();
    } catch (e) {
      print('❌ Error en Upload Multipart: $e');
      rethrow;
    }
  }
}
