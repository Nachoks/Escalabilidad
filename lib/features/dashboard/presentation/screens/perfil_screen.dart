import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/dashboard/presentation/widget/change_password_dialog.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // 1. TRUCO VISUAL: El fondo es del color del header.
      // Esto elimina el "espacio en blanco" feo al hacer scroll hacia abajo (pull down).
      backgroundColor: AppColors.primary,

      // Quitamos el AppBar estándar para tener control total del diseño
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          "Mi Perfil",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Quitamos la flecha de volver por defecto para ponerla blanca explícitamente si es necesario,
        // pero por defecto el Theme debería manejarlo. Si no se ve, agrega iconTheme.
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // --- 2. HEADER FIJO (No scrollea, siempre visible y ordenado) ---
          Padding(
            padding: const EdgeInsets.only(bottom: 30, top: 10),
            child: Column(
              children: [
                // Avatar con borde brillante
                Container(
                  padding: const EdgeInsets.all(4), // Borde blanco
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.nombreCompleto.isNotEmpty
                          ? user.nombreCompleto[0].toUpperCase()
                          : "U",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  user.nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // --- 3. PANEL BLANCO SCROLLABLE ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(
                  0xFFF4F6F8,
                ), // Gris suave para el fondo del contenido
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: SingleChildScrollView(
                  // 4. CLAMPING PHYSICS:
                  // Esto es CLAVE. Evita el efecto "rebote" que deja espacios en blanco.
                  // La lista se detiene exactamente en el borde.
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // TARJETA DE DATOS PERSONALES
                      _ModernInfoCard(
                        title: "Información Personal",
                        icon: Icons.person,
                        color: Colors.blueAccent,
                        children: [
                          _ModernDataRow(
                            icon: Icons.badge_outlined,
                            label: "RUT",
                            value: user.rut,
                            color: Colors.blueAccent,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          _ModernDataRow(
                            icon: Icons.email_outlined,
                            label: "Correo",
                            value: user.correo,
                            color: Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // TARJETA DE DATOS LABORALES
                      _ModernInfoCard(
                        title: "Información Laboral",
                        icon: Icons.work,
                        color: Colors.purple,
                        children: [
                          _ModernDataRow(
                            icon: Icons.business_outlined,
                            label: "Empresa",
                            value: user.empresa,
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 15),

                          // Sección de Roles
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ROLES ACTIVOS",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: user.roles.map((rol) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.secondary
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            RoleHelper.getIconForRole(rol),
                                            size: 14,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            rol.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondary,
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

                      const SizedBox(height: 40),

                      // BOTÓN DE ACCIÓN (Contraseña)
                      SafeArea(
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) =>
                                    const ChangePasswordDialog(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.redAccent,
                              elevation:
                                  0, // Plano para verse más limpio en fondo gris
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.red.shade200),
                              ),
                            ),
                            icon: const Icon(Icons.lock_reset_rounded),
                            label: const Text(
                              "Cambiar Contraseña",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Espacio extra para que el botón no quede pegado al borde inferior del scroll
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES (Iguales, solo ajustes menores) ---

class _ModernInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _ModernInfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ), // Bordes un poco menos agresivos
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Sombra más sutil
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _ModernDataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ModernDataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color.withOpacity(0.7), size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
