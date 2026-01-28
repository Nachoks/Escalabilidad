import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// 1. IMPORT NUEVO
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/auth/presentation/screens/login_screen.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import 'package:somnolence_app/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'core/api/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INICIO CÓDIGO NUEVO: FORZAR CANAL ANDROID ---
  // Esto obliga al teléfono a mostrar el menú de notificaciones en Ajustes
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'onesignal_default_channel', // ID exacto que usa OneSignal
    'Notificaciones Generales', // Nombre visible en Ajustes
    description: 'Avisos de rendiciones y pagos',
    importance: Importance.high,
  );

  // Inicialización mínima requerida para crear el canal
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Crear el canal físicamente en el sistema
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
  // --- FIN CÓDIGO NUEVO ---

  // INICIALIZACIÓN DE ONESIGNAL
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("e5cdf0ea-ed14-4bd4-a2e4-e0daee698f53");

  await ApiService.inicializarConexion();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminUsersProvider()),
        ChangeNotifierProvider(create: (_) => ServicioProvider()),
        ChangeNotifierProvider(
          create: (_) => ClienteProvider()..cargarClientes(),
        ),
        ChangeNotifierProvider(create: (_) => RendicionesProvider()),
        ChangeNotifierProvider(create: (_) => GastoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro Control de Conduccion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF35F34)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Volvemos al código limpio sin diagnósticos visuales exagerados
  // ya que sabemos que el ID sí se genera.

  @override
  void initState() {
    super.initState();
    _iniciarApp();
  }

  Future<void> _iniciarApp() async {
    // 1. Pedir permiso explícitamente
    // Al haber creado el canal arriba, Android ya sabe dónde poner este permiso
    await OneSignal.Notifications.requestPermission(true);

    await Future.delayed(const Duration(seconds: 2));
    _checkSession();
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await ApiService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      final userData = await ApiService.getUsuarioLocal();
      if (userData != null && userData.isNotEmpty) {
        final user = User.fromJson(userData);
        final authProvider = context.read<AuthProvider>();
        authProvider.setUser(user);

        if (OneSignal.User.pushSubscription.id != null) {
          await authProvider.registrarDispositivoEnBackend(user.id.toString());
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeDashboardScreen()),
        );
      } else {
        _irAlLogin();
      }
    } else {
      _irAlLogin();
    }
  }

  void _irAlLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 165, 148),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/LOGO.png'),
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'Inversiones',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Arenas & Arenas',
              style: TextStyle(fontSize: 24, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
