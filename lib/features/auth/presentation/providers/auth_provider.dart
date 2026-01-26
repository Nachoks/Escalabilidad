// Archivo: auth_provider.dart

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:somnolence_app/core/api/api_service.dart'; // <--- AJUSTA ESTA RUTA SI ES NECESARIO
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters para que la vista lea el estado
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  // Función de Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Avisa a la vista que empiece a girar el circulito

    try {
      // Llamada a tu ApiService existente
      final result = await ApiService.login(username, password);

      if (result['success']) {
        // Login Exitoso: Guardamos el usuario en nuestro modelo
        _currentUser = User.fromJson(result['usuario']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Login Fallido: Guardamos el mensaje de error
        _errorMessage = result['message'] ?? 'Error desconocido';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Función de Logout
  Future<void> logout() async {
    await ApiService.logout(); // Llama a tu servicio
    _currentUser = null; // Borra el usuario de la memoria
    notifyListeners();
  }

  Future<void> registrarDispositivoEnBackend() async {
    try {
      // Para OneSignal v5+
      String? oneSignalId = OneSignal.User.pushSubscription.id;

      // Si tienes una versión anterior (v3 o v4) usa:
      // var deviceState = await OneSignal.shared.getDeviceState();
      // String? oneSignalId = deviceState?.userId;

      if (oneSignalId != null) {
        print("Actualizando OneSignal ID: $oneSignalId");
        final api = ApiService();
        // Llamamos a tu endpoint de Laravel
        await api.post('/update-device', {'onesignal_id': oneSignalId});
      }
    } catch (e) {
      print("Error registrando dispositivo: $e");
    }
  }

  // Limpiar errores (ej: cuando el usuario empieza a escribir de nuevo)
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
