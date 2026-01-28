import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Tu App ID de OneSignal
  static const String oneSignalAppId = "e5cdf0ea-ed14-4bd4-a2e4-e0daee698f53";

  static Future<void> init() async {
    // 1. Configurar Logs de OneSignal (para depurar si hace falta)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // 2. Inicializar OneSignal
    OneSignal.initialize(oneSignalAppId);

    // 3. ¡EL TRUCO! Crear el canal de notificación manualmente en Android.
    // Esto obliga a Android 13/14 a mostrar el menú de notificaciones en Ajustes.
    await _crearCanalAndroid();

    // 4. Solicitar Permiso al usuario
    await OneSignal.Notifications.requestPermission(true);
  }

  /// Crea el canal "onesignal_default_channel" manualmente usando flutter_local_notifications
  static Future<void> _crearCanalAndroid() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Configuración mínima para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Inicializamos el plugin local
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Definimos el canal (DEBE coincidir con el ID que OneSignal usa por defecto)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'onesignal_default_channel',
      'Notificaciones Generales', // Nombre visible en Ajustes
      description: 'Avisos importantes de la aplicación',
      importance: Importance.high,
    );

    // Creamos el canal físicamente en el sistema
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Método auxiliar para obtener el ID del usuario (Player ID)
  static Future<String?> getOneSignalId() async {
    return OneSignal.User.pushSubscription.id;
  }
}
