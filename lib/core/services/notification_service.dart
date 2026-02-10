import 'package:flutter/foundation.dart'; // <--- 1. IMPORTANTE: Para usar kIsWeb
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Tu App ID de OneSignal
  static const String oneSignalAppId = "e5cdf0ea-ed14-4bd4-a2e4-e0daee698f53";

  static Future<void> init() async {
    // 2. BLOQUE DE SEGURIDAD PARA WEB
    // Si estamos en web, salimos inmediatamente para no ejecutar código nativo
    if (kIsWeb) {
      print("⚠️ OneSignal desactivado en Web para evitar errores de plugin.");
      return;
    }

    // 1. Configurar Logs de OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // 2. Inicializar OneSignal
    OneSignal.initialize(oneSignalAppId);

    // 3. Crear el canal de notificación manualmente en Android.
    await _crearCanalAndroid();

    // 4. Solicitar Permiso al usuario
    await OneSignal.Notifications.requestPermission(true);
  }

  /// Crea el canal "onesignal_default_channel" manualmente usando flutter_local_notifications
  static Future<void> _crearCanalAndroid() async {
    // Seguridad extra: Si por alguna razón se llama a esto en web, salimos.
    if (kIsWeb) return;

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Configuración mínima para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Inicializamos el plugin local
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Definimos el canal
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'onesignal_default_channel',
      'Notificaciones Generales',
      description: 'Avisos importantes de la aplicación',
      importance: Importance.high,
    );

    // Creamos el canal
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Método auxiliar para obtener el ID del usuario (Player ID)
  static Future<String?> getOneSignalId() async {
    // 3. SEGURIDAD: En web no hay Player ID, devolvemos null
    if (kIsWeb) return null;

    return OneSignal.User.pushSubscription.id;
  }
}
