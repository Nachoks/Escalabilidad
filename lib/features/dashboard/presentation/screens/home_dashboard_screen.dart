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
import 'package:somnolence_app/features/inventario/presentation/screens/configuracion_scaner_screen.dart';
import 'package:somnolence_app/features/inventario/presentation/screens/movile_escaner_screen.dart';
import 'package:somnolence_app/features/inventario/presentation/screens/web_tabla_screen.dart';
import 'package:somnolence_app/features/inventario/presentation/screens/gestion_proveedores_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/admin_history_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/gestion_rendiciones_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/validator_dashboar_screen.dart';
import 'control_salida_screen.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/hojas_list_screen.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/admin_hoja_pendientes_screen.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/admin_hoja_historial_screen.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/providers/hoja_tiempo_provider.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Suscribimos el observador
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _actualizarContadores();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    ); // Limpiamos la memoria al salir
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _actualizarContadores();
    }
  }

  void _actualizarContadores() {
    if (!mounted) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      if (user.esAdmin || RoleHelper.isValidador(user.roles)) {
        context.read<RendicionesProvider>().actualizarContadorPendientes();
      }

      if (user.esAdmin || RoleHelper.isValidadorHT(user.roles)) {
        context.read<HojaTiempoProvider>().actualizarContadorPendientes();
      }
    }
  }

  // =========================================================
  // --- MENÚ INVENTARIO (SOLO MÓVIL) ---
  // =========================================================
  void _mostrarMenuInventarioMovil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              "Lector de Inventario",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            _buildModalListItem(
              icon: Icons.login_rounded,
              color: Colors.green,
              text: "Escanear Entrada",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MovilEscanerScreen(esEntrada: true),
                  ),
                ).then((_) => _actualizarContadores());
              },
            ),
            const Divider(),
            _buildModalListItem(
              icon: Icons.logout_rounded,
              color: Colors.orange[800]!,
              text: "Escanear Salida",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MovilEscanerScreen(esEntrada: false),
                  ),
                ).then((_) => _actualizarContadores());
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- MENÚ RENDICIONES ---
  void _mostrarMenuRendicionesAdmin(BuildContext context, int pendientes) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    Widget menuContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDesktop)
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
        _buildModalListItem(
          icon: Icons.fact_check_outlined,
          color: Colors.green,
          text: "Validar Gastos",
          badgeCount: pendientes,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ValidatorDashboardScreen(),
              ),
            ).then((_) => _actualizarContadores());
          },
        ),
        const Divider(),
        _buildModalListItem(
          icon: Icons.history_edu,
          color: Colors.teal,
          text: "Historial Global",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminHistoryScreen()),
            ).then((_) => _actualizarContadores());
          },
        ),
        const Divider(),
        _buildModalListItem(
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
            ).then((_) => _actualizarContadores());
          },
        ),
        if (!isDesktop) const SizedBox(height: 20),
      ],
    );

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: menuContent,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: menuContent,
        ),
      );
    }
  }

  // --- MENÚ HOJAS DE TIEMPO ---
  void _mostrarMenuHojasTiempoAdmin(BuildContext context, int pendientesHT) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    Widget menuContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDesktop)
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
          "Gestión de Hojas de Tiempo",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        _buildModalListItem(
          icon: Icons.fact_check_outlined,
          color: Colors.green,
          text: "Evaluar Hojas Pendientes",
          badgeCount: pendientesHT,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminHojasPendientesScreen(),
              ),
            ).then((_) => _actualizarContadores());
          },
        ),
        const Divider(),
        _buildModalListItem(
          icon: Icons.history,
          color: Colors.orange[800]!,
          text: "Historial Global HCT",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminHojaHistorialScreen(),
              ),
            ).then((_) => _actualizarContadores());
          },
        ),
        const Divider(),
        _buildModalListItem(
          icon: Icons.access_time,
          color: Colors.deepPurple,
          text: "Mis Hojas de Tiempo",
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HojasListScreen()),
            ).then((_) => _actualizarContadores());
          },
        ),
        if (!isDesktop) const SizedBox(height: 20),
      ],
    );

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: menuContent,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: menuContent,
        ),
      );
    }
  }

  Widget _buildModalListItem({
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
      trailing: (badgeCount != null && badgeCount! > 0)
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

    final int pendientesGastos = context
        .watch<RendicionesProvider>()
        .cantidadPendientes;
    final int pendientesHT = context
        .watch<HojaTiempoProvider>()
        .cantidadPendientes;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool esAdmin = RoleHelper.isAdmin(user.roles);
    final bool esValidadorGastos = RoleHelper.isValidador(user.roles);
    final bool esValidadorHT = RoleHelper.isValidadorHT(user.roles);
    final bool esConductor = RoleHelper.isConductor(user.roles);
    final bool esInventario = RoleHelper.isInventario(
      user.roles,
    ); // 👇 NUEVO: Variable Inventario

    final isDesktopView = MediaQuery.of(context).size.width >= 850;

    final List<Map<String, dynamic>> menuItems = [];

    // Perfil
    menuItems.add({
      'title': 'Mi Perfil',
      'subtitle': 'Ajustes y credenciales',
      'icon': Icons.person_outline,
      'color': Colors.orange,
      'page': const PerfilScreen(),
    });

    // INVENTARIO Y CATÁLOGO (Accesible para Admin o Inventario)
    if (esAdmin || esInventario) {
      if (isDesktopView) {
        menuItems.add({
          'title': 'Monitor Inventario',
          'subtitle': 'Stock e Historial',
          'icon': Icons.inventory_2_outlined,
          'color': Colors.teal,
          'page': const WebTablasScreen(),
        });
      } else {
        menuItems.add({
          'title': 'Inventario',
          'subtitle': 'Escanear Entrada/Salida',
          'icon': Icons.qr_code_scanner,
          'color': Colors.teal,
          'isAction': true,
          'action': (BuildContext ctx) => _mostrarMenuInventarioMovil(ctx),
        });
      }

      menuItems.add({
        'title': 'Proveedores',
        'subtitle': 'Catálogo de proveedores',
        'icon': Icons.local_shipping_outlined,
        'color': Colors.blueGrey.shade700,
        'page': const GestionProveedoresScreen(),
      });

      if (esAdmin) {
        menuItems.add({
          'title': 'Reglas de Escáner',
          'subtitle': 'Ajustes del lector',
          'icon': Icons.settings_overscan,
          'color': Colors.deepOrange,
          'page': const ConfiguracionEscanerScreen(),
        });
      }
    }

    // HOJAS DE TIEMPO
    if (esAdmin || esValidadorHT) {
      menuItems.add({
        'title': 'Hojas de Tiempo',
        'subtitle': 'Control y validación de horas',
        'icon': Icons.access_time,
        'color': Colors.deepPurple,
        'badgeCount': pendientesHT,
        'isAction': true,
        'action': (BuildContext ctx) =>
            _mostrarMenuHojasTiempoAdmin(ctx, pendientesHT),
      });
    } else {
      menuItems.add({
        'title': 'Hojas de Tiempo',
        'subtitle': 'Registra tus horas',
        'icon': Icons.access_time,
        'color': Colors.deepPurple,
        'page': const HojasListScreen(),
      });
    }

    // CONDUCTOR
    if (esConductor) {
      menuItems.add({
        'title': 'Control Salida',
        'subtitle': 'Test de Somnolencia',
        'icon': Icons.directions_car_filled_outlined,
        'color': Colors.indigo,
        'page': const ControlSalidaScreen(),
      });
    }

    // RENDICIONES
    if (esAdmin || esValidadorGastos) {
      if (esAdmin) {
        menuItems.add({
          'title': 'Usuarios',
          'subtitle': 'Gestión de personal',
          'icon': Icons.manage_accounts_outlined,
          'color': Colors.brown,
          'page': const GestionUsuariosScreen(),
        });
        menuItems.add({
          'title': 'Clientes',
          'subtitle': 'Empresas y servicios',
          'icon': Icons.business_center_outlined,
          'color': Colors.amber.shade800,
          'page': const GestionClientesScreen(),
        });
      }

      menuItems.add({
        'title': 'Rendiciones',
        'subtitle': 'Control de viáticos y gastos',
        'icon': Icons.folder_shared_outlined,
        'color': Colors.blueGrey,
        'badgeCount': pendientesGastos,
        'isAction': true,
        'action': (BuildContext ctx) =>
            _mostrarMenuRendicionesAdmin(ctx, pendientesGastos),
      });
    } else {
      menuItems.add({
        'title': 'Mis Rendiciones',
        'subtitle': 'Envío de boletas y gastos',
        'icon': Icons.receipt_long_outlined,
        'color': Colors.blueAccent,
        'page': const GestionRendicionesScreen(),
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: isDesktop
              ? AppBar(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  toolbarHeight: 70,
                  title: Row(
                    children: [
                      const Image(
                        image: AssetImage('assets/images/isotipo.png'),
                        width: 45,
                        height: 45,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Intranet IAA SPA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            user.nombreCompleto,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            user.roles.join(' • '),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        user.nombreUsuario.isNotEmpty
                            ? user.nombreUsuario[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      tooltip: 'Cerrar Sesión',
                      icon: const Icon(Icons.logout, color: Colors.white),
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
                    const SizedBox(width: 16),
                  ],
                )
              : null,

          body: Column(
            children: [
              if (!isDesktop)
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
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
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
                                style: const TextStyle(
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
                                    children: user.roles
                                        .map(
                                          (rol) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.25,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              RoleHelper.getIconForRole(rol),
                                              color: Colors.white70,
                                              size: 14,
                                            ),
                                          ),
                                        )
                                        .toList(),
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

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 40 : 20,
                        vertical: isDesktop ? 40 : 25,
                      ),
                      itemCount: menuItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 2,
                        crossAxisSpacing: isDesktop ? 24 : 16,
                        mainAxisSpacing: isDesktop ? 24 : 16,
                        childAspectRatio: isDesktop ? 2.5 : 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final item = menuItems[index];

                        return isDesktop
                            ? _WebCardMenu(
                                title: item['title'],
                                subtitle: item['subtitle'],
                                icon: item['icon'],
                                color: item['color'],
                                badgeCount: item['badgeCount'],
                                onTap: () => _manejarNavegacion(
                                  item,
                                  context,
                                  esAdmin ||
                                      esValidadorGastos ||
                                      esValidadorHT ||
                                      esInventario,
                                ),
                              )
                            : _MobileSquareCard(
                                title: item['title'],
                                icon: item['icon'],
                                color: item['color'],
                                badgeCount: item['badgeCount'],
                                onTap: () => _manejarNavegacion(
                                  item,
                                  context,
                                  esAdmin ||
                                      esValidadorGastos ||
                                      esValidadorHT ||
                                      esInventario,
                                ),
                              );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _manejarNavegacion(
    Map<String, dynamic> item,
    BuildContext context,
    bool permisosAvanzados,
  ) async {
    if (item['isAction'] == true) {
      item['action'](context);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item['page']),
      );
      if (context.mounted) _actualizarContadores();
    }
  }
}

// ==========================================================
// TARJETA HORIZONTAL (SOLO PARA WEB)
// ==========================================================
class _WebCardMenu extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const _WebCardMenu({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeCount! > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 🎨 DISEÑO 2: TARJETA CUADRADA ORIGINAL (SOLO PARA MÓVIL)
// ==========================================================
class _MobileSquareCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const _MobileSquareCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
