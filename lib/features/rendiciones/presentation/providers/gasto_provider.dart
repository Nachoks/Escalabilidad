import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/core/constants/app_constants.dart';
import 'package:somnolence_app/core/services/auth_services.dart';
import 'package:somnolence_app/features/rendiciones/data/models/gasto_model.dart';

class GastoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<GastoModel> _gastos = [];
  bool _isLoading = false;

  List<GastoModel> get gastos => _gastos;
  bool get isLoading => _isLoading;

  // 1. CARGAR GASTOS DE UNA RENDICIÓN
  Future<void> cargarGastos(int idRendicion) async {
    _isLoading = true;
    _gastos = []; // Limpiamos para evitar parpadeos de datos viejos
    notifyListeners();

    try {
      final response = await _apiService.get('/rendiciones/$idRendicion');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['gastos'] != null) {
          final List<dynamic> lista = data['gastos'];
          _gastos = lista.map((g) => GastoModel.fromJson(g)).toList();
        }
      }
    } catch (e) {
      print('Error cargando gastos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. CREAR GASTO (Solo datos de texto)
  Future<bool> crearGasto({
    required int idRendicion,
    required String fecha,
    required String monto,
    required String numDocumento,
    required String tipoDoc,
    required String detalle,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        "id_rendicion": idRendicion,
        "fecha": fecha,
        "monto": int.parse(monto),
        "num_documento": numDocumento,
        "tipo_documento": tipoDoc,
        "detalle": detalle,
      };

      final response = await _apiService.post('/gastos', body);

      if (response.statusCode == 201) {
        await cargarGastos(idRendicion); // Recargar lista
        return true;
      } else {
        print("Error creando gasto: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Excepción creando gasto: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. SUBIR EVIDENCIA (MÓVIL)
  Future<bool> subirEvidencia(
    int idGasto,
    int idRendicion,
    String filePath,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final streamResponse = await _apiService.postMultipart(
        '/gastos/archivo',
        {'id_gasto': idGasto.toString()},
        filePath,
      );
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await cargarGastos(idRendicion); // Recargar para ver el cambio de icono
        return true;
      } else {
        print("Error subiendo evidencia: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Excepción subiendo evidencia: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3.5 SUBIR EVIDENCIA (WEB) - CORREGIDO
  Future<bool> subirEvidenciaWeb(
    int idGasto,
    int idRendicion,
    Uint8List bytes,
    String fileName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();

      // CORRECCIÓN 1: La ruta exacta que usa tu Laravel
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiUrl}/gastos/archivo'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // CORRECCIÓN 2: Enviamos el ID del gasto en el cuerpo de la petición (como en el móvil)
      request.fields['id_gasto'] = idGasto.toString();

      // Añadimos el archivo desde los bytes
      request.files.add(
        http.MultipartFile.fromBytes('archivo', bytes, filename: fileName),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recargamos los gastos para ver la nueva foto
        await cargarGastos(idRendicion);
        return true;
      } else {
        print("Error subiendo evidencia web: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Excepción subiendo evidencia web: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. ELIMINAR GASTO
  Future<bool> eliminarGastoCompleto(int idGasto) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('${AppConstants.apiUrl}/gastos/$idGasto');

      print("--- INTENTANDO BORRAR GASTO ---");
      print("URL: $url");
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print("STATUS: ${response.statusCode}");
      print("ERROR BODY: ${response.body}");
      if (response.statusCode == 200) {
        // Borramos de la lista local
        _gastos.removeWhere((g) => g.idGasto == idGasto);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error al borrar gasto: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 5. ELIMINAR EVIDENCIA
  Future<bool> eliminarEvidencia(int idGasto, int idRendicion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('${AppConstants.apiUrl}/gastos/$idGasto/archivo');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final index = _gastos.indexWhere((g) => g.idGasto == idGasto);

        if (index != -1) {
          final gastoViejo = _gastos[index];

          final gastoNuevo = GastoModel(
            idGasto: gastoViejo.idGasto,
            idRendicion: gastoViejo.idRendicion,
            fecha: gastoViejo.fecha,
            monto: gastoViejo.monto,
            numDocumento: gastoViejo.numDocumento,
            tipoDocumento: gastoViejo.tipoDocumento,
            detalle: gastoViejo.detalle,
            estado: gastoViejo.estado,
            comentario: gastoViejo.comentario,
            fotos: [], // FORZAMOS QUE NO TENGA FOTOS
          );

          _gastos[index] = gastoNuevo;
        }

        _isLoading = false;
        notifyListeners();

        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error al eliminar: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
