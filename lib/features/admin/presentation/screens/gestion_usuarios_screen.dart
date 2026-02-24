import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';

// Widgets y Pantallas
import 'package:somnolence_app/features/admin/presentation/widgets/add_user_dialog.dart';
import 'package:somnolence_app/features/admin/presentation/screens/user_details_screen.dart';

class GestionUsuariosScreen extends StatelessWidget {
  const GestionUsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ListaUsuariosContent();
  }
}

class _ListaUsuariosContent extends StatefulWidget {
  const _ListaUsuariosContent();

  @override
  State<_ListaUsuariosContent> createState() => _ListaUsuariosContentState();
}

class _ListaUsuariosContentState extends State<_ListaUsuariosContent> {
  String _filtroSeleccionado = 'Todos';

  final List<String> _opcionesFiltro = [
    'Todos',
    'Habilitados',
    'Deshabilitados',
    'Administrador',
    'Conductor',
    'Validador',
    'Rendidor',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();

    final usuariosFiltrados = provider.usuarios.where((u) {
      if (_filtroSeleccionado == 'Todos') return true;
      if (_filtroSeleccionado == 'Habilitados') return u.estado == true;
      if (_filtroSeleccionado == 'Deshabilitados') return u.estado == false;
      return u.roles.any(
        (rol) => rol.toLowerCase().contains(_filtroSeleccionado.toLowerCase()),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : AppColors.background,

          // --- APPBAR ADAPTATIVO ---
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Gestión de Usuarios',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '${usuariosFiltrados.length} usuarios encontrados',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Recargar lista',
                      onPressed: provider.cargarUsuarios,
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión de Usuarios',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${usuariosFiltrados.length} usuarios encontrados',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                    ),
                  ),
                ),

          // --- BOTÓN FLOTANTE ---
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1),
            label: isDesktop
                ? const Text(
                    "NUEVO USUARIO",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text("NUEVO"),
            onPressed: () {
              final providerActual = context.read<AdminUsersProvider>();
              showDialog(
                context: context,
                builder: (_) => ChangeNotifierProvider.value(
                  value: providerActual,
                  child: const AddUserDialog(),
                ),
              );
            },
          ),

          // --- CUERPO ---
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
              child: Column(
                children: [
                  // --- FILTROS (Diferente para Web y Móvil) ---
                  isDesktop
                      ? _buildWebFilterBar()
                      : _buildMobileFilterDropdown(),

                  // --- LISTA DE USUARIOS ---
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : usuariosFiltrados.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: provider.cargarUsuarios,
                            child: isDesktop
                                // --- GRILLA PARA ESCRITORIO ---
                                ? GridView.builder(
                                    padding: const EdgeInsets.all(32),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              constraints.maxWidth > 1100
                                              ? 4
                                              : 3, // 4 columnas si es muy ancho, 3 si no
                                          childAspectRatio:
                                              2.5, // Tarjetas rectangulares
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                    itemCount: usuariosFiltrados.length,
                                    itemBuilder: (context, index) =>
                                        _buildUsuarioCard(
                                          usuariosFiltrados[index],
                                          isDesktop: true,
                                        ),
                                  )
                                // --- LISTA PARA MÓVIL ---
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      80,
                                    ),
                                    itemCount: usuariosFiltrados.length,
                                    separatorBuilder: (c, i) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) =>
                                        _buildUsuarioCard(
                                          usuariosFiltrados[index],
                                          isDesktop: false,
                                        ),
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TARJETA DE USUARIO COMPARTIDA ---
  Widget _buildUsuarioCard(dynamic usuario, {required bool isDesktop}) {
    final bool estaHabilitado = usuario.estado;
    final colorFondo = estaHabilitado ? Colors.white : Colors.red[50];

    return Card(
      color: colorFondo,
      elevation: isDesktop ? 0 : 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsScreen(user: usuario),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isDesktop ? 16 : 8,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: isDesktop ? 24 : 20,
                backgroundColor: estaHabilitado
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Text(
                  usuario.nombreCompleto.isNotEmpty
                      ? usuario.nombreCompleto[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: estaHabilitado ? AppColors.primary : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 20 : 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      usuario.nombreCompleto,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 15,
                        decoration: estaHabilitado
                            ? null
                            : TextDecoration.lineThrough,
                        color: estaHabilitado
                            ? Colors.black87
                            : Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario.empresa,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 💻 BARRA DE FILTROS PARA ESCRITORIO (CHIPS HORIZONTALES)
  // ==========================================================
  Widget _buildWebFilterBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          const Text(
            "Filtrar:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _opcionesFiltro.map((opcion) {
                  final isSelected = _filtroSeleccionado == opcion;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(
                        opcion,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) =>
                          setState(() => _filtroSeleccionado = opcion),
                      backgroundColor: Colors.grey[100],
                      selectedColor: _getColorForOption(opcion),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? _getColorForOption(opcion)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 📱 FILTRO DROPDOWN ORIGINAL PARA MÓVIL
  // ==========================================================
  Widget _buildMobileFilterDropdown() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        onSelected: (String newValue) =>
            setState(() => _filtroSeleccionado = newValue),
        itemBuilder: (context) => _opcionesFiltro.map((String opcion) {
          return PopupMenuItem<String>(
            value: opcion,
            child: Row(
              children: [
                if (opcion != 'Todos') ...[
                  Icon(
                    _getIconForOption(opcion),
                    size: 18,
                    color: _getColorForOption(opcion),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(opcion),
              ],
            ),
          );
        }).toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.filter_list_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                "Filtrar por:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    if (_filtroSeleccionado != 'Todos') ...[
                      Icon(
                        _getIconForOption(_filtroSeleccionado),
                        size: 18,
                        color: _getColorForOption(_filtroSeleccionado),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _filtroSeleccionado,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
  IconData _getIconForOption(String opcion) {
    if (opcion == 'Todos') return Icons.grid_view_rounded;
    if (opcion == 'Habilitados') return Icons.check_circle_outline_rounded;
    if (opcion == 'Deshabilitados') return Icons.block_rounded;
    return RoleHelper.getIconForRole(opcion);
  }

  Color _getColorForOption(String opcion) {
    if (opcion == 'Todos') return Colors.blueGrey;
    if (opcion == 'Habilitados') return Colors.green;
    if (opcion == 'Deshabilitados') return Colors.red;
    return RoleHelper.getColorForRole(opcion);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No se encontraron resultados",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
