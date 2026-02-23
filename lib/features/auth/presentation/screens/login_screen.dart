import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import 'package:somnolence_app/features/dashboard/presentation/screens/home_dashboard_screen.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // SI ES PANTALLA ANCHA (PC / WEB DESKTOP)
          if (constraints.maxWidth >= 850) {
            return Row(
              children: [
                // PANEL IZQUIERDO CORPORATIVO
                Expanded(
                  flex: 5,
                  child: Container(
                    color: const Color(0xFFF35F34), // Naranjo corporativo
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/LOGO.png',
                            width: 120,
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Intranet Corporativa",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Gestión Administrativa y Operacional",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                // PANEL DERECHO (FORMULARIO)
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                      ), // Ancho máximo del form
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: const _LoginForm(isDesktop: true),
                    ),
                  ),
                ),
              ],
            );
          }
          // SI ES CELULAR
          else {
            return const SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: _LoginForm(isDesktop: false),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final bool isDesktop;
  const _LoginForm({required this.isDesktop});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instancia de Secure Storage
  final _storage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _recordarCredenciales = false;

  @override
  void initState() {
    super.initState();
    _cargarCredencialesGuardadas();
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text;

    final success = await authProvider.login(usuario, password);

    if (!mounted) return;

    if (success) {
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

      User? usuarioParaRegistrar = authProvider.currentUser;

      if (usuarioParaRegistrar == null) {
        final userData = await ApiService.getUsuarioLocal();
        if (userData != null && userData.isNotEmpty) {
          usuarioParaRegistrar = User.fromJson(userData);
          authProvider.setUser(usuarioParaRegistrar);
        }
      }

      if (usuarioParaRegistrar != null) {
        await authProvider.registrarDispositivoEnBackend(
          usuarioParaRegistrar.id.toString(),
        );
      }

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

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize:
            MainAxisSize.min, // Evita que se estire infinito en la web
        children: [
          // En escritorio ocultamos el logo pequeño porque ya lo mostramos en grande a la izquierda
          if (!widget.isDesktop) ...[
            const Image(
              image: AssetImage('assets/images/LOGO.png'),
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
          ],

          Text(
            'Bienvenido',
            textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ingresa tus credenciales para acceder',
            textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (v) => v!.isEmpty ? 'Ingresa tu contraseña' : null,
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
                          _recordarCredenciales = !_recordarCredenciales;
                        });
                      },
                child: Text(
                  "Recordar credenciales",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
                elevation: 0,
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
            margin: const EdgeInsets.only(top: 30),
            child: Text(
              '© 2026 Inversiones Arenas & Arenas',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
    );
  }
}
