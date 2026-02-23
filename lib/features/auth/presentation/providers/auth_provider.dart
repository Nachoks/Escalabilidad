// Archivo: auth_provider.dart
import 'package:flutter/foundation.dart';
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
    try {
      // 1. PRIMERO: Desconectar OneSignal del celular
      // Esto le quita la etiqueta de "Usuario X" al dispositivo
      await OneSignal.logout();

      // 2. SEGUNDO: Avisar al Servidor (Laravel)
      // Esto borra el ID de la base de datos (con el cambio que hiciste en PHP)
      await ApiService.logout();
    } catch (e) {
      // Si falla internet o el servidor, no importa, seguimos cerrando sesión local
      print("Error avisando logout al servidor: $e");
    } finally {
      // 3. TERCERO: Borrar usuario local y actualizar UI (Siempre se ejecuta)
      _currentUser = null;
      notifyListeners();
    }
  }
  // En AuthProvider.dart

  Future<void> registrarDispositivoEnBackend(String idUsuarioLaravel) async {
    if (kIsWeb) {
      print("🌐 Modo Web detectado: Saltando registro de OneSignal.");
      return; // Sale inmediatamente y deja que el Login avance
    }

    print("🟦 [1] Configurando OneSignal para usuario: $idUsuarioLaravel");

    try {
      // 2. LOGIN (Vincular usuario) - Esto ya es seguro porque sabemos que es celular
      OneSignal.login(idUsuarioLaravel);

      // 3. REVISAR SI YA TENEMOS EL ID (Caso ideal)
      String? currentId = OneSignal.User.pushSubscription.id;

      if (currentId != null && currentId.isNotEmpty) {
        print("✅ ID disponible inmediatamente: $currentId");
        await _enviarALaravel(currentId);
      } else {
        print("⏳ ID no disponible aún. Activando OBSERVER (Espía)...");

        // 4. ACTIVAR EL ESPÍA (Observer)
        OneSignal.User.pushSubscription.addObserver((state) {
          print("👀 El estado de OneSignal cambió...");
          var newId = state.current.id;

          if (newId != null && newId.isNotEmpty) {
            print("🎉 ¡EL ESPÍA ENCONTRÓ EL ID!: $newId");
            _enviarALaravel(newId);
          }
        });
      }
    } catch (e) {
      print("❌ Error configurando OneSignal: $e");
    }
  }

  // Función auxiliar para no repetir código y validar antes de enviar
  Future<void> _enviarALaravel(String oneSignalId) async {
    if (oneSignalId.isEmpty) return;

    try {
      print("🚀 Enviando ID a Laravel: $oneSignalId");
      final api = ApiService();

      final response = await api.post('/update-device', {
        'onesignal_id': oneSignalId,
      });

      if (response.statusCode == 200) {
        print("✅ ¡ÉXITO! Dispositivo registrado en BD.");
      } else {
        print(
          "⚠️ Laravel respondió error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Error de conexión al enviar ID: $e");
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
