import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
// Importa tus servicios y providers
import 'package:somnolence_app/core/services/notification_service.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/auth/presentation/screens/login_screen.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import 'package:somnolence_app/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  // 1. INICIALIZAR NOTIFICACIONES (Aquí ocurre la magia del canal)
  await NotificationService.init();

  // 2. Inicializar API
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro Control de Conduccion',
      navigatorKey: navigatorKey, // <--- Esto permite la navegación global
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF35F34)),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Pantalla inicial
      // --- AGREGA ESTO ---
      // Definimos los nombres de las rutas para que AuthService las encuentre
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeDashboardScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _iniciarApp();
  }

  Future<void> _iniciarApp() async {
    // Damos un tiempo para que OneSignal termine de conectar
    await Future.delayed(const Duration(seconds: 3));
    _checkSession();
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await ApiService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // Validamos con el servidor
      final tokenEsValido = await ApiService.verificarTokenValido();

      if (!mounted) return;

      if (tokenEsValido) {
        // --- TODO OK ---
        final userData = await ApiService.getUsuarioLocal();
        if (userData != null && userData.isNotEmpty) {
          final user = User.fromJson(userData);
          final authProvider = context.read<AuthProvider>();
          authProvider.setUser(user);

          final osId = OneSignal.User.pushSubscription.id;
          if (osId != null) {
            authProvider.registrarDispositivoEnBackend(user.id.toString());
          }

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeDashboardScreen(),
            ),
          );
        } else {
          _irAlLogin();
        }
      } else {
        // --- TOKEN INVÁLIDO (MIGRATE:FRESH) ---
        print("🚨 Token inválido. Ejecutando Logout...");

        // CORRECCIÓN AQUÍ:
        // Solo llamamos al logout. NO llamamos a _irAlLogin() después.
        // AuthService.logout() ya tiene la redirección interna con navigatorKey.
        await ApiService.logout();

        // ¡NO AGREGUES NADA MÁS AQUÍ!
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
