import 'package:flutter/material.dart';
import '../../data/models/hoja_tiempo_model.dart';
import '../../data/services/hoja_tiempo_service.dart';

class HojaTiempoProvider extends ChangeNotifier {
  final HojaTiempoService _service = HojaTiempoService();

  HojaTiempoSemana? _hojaSeleccionada;
  HojaTiempoSemana? get hojaSeleccionada => _hojaSeleccionada;

  List<HojaTiempoSemana> _hojas = [];
  List<HojaTiempoSemana> _adminPendientes = [];
  List<HojaTiempoDiaria> _adminPendientesDiarias =
      []; // <--- NUEVA LISTA PARA DÍAS
  List<HojaTiempoSemana> _adminHistorial = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<HojaTiempoSemana> get hojas => _hojas;
  List<HojaTiempoSemana> get adminPendientes => _adminPendientes;
  List<HojaTiempoDiaria> get adminPendientesDiarias =>
      _adminPendientesDiarias; // <--- NUEVO GETTER
  List<HojaTiempoSemana> get adminHistorial => _adminHistorial;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 👇 NUEVO: Getter para contar todas las tareas pendientes (Semanas + Días) 👇
  int get cantidadPendientes =>
      _adminPendientes.length + _adminPendientesDiarias.length;

  // 👇 NUEVO: Método para actualizar los contadores en segundo plano (para la burbuja roja) 👇
  Future<void> actualizarContadorPendientes() async {
    try {
      // Hacemos ambas peticiones al mismo tiempo para que sea más rápido
      final resultados = await Future.wait([
        _service.obtenerPendientesAdmin(),
        _service.obtenerPendientesDiariasAdmin(),
      ]);

      _adminPendientes = resultados[0] as List<HojaTiempoSemana>;
      _adminPendientesDiarias = resultados[1] as List<HojaTiempoDiaria>;

      notifyListeners(); // Le avisa al menú que dibuje el número
    } catch (e) {
      debugPrint("Error actualizando contador de hojas de tiempo: $e");
    }
  }

  // --- MÉTODOS TÉCNICO ---

  Future<void> cargarHojas(int idUsuario) async {
    debugPrint("=== INICIANDO CARGA MIS HOJAS ===");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hojas = await _service.obtenerMisHojas(idUsuario);
      debugPrint("=== MIS HOJAS CARGADAS ÉXITO: ${_hojas.length} ===");
    } catch (e) {
      debugPrint("=== ERROR AL CARGAR MIS HOJAS: $e ===");
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
      _errorMessage = "Error al cargar el detalle de la hoja";
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
    // 🚨 Mantenemos la lógica de no usar _isLoading para no destruir la vista de edición 🚨
    try {
      final exito = await _service.guardarDia(idHojaDiaria, data);
      return exito;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    }
  }

  // --- NUEVO: ENVIAR UN SOLO DÍA ---
  Future<bool> enviarDia(int idHojaDiaria, int idHojaSemana) async {
    _isLoading = true;
    notifyListeners();

    try {
      final exito = await _service.enviarDia(idHojaDiaria);
      if (exito) {
        // Recargamos el detalle de la hoja para ver el día bloqueado como "Enviado"
        await cargarDetalleHoja(idHojaSemana);
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

  Future<bool> enviarSemana(int idHojaSemana, String observacion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final exito = await _service.enviarSemana(idHojaSemana, observacion);
      if (exito) {
        await cargarDetalleHoja(idHojaSemana);
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

  // --- MÉTODOS ADMINISTRACIÓN ---

  Future<void> cargarPendientesAdmin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _adminPendientes = await _service.obtenerPendientesAdmin();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NUEVO: CARGAR DÍAS PENDIENTES ---
  Future<void> cargarPendientesDiariasAdmin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _adminPendientesDiarias = await _service.obtenerPendientesDiariasAdmin();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarHistorialAdmin() async {
    debugPrint("=== INICIANDO CARGA HISTORIAL ADMIN ===");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _adminHistorial = await _service.obtenerHistorialAdmin();
      debugPrint("=== HISTORIAL ADMIN CARGADO: ${_adminHistorial.length} ===");
    } catch (e) {
      debugPrint("=== ERROR HISTORIAL: $e ===");
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> evaluarHojaAdmin({
    required int idHojaSemana,
    required String estado,
    required String observacion,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exito = await _service.evaluarHoja(
        idHojaSemana,
        estado,
        observacion,
      );
      if (exito) {
        // Refrescamos las listas para mantener la consistencia
        await cargarPendientesAdmin();
        await cargarPendientesDiariasAdmin(); // Refrescar diarios también
        await cargarHistorialAdmin();
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

  // --- NUEVO: EVALUAR UN SOLO DÍA ---
  Future<bool> evaluarDiaAdmin({
    required int idHojaDiaria,
    required String estado,
    required String observacion,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exito = await _service.evaluarDia(
        idHojaDiaria,
        estado,
        observacion,
      );
      if (exito) {
        // Refrescamos las listas para mantener la consistencia
        await cargarPendientesDiariasAdmin();
        await cargarPendientesAdmin();
        await cargarHistorialAdmin();
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
