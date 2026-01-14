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
  // Solo mantenemos un flag local para indicar carga mientras se ejecuta la acción
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider para obtener el usuario actualizado
    final provider = context.watch<AdminUsersProvider>();
    final currentUser = provider.usuarios.firstWhere(
      (u) => u.id == widget.user.id,
      orElse: () => widget.user,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detalle de Usuario',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      // 🔥 CAMBIO ESTRUCTURAL AQUÍ
      // Usamos Column para dividir la pantalla en: Contenido vs Botones Fijos
      body: Column(
        children: [
          // 1. ZONA SCROLLABLE (Ocupa todo el espacio sobrante)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(currentUser),
                  const SizedBox(height: 24),
                  _buildInfoCard(currentUser),
                  // Un pequeño espacio extra al final por si acaso
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 2. ZONA DE BOTONES (Fija abajo y Segura)
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
            // SafeArea protege contra la barra de gestos/notch inferior
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildActionButtons(context, currentUser),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(User currentUser) {
    final esHabilitado = currentUser.estado;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            currentUser.nombreCompleto.isNotEmpty
                ? currentUser.nombreCompleto[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 40,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          currentUser.nombreCompleto,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Mostrar roles como "badges"
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: currentUser.roles.map((rol) {
            return Chip(
              avatar: Icon(
                RoleHelper.getIconForRole(rol),
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                rol.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: RoleHelper.getColorForRole(rol),
              padding: EdgeInsets.zero,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Indicador de Estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  Widget _buildInfoCard(User currentUser) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildActionButtons(BuildContext context, User currentUser) {
    // Definimos colores según el estado del usuario actual
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
      children: [
        // Botón Editar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditUserDialog(user: currentUser),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar Usuario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // (HABILITAR/DESHABILITAR)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : () async {
                    // 1. Mostrar Diálogo de Confirmación
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

                    // 2. Si confirmó, llamar a la API
                    if (confirmar == true) {
                      setState(() => _isLoading = true);

                      final provider = context.read<AdminUsersProvider>();
                      final exito = await provider.cambiarEstadoUsuario(
                        currentUser.id,
                      );

                      if (!mounted) return; // Chequeo de seguridad

                      setState(() => _isLoading = false);

                      if (exito) {
                        // No necesitamos cambiar estado localmente: el provider
                        // ya actualizó la lista y notificará a los listeners.
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
            label: Text(_isLoading ? 'Procesando...' : textoBoton),
            style: OutlinedButton.styleFrom(
              backgroundColor: colorBoton,
              foregroundColor: Colors.white,
              side: BorderSide(color: colorBoton),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
