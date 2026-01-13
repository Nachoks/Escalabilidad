import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/admin/presentation/screens/servicio_detalle_screen.dart';
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
      if (widget.cliente.idCliente != null) {
        context.read<ServicioProvider>().cargarServiciosPorCliente(
          widget.cliente.idCliente!,
        );
      }
    });
  }

  // --- LÓGICA DE COLORES SEMÁFORO ---
  Color _getColorByFacturacion(String? facturacion) {
    switch (facturacion) {
      case 'Totalmente facturado':
        return Colors.green.shade100; // Verde
      case 'Parcialmente facturado':
        return Colors.amber.shade100; // Amarillo/Ambar
      case 'No facturado':
      default:
        return Colors.red.shade100; // Rojo
    }
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

                // 1. Obtenemos el color según la facturación
                final colorFondo = _getColorByFacturacion(servicio.facturacion);

                return Card(
                  elevation: 2,
                  color: colorFondo, // <--- APLICAMOS EL COLOR SEMÁFORO
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: const Icon(
                        Icons.work_outline,
                        color: Colors.black54,
                      ),
                    ),
                    title: Text(
                      servicio.nombreServicio,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        // QUITAMOS EL TACHADO Y DEJAMOS COLOR NEGRO
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Fila con Centro de Costo y Etiqueta de Finalizado
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${servicio.centroCosto ?? 'Pendiente'}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Etiqueta pequeña si está finalizado (para no perder esa info)
                            if (servicio.estadoServicio == 'Finalizado')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "FINALIZADO",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Texto explícito del estado de facturación
                        Text(
                          servicio.facturacion ?? "No facturado",
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black45,
                    ),
                    onTap: () {
                      // NAVEGACIÓN A LA NUEVA PANTALLA
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ServicioDetalleScreen(servicio: servicio),
                        ),
                      ).then((_) {
                        // AL VOLVER, RECARGAR LA LISTA
                        if (mounted) {
                          context
                              .read<ServicioProvider>()
                              .cargarServiciosPorCliente(
                                widget.cliente.idCliente!,
                              );
                        }
                      });
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
