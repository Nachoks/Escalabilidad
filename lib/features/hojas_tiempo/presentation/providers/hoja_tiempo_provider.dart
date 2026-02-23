import 'package:flutter/material.dart';
import '../../data/models/hoja_tiempo_model.dart';
import '../../data/services/hoja_tiempo_service.dart';

class HojaTiempoProvider extends ChangeNotifier {
  final HojaTiempoService _service = HojaTiempoService();
  HojaTiempoSemana? _hojaSeleccionada;
  HojaTiempoSemana? get hojaSeleccionada => _hojaSeleccionada;

  List<HojaTiempoSemana> _hojas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HojaTiempoSemana> get hojas => _hojas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> cargarHojas(int idUsuario) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hojas = await _service.obtenerMisHojas(idUsuario);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearNuevaSemana({
    required int idUsuario,
    required int idServicio,
    required int idOcCliente,
    required String fecha,
    required int numeroHct,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exito = await _service.crearSemana(
        idUsuario: idUsuario,
        idServicio: idServicio,
        idOcCliente: idOcCliente,
        fecha: fecha,
        numeroHct: numeroHct,
      );

      if (exito) {
        // Recargamos la lista para que aparezca la nueva semana
        await cargarHojas(idUsuario);
      }
      return exito;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarDetalleHoja(int idHojaSemana) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hojaSeleccionada = await _service.obtenerDetalleHoja(idHojaSemana);
    } catch (e) {
      _errorMessage = "Error al cargar los 7 días";
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarDia(
    int idHojaDiaria,
    Map<String, dynamic> data,
  ) async {
    // 🚨 ELIMINAMOS EL _isLoading = true y notifyListeners() DE AQUÍ 🚨
    // Así evitamos que la pantalla de atrás se destruya mientras guardamos.

    try {
      final exito = await _service.guardarDia(idHojaDiaria, data);
      return exito;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    }
  }

  Future<bool> enviarSemana(int idHojaSemana, String observacion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final exito = await _service.enviarSemana(idHojaSemana, observacion);
      if (exito) {
        // Recargamos el detalle para que la vista cambie a verde (Enviada)
        await cargarDetalleHoja(idHojaSemana);
      }
      return exito;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
