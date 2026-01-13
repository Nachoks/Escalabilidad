import 'package:flutter/material.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/presentation/screens/gestion_servicios_screen.dart';

class ClienteDetailScreen extends StatefulWidget {
  final ClienteModel cliente;

  const ClienteDetailScreen({super.key, required this.cliente});

  @override
  State<ClienteDetailScreen> createState() => _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends State<ClienteDetailScreen> {
  // Variable de estado para bloquear botones si hay procesos cargando
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Detalle del Cliente"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- SECCIÓN DE DATOS (Scrollable) ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. Cabecera con Logo/Iniciales
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

                  // 2. Nombre Principal
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

                  // 3. Tarjeta de Datos
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

          // --- SECCIÓN DE BOTONES (Fija abajo) ---
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
                child: _buildActionButtons(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTONES CON EL ESTILO SOLICITADO ---
  // --- BOTONES CORREGIDOS ---
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 1. Botón Editar (Azul)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Próximamente: Editar Cliente")),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar Cliente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Botón Servicios Asociados (Verde - Acción Principal)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    // ✅ NAVEGACIÓN CORRECTA
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GestionServiciosScreen(cliente: widget.cliente),
                      ),
                    );
                  },
            icon: const Icon(Icons.home_repair_service_rounded),
            label: const Text('Gestionar Servicios'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.green[700]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Botón Eliminar (Rojo - Zona de Peligro)
      ],
    );
  }

  // Widget auxiliar para las filas de información
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
