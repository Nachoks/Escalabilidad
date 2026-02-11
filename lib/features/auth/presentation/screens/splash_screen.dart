import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';

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
    // 1. Simular un tiempo mínimo (opcional, para que se vea el logo)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Verificar Token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    // 3. Redirigir
    if (token != null && token.isNotEmpty) {
      // Tiene token -> Vamos al Home (y borramos historial para que no vuelva al splash)
      Navigator.pushReplacementNamed(
        context,
        '/home',
      ); // O tu ruta de dashboard
    } else {
      // No tiene token -> Vamos al Login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Tu color corporativo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tu Logo
            Image.asset(
              'assets/images/logo.png', // Asegúrate que la ruta sea correcta
              width: 150,
            ),
            const SizedBox(height: 20),
            // Un indicador de carga blanco
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
