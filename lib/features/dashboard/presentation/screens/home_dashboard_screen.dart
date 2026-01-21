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

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Mi Perfil',
        'icon': Icons.person_outline,
        'color': Colors.orange,
        'page': const PerfilScreen(),
      },
      {
        'title': 'Mis Rendiciones',
        'icon': Icons.receipt_long_outlined,
        'color': Colors.blueAccent,
        'page': const GestionRendicionesScreen(),
      },
      if (esConductor)
        {
          'title': 'Control Salida',
          'icon': Icons.directions_car_filled_outlined,
          'color': Colors.indigo,
          'page': const ControlSalidaScreen(),
        },
      if (esAdmin) ...[
        {
          'title': 'Validar Gastos',
          'icon': Icons.fact_check_outlined,
          'color': Colors.green,
          'page': const ValidatorDashboardScreen(),
        },
        {
          'title': 'Historial Global',
          'icon': Icons.history_edu,
          'color': Colors.teal,
          'page': const AdminHistoryScreen(),
        },
        {
          'title': 'Usuarios',
          'icon': Icons.manage_accounts_outlined,
          'color': Colors.brown,
          'page': const GestionUsuariosScreen(),
        },
        {
          'title': 'Clientes y Servicios',
          'icon': Icons.business_center_outlined,
          'color': Colors.amber.shade800,
          'page': const GestionClientesScreen(),
        },
      ],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Gris azulado muy claro
      body: Column(
        children: [
          // --- HEADER (Mantenemos tu diseño de roles) ---
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LogoAppbar(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (r) => false,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.nombreUsuario.isNotEmpty
                              ? user.nombreUsuario[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.nombreCompleto,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: user.roles.map((rol) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        RoleHelper.getIconForRole(rol),
                                        color: Colors.white70,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        rol.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- GRID GRANDE Y LLENO ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columnas
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    1.0, // Cuadrado perfecto (1:1) para llenar espacio
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _BigCardButton(
                  title: item['title'],
                  icon: item['icon'],
                  color: item['color'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item['page']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- TARJETA "BIG CARD" (LLENA EL ESPACIO) ---
class _BigCardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BigCardButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Icono GRANDE con fondo generoso
              Container(
                height: 70, // Mucho más grande
                width: 70,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08), // Fondo muy suave
                  shape: BoxShape
                      .circle, // O BorderRadius.circular(20) si prefieres cuadrado redondeado
                ),
                child: Icon(
                  icon,
                  size: 32, // Icono interno más grande
                  color: color,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Título Centrado y Visible
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16, // Texto más grande
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
