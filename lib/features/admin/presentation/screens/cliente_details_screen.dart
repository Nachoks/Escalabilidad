import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';
import 'package:somnolence_app/features/admin/presentation/screens/gestion_servicios_screen.dart';
import 'package:somnolence_app/features/admin/presentation/widgets/edit_cliente_dialog.dart';

class ClienteDetailScreen extends StatefulWidget {
  final ClienteModel cliente;

  const ClienteDetailScreen({super.key, required this.cliente});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final cliente = provider.clientes.firstWhere(
      (c) => c.idCliente == widget.cliente.idCliente,
      orElse: () => widget.cliente,
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
                        "Detalle del Cliente",
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
                    "Detalle del Cliente",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
              ? _buildDesktopLayout(cliente, context)
              : _buildMobileLayout(cliente, context),
        );
      },
    );
  }

  // ==========================================================
  // 💻 DISEÑO 1: ESCRITORIO (WEB / PC)
  // ==========================================================
  Widget _buildDesktopLayout(ClienteModel cliente, BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
        ), // Ancho máximo tipo "Panel"
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lado Izquierdo: Info del Cliente
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Avatar Grande
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cliente.codCliente ?? "XX",
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          cliente.nombreCliente,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Lista de Info
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.tag,
                                "Código Interno",
                                cliente.codCliente ?? "Sin código",
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(),
                              ),
                              _buildInfoRow(
                                Icons.person,
                                "Representante",
                                cliente.nombreRepresentante ?? "No definido",
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(),
                              ),
                              _buildInfoRow(
                                Icons.email,
                                "Correo Contacto",
                                cliente.correoRepresentante ?? "No definido",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Divisor Vertical
                Container(width: 1, color: Colors.grey.shade200, height: 500),

                // Lado Derecho: Acciones
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Acciones",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildActionButtons(context, cliente, isDesktop: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======================
  // 📱 DISEÑO 2: MÓVIL
  // ======================
  Widget _buildMobileLayout(ClienteModel cliente, BuildContext context) {
    return Column(
      children: [
        // --- SECCIÓN DE DATOS ---
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cliente.codCliente ?? "XX",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cliente.nombreCliente,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.tag,
                          "Código Interno",
                          cliente.codCliente ?? "Sin código",
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.person,
                          "Representante",
                          cliente.nombreRepresentante ?? "No definido",
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.email,
                          "Correo Contacto",
                          cliente.correoRepresentante ?? "No definido",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- SECCIÓN DE BOTONES ---
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
              padding: const EdgeInsets.all(16),
              child: _buildActionButtons(context, cliente, isDesktop: false),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES REUTILIZABLES ---
  Widget _buildActionButtons(
    BuildContext context,
    ClienteModel cliente, {
    required bool isDesktop,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Botón Gestionar Servicios (Principal)
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 55 : 48,
          child: ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GestionServiciosScreen(cliente: cliente),
                      ),
                    );
                  },
            icon: const Icon(Icons.home_repair_service_rounded),
            label: const Text(
              'Gestionar Servicios',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isDesktop ? 0 : 2,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // 2. Botón Editar (Secundario)
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 55 : 48,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => EditClienteDialog(cliente: cliente),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text(
              'Editar Cliente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[700]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
              const SizedBox(height: 2),
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
    );
  }
}
