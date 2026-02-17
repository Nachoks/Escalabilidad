import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somnolence_app/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hoja_tiempo_model.dart';

class HojaTiempoService {
  String get _baseUrl {
    String url = AppConstants.apiUrl;
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return url;
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    // CAMBIO AQUI: de 'auth_token' a 'token'
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // --- DROPDOWNS ---
  Future<List<dynamic>> obtenerClientes() async {
    final url = Uri.parse('$_baseUrl/dropdowns/clientes');
    debugPrint("=== DEBUG API ===");
    debugPrint("1. Llamando a: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      debugPrint("2. Status Code: ${response.statusCode}");
      debugPrint("3. Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("4. ERROR DE CONEXIÓN: $e");
      return [];
    }
  }

  Future<List<dynamic>> obtenerServicios(String idCliente) async {
    final url = Uri.parse('$_baseUrl/dropdowns/clientes/$idCliente/servicios');
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    return [];
  }

  Future<List<dynamic>> obtenerOcs(String idServicio) async {
    final url = Uri.parse('$_baseUrl/dropdowns/servicios/$idServicio/ocs');
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    return [];
  }

  // --- OPERACIONES ---
  Future<List<HojaTiempoSemana>> obtenerMisHojas(int idUsuario) async {
    final url = Uri.parse('$_baseUrl/hoja-tiempo/mis-hojas');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'id_usuario': idUsuario}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => HojaTiempoSemana.fromJson(e)).toList();
    }
    throw Exception('Error al cargar historial de hojas');
  }

  Future<bool> crearSemana({
    required int idUsuario,
    required int idServicio,
    required int idOcCliente,
    required String fecha,
    required int numeroHct,
  }) async {
    final url = Uri.parse('$_baseUrl/hoja-tiempo/crear');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'id_usuario': idUsuario,
        'id_servicio': idServicio,
        'id_oc_cliente': idOcCliente,
        'fecha': fecha,
        'numero_hct': numeroHct,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al crear la semana');
    }
  }

  Future<HojaTiempoSemana> obtenerDetalleHoja(int idHojaSemana) async {
    final url = Uri.parse('$_baseUrl/hoja-tiempo/$idHojaSemana/detalle');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return HojaTiempoSemana.fromJson(data);
    }
    throw Exception('Error al cargar el detalle de la hoja');
  }

  Future<bool> guardarDia(int idHojaDiaria, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/hoja-tiempo/dia/$idHojaDiaria/guardar');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint("Error al guardar día: ${response.body}");
      throw Exception('Error al guardar el día');
    }
  }

  Future<bool> enviarSemana(int idHojaSemana, String observacion) async {
    final url = Uri.parse('$_baseUrl/hoja-tiempo/$idHojaSemana/enviar');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'observacion': observacion}),
    );

    return response.statusCode == 200;
  }

  Future<List<HojaTiempoSemana>> obtenerPendientesAdmin() async {
    final url = Uri.parse('$_baseUrl/admin/hoja-tiempo/pendientes');
    debugPrint("=== DEBUG PENDIENTES ADMIN ===");
    debugPrint("Llamando a: $url");

    try {
      final response = await http.get(url, headers: await _getHeaders());

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((e) => HojaTiempoSemana.fromJson(e)).toList();
      } else {
        // Ahora si falla, nos mostrará el mensaje real de Laravel en pantalla
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Error desconocido del servidor',
        );
      }
    } catch (e) {
      debugPrint("Error atrapado: $e");
      throw Exception('Error al cargar hojas pendientes: $e');
    }
  }

  Future<bool> evaluarHoja(
    int idHojaSemana,
    String estado,
    String observacion,
  ) async {
    final url = Uri.parse('$_baseUrl/admin/hoja-tiempo/$idHojaSemana/evaluar');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'estado': estado, 'observacion': observacion}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al evaluar la hoja de tiempo');
    }
  }
}
