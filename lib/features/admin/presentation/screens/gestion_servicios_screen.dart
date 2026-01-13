import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/admin/presentation/widgets/add_servicio_dialog.dart';

class GestionServiciosScreen extends StatefulWidget {
  final ClienteModel cliente;

  const GestionServiciosScreen({super.key, required this.cliente});

  @override
  State<GestionServiciosScreen> createState() => _GestionServiciosScreenState();
}

class _GestionServiciosScreenState extends State<GestionServiciosScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los servicios apenas entramos a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicioProvider>().cargarServiciosPorCliente(
        widget.cliente.idCliente!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicioProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Servicios Activos", style: TextStyle(fontSize: 18)),
            Text(
              widget.cliente.nombreCliente,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AddServicioDialog(cliente: widget.cliente),
          );
        },
        label: const Text("Nuevo Servicio"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.servicios.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.servicios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final servicio = provider.servicios[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.work_outline, color: Colors.blue),
                    ),
                    title: Text(
                      servicio.nombreServicio,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Mostramos el Centro de Costo generado (XX-Y-ZZZ)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "CC: ${servicio.centroCosto ?? 'Pendiente'}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // AQUÍ ES DONDE SE CUMPLE TU DESEO:
                      // Al hacer click, iremos al "Dashboard del Servicio"
                      // donde verás las OC y las HAS.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Ir a Dashboard de: ${servicio.nombreServicio}",
                          ),
                        ),
                      );
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleServicioScreen(servicio: servicio)));
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay servicios activos",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text("Crea uno nuevo para comenzar"),
        ],
      ),
    );
  }
}
