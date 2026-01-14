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
  // --- VARIABLES DE FILTRO ---
  String _filtroEstado = 'Todos'; // Opciones: 'Todos', 'Activos', 'Finalizados'
  String _filtroFacturacion =
      'Todos'; // Opciones: 'Todos', 'Totalmente facturado', 'Parcialmente facturado', 'No facturado'

  @override
  void initState() {
    super.initState();
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
        return Colors.green.shade100;
      case 'Parcialmente facturado':
        return Colors.amber.shade100;
      case 'No facturado':
      default:
        return Colors.red.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicioProvider>();

    // --- APLICAR FILTROS ---
    // Tomamos la lista original del provider y la filtramos según las variables
    final serviciosFiltrados = provider.servicios.where((servicio) {
      // 1. Filtro por Estado (Finalizado vs Activo)
      if (_filtroEstado == 'Finalizados' &&
          servicio.estadoServicio != 'Finalizado') {
        return false;
      }
      if (_filtroEstado == 'Activos' &&
          servicio.estadoServicio == 'Finalizado') {
        return false;
      }

      // 2. Filtro por Facturación
      if (_filtroFacturacion != 'Todos') {
        // Si el filtro no es "Todos", debe coincidir exactamente con el string de facturación
        // Manejamos null como 'No facturado' por seguridad
        final facturacionServicio = servicio.facturacion ?? 'No facturado';
        if (facturacionServicio != _filtroFacturacion) {
          return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Servicios",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
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
      body: Column(
        children: [
          // --- BARRA DE FILTROS ---
          _buildFilterBar(),

          // --- LISTA DE SERVICIOS ---
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.servicios.isEmpty
                ? _buildEmptyStateOriginal() // No hay datos en absoluto
                : serviciosFiltrados.isEmpty
                ? _buildEmptyStateFiltros() // Hay datos, pero el filtro los ocultó todos
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      80,
                    ), // Padding inferior para el FAB
                    itemCount: serviciosFiltrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final servicio = serviciosFiltrados[index];
                      final colorFondo = _getColorByFacturacion(
                        servicio.facturacion,
                      );

                      return Card(
                        elevation: 2,
                        color: colorFondo,
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
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ServicioDetalleScreen(servicio: servicio),
                              ),
                            ).then((_) {
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
          ),
        ],
      ),
    );
  }

  // --- WIDGET DE LA BARRA DE FILTROS ---
  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título pequeño de filtros
          const Text(
            "Filtros:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Grupo 1: ESTADO (Activos / Finalizados)
                _buildChoiceChip(
                  label: 'Todos',
                  selected:
                      _filtroEstado == 'Todos' && _filtroFacturacion == 'Todos',
                  onSelected: (bool selected) {
                    setState(() {
                      _filtroEstado = 'Todos';
                      _filtroFacturacion = 'Todos'; // Resetear todo
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Activos',
                  selected: _filtroEstado == 'Activos',
                  onSelected: (bool selected) {
                    setState(
                      () => _filtroEstado = selected ? 'Activos' : 'Todos',
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Finalizados',
                  selected: _filtroEstado == 'Finalizados',
                  onSelected: (bool selected) {
                    setState(
                      () => _filtroEstado = selected ? 'Finalizados' : 'Todos',
                    );
                  },
                ),

                // Divisor vertical visual
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),

                // Grupo 2: FACTURACIÓN
                _buildChoiceChip(
                  label: 'Totalmente',
                  color: Colors.green.shade100,
                  selected: _filtroFacturacion == 'Totalmente facturado',
                  onSelected: (bool selected) {
                    setState(
                      () => _filtroFacturacion = selected
                          ? 'Totalmente facturado'
                          : 'Todos',
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Parcialmente',
                  color: Colors.amber.shade100,
                  selected: _filtroFacturacion == 'Parcialmente facturado',
                  onSelected: (bool selected) {
                    setState(
                      () => _filtroFacturacion = selected
                          ? 'Parcialmente facturado'
                          : 'Todos',
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'No facturado',
                  color: Colors.red.shade100,
                  selected: _filtroFacturacion == 'No facturado',
                  onSelected: (bool selected) {
                    setState(
                      () => _filtroFacturacion = selected
                          ? 'No facturado'
                          : 'Todos',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black87 : Colors.black54,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: color?.withOpacity(0.3) ?? Colors.grey[100],
      selectedColor: color ?? AppColors.primary.withOpacity(0.2),
      checkmarkColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? (color ?? AppColors.primary) : Colors.transparent,
        ),
      ),
    );
  }

  // --- EMPTY STATE ORIGINAL (Cuando no hay NADA en la BD) ---
  Widget _buildEmptyStateOriginal() {
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
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              if (widget.cliente.idCliente != null) {
                context.read<ServicioProvider>().cargarServiciosPorCliente(
                  widget.cliente.idCliente!,
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // --- EMPTY STATE FILTROS (Cuando no hay coincidencias) ---
  Widget _buildEmptyStateFiltros() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay resultados",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Intenta cambiar los filtros seleccionados",
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _filtroEstado = 'Todos';
                _filtroFacturacion = 'Todos';
              });
            },
            child: const Text("Limpiar filtros"),
          ),
        ],
      ),
    );
  }
}
