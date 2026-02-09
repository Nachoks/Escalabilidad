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
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/admin_history_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/gestion_rendiciones_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/validator_dashboar_screen.dart';
import 'control_salida_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar el contador al iniciar si es admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && user.esAdmin) {
        context.read<RendicionesProvider>().actualizarContadorPendientes();
      }
    });
  }

  /// Refrescamos el contador manualmente al volver de una pantalla
  void _actualizarContador() {
    if (mounted) {
      context.read<RendicionesProvider>().actualizarContadorPendientes();
    }
  }

  /// ------------------------------------------------------------
  /// MENÚ DESPLEGABLE (POPUP) PARA EL ADMIN
  /// Aquí aparecen los 3 botones agrupados
  /// ------------------------------------------------------------
  void _mostrarMenuRendicionesAdmin(BuildContext context, int pendientes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Permite que el modal se ajuste mejor
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pequeña barra gris decorativa
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Gestión de Rendiciones",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // 1. Validar Gastos (Validar)
            _buildListItem(
              icon: Icons.fact_check_outlined,
              color: Colors.green,
              text: "Validar Gastos",
              badgeCount: pendientes, // El contador también se ve aquí dentro
              onTap: () {
                Navigator.pop(context); // Cerrar el menú
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ValidatorDashboardScreen(),
                  ),
                ).then((_) => _actualizarContador());
              },
            ),
            const Divider(),

            // 2. Historial Global
            _buildListItem(
              icon: Icons.history_edu,
              color: Colors.teal,
              text: "Historial Global",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminHistoryScreen()),
                );
              },
            ),
            const Divider(),

            // 3. Mis propias rendiciones (Como usuario normal)
            _buildListItem(
              icon: Icons.receipt_long_outlined,
              color: Colors.blueAccent,
              text: "Mis Rendiciones",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GestionRendicionesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las filas del menú desplegable
  Widget _buildListItem({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: (badgeCount != null && badgeCount > 0)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$badgeCount",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    // Consumir el contador
    final provider = context.watch<RendicionesProvider>();
    final int pendientes = provider.cantidadPendientes;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool esConductor = user.esConductor;
    final bool esAdmin = user.esAdmin;
    final bool esValidador = user.esValidador;

    // ------------------------------------------------------
    // CONSTRUCCIÓN DE LA LISTA DE BOTONES SEGÚN EL ROL
    // ------------------------------------------------------
    final List<Map<String, dynamic>> menuItems = [];

    // 1. MI PERFIL (Para todos)
    menuItems.add({
      'title': 'Mi Perfil',
      'icon': Icons.person_outline,
      'color': Colors.orange,
      'page': const PerfilScreen(),
    });

    // 2. CONTROL SALIDA (Solo si es conductor)
    if (esConductor) {
      menuItems.add({
        'title': 'Control Salida',
        'icon': Icons.directions_car_filled_outlined,
        'color': Colors.indigo,
        'page': const ControlSalidaScreen(),
      });
    }

    // 3. LÓGICA DE RENDICIONES (Diferenciada)
    if (esAdmin || esValidador) {
      // SOLO ADMIN ve Usuarios y Clientes (Opcional: Si quieres que el validador NO vea esto, déjalo dentro de un if(esAdmin) interno)
      if (esAdmin) {
        menuItems.add({
          'title': 'Usuarios',
          'icon': Icons.manage_accounts_outlined,
          'color': Colors.brown,
          'page': const GestionUsuariosScreen(),
        });

        menuItems.add({
          'title': 'Clientes y Servicios',
          'icon': Icons.business_center_outlined,
          'color': Colors.amber.shade800,
          'page': const GestionClientesScreen(),
        });
      }

      // C. RENDICIONES (Botón Agrupado) - VISIBLE PARA AMBOS
      menuItems.add({
        'title': 'Rendiciones',
        'icon': Icons.folder_shared_outlined,
        'color': Colors.blueGrey,
        'badgeCount': pendientes,
        'isAction': true,
        'action': (BuildContext ctx) =>
            _mostrarMenuRendicionesAdmin(ctx, pendientes),
      });
    } else {
      // --- VISTA NORMAL (Solo Rendidor/Conductor) ---
      menuItems.add({
        'title': 'Mis Rendiciones',
        'icon': Icons.receipt_long_outlined,
        'color': Colors.blueAccent,
        'page': const GestionRendicionesScreen(),
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          // --- HEADER (Diseño original mantenido) ---
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

          // --- GRID DE BOTONES ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];

                return _BigCardButton(
                  title: item['title'],
                  icon: item['icon'],
                  color: item['color'],
                  badgeCount: item['badgeCount'], // Pasamos el contador
                  onTap: () async {
                    // VERIFICACIÓN IMPORTANTE:
                    // ¿Es un botón de acción (Popup) o de navegación normal?

                    if (item['isAction'] == true) {
                      // Ejecutar la función (abrir el modal)
                      item['action'](context);
                    } else {
                      // Navegación normal
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item['page']),
                      );
                      // Al volver, actualizamos el contador por si acaso
                      if (context.mounted && esAdmin) {
                        _actualizarContador();
                      }
                    }
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

// --- WIDGET DE TARJETA (Mantenido igual para diseño visual) ---
class _BigCardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount; // Variable opcional para el número

  const _BigCardButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Permitir que el badge salga un poco
      children: [
        // 1. Tarjeta Normal
        Container(
          width: double.infinity,
          height: double.infinity,
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
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
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
        ),

        // 2. BADGE DE NOTIFICACIÓN (Solo si hay contador > 0)
        if (badgeCount != null && badgeCount! > 0)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                badgeCount! > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
