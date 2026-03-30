import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; //DETECTAR LA WEB
import 'package:flutter_localizations/flutter_localizations.dart'; // IMPORTACIÓN DE IDIOMAS
import 'package:somnolence_app/core/services/notification_service.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/auth/presentation/screens/login_screen.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import 'package:somnolence_app/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/providers/hoja_tiempo_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/inventario_provider.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/proveedor_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 AQUÍ ESTÁ LA MAGIA QUE SALVA A LA WEB 👇
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  await NotificationService.init();
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
        ChangeNotifierProvider(create: (_) => HojaTiempoProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()),
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
      title: 'Intranet IAA',
      navigatorKey: navigatorKey, //navegación global
      // CONFIGURACIÓN MUNDIAL DE IDIOMAS PARA FLUTTER
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés (Fallback)
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF35F34)),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Pantalla inicial
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
        await ApiService.logout();
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
