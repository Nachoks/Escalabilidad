import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <-- IMPORTANTE
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
// IMPORTANTE: Redirigimos al Dashboard, NO al test directo
import 'package:somnolence_app/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginContent();
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();
  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instancia de Secure Storage
  final _storage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _recordarCredenciales = false; // <-- ESTADO DEL CHECKBOX

  @override
  void initState() {
    super.initState();
    _cargarCredencialesGuardadas(); // Cargar al iniciar la pantalla
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LÓGICA PARA LEER CREDENCIALES ---
  Future<void> _cargarCredencialesGuardadas() async {
    try {
      String? usuarioGuardado = await _storage.read(key: 'saved_username');
      String? passwordGuardada = await _storage.read(key: 'saved_password');

      if (usuarioGuardado != null && passwordGuardada != null) {
        setState(() {
          _usuarioController.text = usuarioGuardado;
          _passwordController.text = passwordGuardada;
          _recordarCredenciales = true;
        });
      }
    } catch (e) {
      print("Error leyendo credenciales seguras: $e");
    }
  }

  // --- LÓGICA DE INICIO DE SESIÓN ---
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text;

    // 1. Ejecutar Login
    final success = await authProvider.login(usuario, password);

    if (!mounted) return;

    if (success) {
      // 2. GUARDAR O BORRAR CREDENCIALES
      if (_recordarCredenciales) {
        await _storage.write(key: 'saved_username', value: usuario);
        await _storage.write(key: 'saved_password', value: password);
      } else {
        await _storage.delete(key: 'saved_username');
        await _storage.delete(key: 'saved_password');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido!'),
          backgroundColor: Colors.green,
        ),
      );

      // --- 🔍 CORRECCIÓN DE BUG: EL USUARIO ERA NULL ---
      User? usuarioParaRegistrar = authProvider.currentUser;

      // Si el provider no tiene el usuario cargado en memoria,
      // lo buscamos urgentemente en el almacenamiento local.
      if (usuarioParaRegistrar == null) {
        print("⚠️ Provider vacío. Buscando usuario en almacenamiento local...");
        final userData = await ApiService.getUsuarioLocal();
        if (userData != null && userData.isNotEmpty) {
          usuarioParaRegistrar = User.fromJson(userData);
          // Actualizamos el provider para que ya no sea null
          authProvider.setUser(usuarioParaRegistrar);
        }
      }

      // Ahora sí, intentamos registrar
      if (usuarioParaRegistrar != null) {
        print(
          "👤 Usuario detectado (ID: ${usuarioParaRegistrar.id}). Iniciando OneSignal...",
        );
        await authProvider.registrarDispositivoEnBackend(
          usuarioParaRegistrar.id.toString(),
        );
      } else {
        print(
          "❌ ERROR CRÍTICO: No se pudo obtener el usuario ni del Login ni de Memoria.",
        );
      }
      // ------------------------------------------------

      // Ir al Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Image(
                    image: AssetImage('assets/images/LOGO.png'),
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ingresa tus credenciales',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  // CAMPO USUARIO
                  TextFormField(
                    controller: _usuarioController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      labelText: 'Nombre de Usuario',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (_) => context.read<AuthProvider>().clearError(),
                    validator: (v) => v!.isEmpty ? 'Ingresa tu usuario' : null,
                  ),
                  const SizedBox(height: 20),

                  // CAMPO CONTRASEÑA
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Ingresa tu contraseña' : null,
                  ),
                  const SizedBox(height: 10),

                  // CHECKBOX RECORDAR CONTRASEÑA
                  Row(
                    children: [
                      Checkbox(
                        value: _recordarCredenciales,
                        activeColor: const Color(0xFFF35F34),
                        onChanged: isLoading
                            ? null
                            : (bool? value) {
                                setState(() {
                                  _recordarCredenciales = value ?? false;
                                });
                              },
                      ),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _recordarCredenciales =
                                      !_recordarCredenciales;
                                });
                              },
                        child: Text(
                          "Recordar credenciales",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // BOTÓN INGRESAR
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF35F34),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(
                      '© 2026 Inversiones Arenas & Arenas',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Versión 1.1',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
