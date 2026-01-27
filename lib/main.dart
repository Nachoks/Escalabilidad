import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 1. IMPORTAR ONESIGNAL
import 'package:onesignal_flutter/onesignal_flutter.dart';

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
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("e5cdf0ea-ed14-4bd4-a2e4-e0daee698f53");
  OneSignal.Notifications.requestPermission(true);

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
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    final isLoggedIn = await ApiService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      final userData = await ApiService.getUsuarioLocal();
      if (userData != null && userData.isNotEmpty) {
        final user = User.fromJson(userData);

        // Cargar usuario en el Provider
        final authProvider = context.read<AuthProvider>();
        authProvider.setUser(user);

        // --- 3. VINCULAR DISPOSITIVO (CORREGIDO) ---
        // Pasamos el ID del usuario como String para que OneSignal haga Login
        await authProvider.registrarDispositivoEnBackend(user.id.toString());
        // -------------------------------------------

        //Si ya tiene sesión, va al Dashboard
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
