import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/admin/presentation/screens/gestion_clientes_screen.dart';
import 'package:somnolence_app/features/admin/presentation/screens/gestion_usuarios_screen.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/auth/presentation/screens/login_screen.dart';
import 'package:somnolence_app/core/widgets/logo_appbar.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/dashboard/presentation/screens/perfil_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/admin_history_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/gestion_rendiciones_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/validator_dashboar_screen.dart';
import 'control_salida_screen.dart';

// --- NUEVOS IMPORTS ---

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool esConductor = user.esConductor;
    final bool esAdmin = user.esAdmin;
    // Si tuvieras un rol separado para validar, podrías usar: final bool esValidador = user.roles.contains('validador');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menú Principal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        leading: const LogoAppbar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // --- HEADER USUARIO ---
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const Text(
                  "Bienvenido,",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  user.nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // --- SECCIÓN DE ICONOS DE ROLES ---
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: user.roles.map((rol) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Tooltip(
                          message: rol.toUpperCase(),
                          triggerMode: TooltipTriggerMode.tap,
                          child: Icon(
                            RoleHelper.getIconForRole(rol),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // --- GRID DE BOTONES ---
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              mainAxisSpacing: 15, // Espacio vertical entre botones
              crossAxisSpacing: 15, // Espacio horizontal entre botones
              children: [
                // 1. MI PERFIL (Para todos)
                _DashboardButton(
                  title: "Mi Perfil",
                  icon: Icons.person,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PerfilScreen(),
                      ),
                    );
                  },
                ),

                // 2. MIS RENDICIONES (Para todos)
                _DashboardButton(
                  title: "Mis Rendiciones",
                  icon: Icons.receipt_long, // Icono más acorde
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GestionRendicionesScreen(),
                      ),
                    );
                  },
                ),

                // 3. CONTROL SALIDA (Solo conductores)
                if (esConductor)
                  _DashboardButton(
                    title: "Control de Salida",
                    icon: Icons.directions_car,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ControlSalidaScreen(),
                        ),
                      );
                    },
                  ),

                // --- ZONA ADMINISTRATIVA / VALIDACIÓN ---
                if (esAdmin) ...[
                  // 4. GESTIÓN USUARIOS
                  _DashboardButton(
                    title: "Gestión Usuarios",
                    icon: Icons.manage_accounts,
                    color: const Color.fromARGB(255, 88, 65, 11),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GestionUsuariosScreen(),
                        ),
                      );
                    },
                  ),

                  // 5. CLIENTES Y SERVICIOS
                  _DashboardButton(
                    title: "Clientes y Serv.",
                    icon: Icons.business_center,
                    color: const Color.fromARGB(255, 221, 163, 27),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GestionClientesScreen(),
                        ),
                      );
                    },
                  ),

                  // 6. VALIDAR RENDICIONES (NUEVO)
                  _DashboardButton(
                    title: "Validar Gastos",
                    icon: Icons.fact_check, // Icono de checklist/validación
                    color: Colors.purple, // Color distintivo
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ValidatorDashboardScreen(),
                        ),
                      );
                    },
                  ),

                  // 7. HISTORIAL GLOBAL (NUEVO)
                  _DashboardButton(
                    title: "Historial Global",
                    icon: Icons.history_edu, // Icono de historial/archivo
                    color: Colors.teal, // Color distintivo
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DashboardButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 30,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
