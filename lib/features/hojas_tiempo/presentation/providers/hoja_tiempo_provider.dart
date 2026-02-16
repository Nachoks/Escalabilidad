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
    _isLoading = true;
    notifyListeners();

    try {
      final exito = await _service.guardarDia(idHojaDiaria, data);

      // Si se guardó bien, recargamos la semana para ver el día actualizado
      if (exito && _hojaSeleccionada != null) {
        await cargarDetalleHoja(_hojaSeleccionada!.idHojaSemana!);
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
}
