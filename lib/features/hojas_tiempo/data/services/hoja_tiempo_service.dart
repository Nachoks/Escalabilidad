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
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("ERROR DE CONEXIÓN: $e");
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

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'id_usuario': idUsuario}),
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(response.body);
          final List data = decoded['data'] ?? [];
          return data.map((e) => HojaTiempoSemana.fromJson(e)).toList();
        } catch (parseError) {
          debugPrint("Error de parseo en misHojas: $parseError");
          throw Exception("Error de lectura de datos (JSON): $parseError");
        }
      } else {
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint("Excepción en obtenerMisHojas: $e");
      rethrow;
    }
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
    throw Exception('Error al cargar el detalle de la hoja: ${response.body}');
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
      throw Exception('Error al guardar el día: ${response.body}');
    }
  }

  // --- NUEVA RUTA: ENVIAR UN SOLO DÍA ---
  Future<bool> enviarDia(int idHojaDiaria) async {
    final url = Uri.parse('$_baseUrl/hoja-tiempo/dia/$idHojaDiaria/enviar');
    final response = await http.post(url, headers: await _getHeaders());

    if (response.statusCode == 200) return true;

    // Intentar extraer el mensaje de error real
    try {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Error al enviar el día');
    } catch (_) {
      throw Exception('Error al enviar el día: ${response.body}');
    }
  }

  Future<bool> enviarSemana(int idHojaSemana, String observacion) async {
    final url = Uri.parse('$_baseUrl/hoja-tiempo/$idHojaSemana/enviar');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'observacion': observacion}),
    );

    if (response.statusCode == 200) return true;
    throw Exception('Error al enviar semana: ${response.body}');
  }

  // --- ADMINISTRACIÓN ---
  Future<List<HojaTiempoSemana>> obtenerPendientesAdmin() async {
    final url = Uri.parse('$_baseUrl/admin/hoja-tiempo/pendientes');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((e) => HojaTiempoSemana.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar pendientes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // --- NUEVA RUTA: OBTENER DÍAS PENDIENTES ---
  Future<List<HojaTiempoDiaria>> obtenerPendientesDiariasAdmin() async {
    // ⚠️ CORRECCIÓN DE LA URL: Quitamos '/admin' para que coincida con routes/api.php
    final url = Uri.parse('$_baseUrl/admin/hoja-tiempo/pendientes-diarias');

    try {
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((e) => HojaTiempoDiaria.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar días pendientes: ${response.body}');
      }
    } catch (e) {
      debugPrint("ERROR AL OBTENER DÍAS PENDIENTES: $e");
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<HojaTiempoSemana>> obtenerHistorialAdmin() async {
    final url = Uri.parse('$_baseUrl/admin/hoja-tiempo/historial');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((e) => HojaTiempoSemana.fromJson(e)).toList();
      } else {
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Excepción al cargar historial: $e');
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
      throw Exception('Error al evaluar: ${response.body}');
    }
  }

  // --- NUEVA RUTA: EVALUAR UN SOLO DÍA ---
  Future<bool> evaluarDia(
    int idHojaDiaria,
    String estado,
    String observacion,
  ) async {
    // ⚠️ CORRECCIÓN DE LA URL: Quitamos '/admin'
    final url = Uri.parse(
      '$_baseUrl/admin/hoja-tiempo/dia/$idHojaDiaria/evaluar',
    );

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'estado': estado, 'observacion': observacion}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al evaluar el día: ${response.body}');
    }
  }
}
