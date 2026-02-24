import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/admin/presentation/widgets/edit_user_dialog.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';

class UserDetailsScreen extends StatefulWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();
    final currentUser = provider.usuarios.firstWhere(
      (u) => u.id == widget.user.id,
      orElse: () => widget.user,
    );

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
                      const Text(
                        'Detalle de Usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                )
              : AppBar(
                  title: const Text(
                    'Detalle de Usuario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

          // --- CUERPO ---
          body: isDesktop
              ? _buildDesktopLayout(currentUser)
              : _buildMobileLayout(currentUser),
        );
      },
    );
  }

  // ==========================================================
  // 💻 DISEÑO 1: ESCRITORIO (WEB / PC)
  // ==========================================================
  Widget _buildDesktopLayout(User currentUser) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900), // Panel central ancho
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            // 🔥 SOLUCIÓN DEL ERROR: IntrinsicHeight evita el colapso del "stretch" infinito
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Columna Izquierda: Perfil y Roles
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                        ),
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [_buildHeader(currentUser, isDesktop: true)],
                      ),
                    ),
                  ),

                  // Columna Derecha: Información y Botones
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Información de Contacto",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoCard(currentUser, isDesktop: true),
                          const SizedBox(height: 40),
                          const Text(
                            "Acciones de Administrador",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButtons(currentUser, isDesktop: true),
                        ],
                      ),
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

  // ==========================================================
  // 📱 DISEÑO 2: MÓVIL (Mantenido exactamente igual)
  // ==========================================================
  Widget _buildMobileLayout(User currentUser) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(currentUser, isDesktop: false),
                const SizedBox(height: 24),
                _buildInfoCard(currentUser, isDesktop: false),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildActionButtons(currentUser, isDesktop: false),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader(User currentUser, {required bool isDesktop}) {
    final esHabilitado = currentUser.estado;

    return Column(
      children: [
        CircleAvatar(
          radius: isDesktop ? 60 : 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            currentUser.nombreCompleto.isNotEmpty
                ? currentUser.nombreCompleto[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: isDesktop ? 48 : 40,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          currentUser.nombreCompleto,
          style: TextStyle(
            fontSize: isDesktop ? 26 : 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: (currentUser.roles as List<dynamic>).map<Widget>((rol) {
            final String roleStr = rol.toString();
            return Chip(
              avatar: Icon(
                RoleHelper.getIconForRole(roleStr),
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                roleStr.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: RoleHelper.getColorForRole(roleStr),
              padding: EdgeInsets.zero,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: esHabilitado
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: esHabilitado ? Colors.green : Colors.red),
          ),
          child: Text(
            esHabilitado ? "CUENTA ACTIVA" : "CUENTA DESHABILITADA",
            style: TextStyle(
              color: esHabilitado ? Colors.green[800] : Colors.red[800],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(User currentUser, {required bool isDesktop}) {
    return Card(
      elevation: isDesktop ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.business, 'Empresa', currentUser.empresa),
            const Divider(),
            _buildInfoRow(Icons.fingerprint, 'RUT', currentUser.rut),
            const Divider(),
            _buildInfoRow(Icons.email_outlined, 'Correo', currentUser.correo),
            const Divider(),
            _buildInfoRow(
              Icons.person_outline,
              'Nombre de Usuario',
              currentUser.nombreUsuario,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(User currentUser, {required bool isDesktop}) {
    final colorBoton = currentUser.estado
        ? Colors.orange[800]!
        : Colors.green[700]!;
    final textoBoton = currentUser.estado
        ? 'Deshabilitar Acceso'
        : 'Habilitar Acceso';
    final iconoBoton = currentUser.estado
        ? Icons.block
        : Icons.check_circle_outline;

    return Column(
      mainAxisSize:
          MainAxisSize.min, // Para que no intente crecer infinitamente
      children: [
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 55 : 48,
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => EditUserDialog(user: currentUser),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text(
              'Editar Usuario',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isDesktop ? 0 : 2,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 55 : 48,
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          currentUser.estado
                              ? '¿Deshabilitar Usuario?'
                              : '¿Habilitar Usuario?',
                        ),
                        content: Text(
                          currentUser.estado
                              ? 'El usuario no podrá ingresar a la aplicación hasta que sea habilitado nuevamente.'
                              : 'El usuario recuperará el acceso a la aplicación inmediatamente.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      setState(() => _isLoading = true);
                      final provider = context.read<AdminUsersProvider>();
                      final exito = await provider.cambiarEstadoUsuario(
                        currentUser.id,
                      );

                      if (!mounted) return;
                      setState(() => _isLoading = false);

                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              currentUser.estado
                                  ? 'Usuario Habilitado'
                                  : 'Usuario Deshabilitado',
                            ),
                            backgroundColor: currentUser.estado
                                ? Colors.green
                                : Colors.orange,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al cambiar el estado'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(iconoBoton),
            label: Text(
              _isLoading ? 'Procesando...' : textoBoton,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: colorBoton,
              foregroundColor: Colors.white,
              side: BorderSide(color: colorBoton),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
