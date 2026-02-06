import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/admin/presentation/screens/servicio_detalle_screen.dart';
import 'package:somnolence_app/features/admin/presentation/widgets/add_servicio_dialog.dart';
import 'package:somnolence_app/features/admin/presentation/widgets/edit_nombre_servicio_dialog.dart';

class GestionServiciosScreen extends StatefulWidget {
  final ClienteModel cliente;

  const GestionServiciosScreen({super.key, required this.cliente});

  @override
  State<GestionServiciosScreen> createState() => _GestionServiciosScreenState();
}

class _GestionServiciosScreenState extends State<GestionServiciosScreen> {
  // --- VARIABLES DE FILTRO ---
  String _filtroEstado = 'Todos';
  String _filtroFacturacion = 'Todos';

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

  // --- FUNCIONES DE ACCIÓN (Placeholders para backend después) ---
  void _editarServicio(dynamic servicio) async {
    final resultado = await showDialog(
      context: context, // Usa 'context' de la clase, no del argumento
      barrierDismissible: false,
      builder: (ctx) => EditNombreServicioDialog(servicio: servicio),
    );

    if (resultado == true && mounted) {
      // Al usar 'context' de la clase, esto es seguro aunque el botón se haya ido
      context.read<ServicioProvider>().cargarServiciosPorCliente(
        widget.cliente.idCliente!,
      );
    }
  }

  // void _eliminarServicio(dynamic servicio) {
  //   showDialog(
  //     context: context, // Usa 'context' de la clase
  //     builder: (ctx) => AlertDialog(
  //       title: const Text("Confirmar eliminación"),
  //       content: Text(
  //         "¿Seguro que deseas eliminar '${servicio.nombreServicio}'?",
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text("Cancelar"),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(ctx);
  //             // Aquí iría tu lógica de borrado usando 'context' de la clase
  //           },
  //           child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicioProvider>();

    final serviciosFiltrados = provider.servicios.where((servicio) {
      if (_filtroEstado == 'Finalizados' &&
          servicio.estadoServicio != 'Finalizado') {
        return false;
      }
      if (_filtroEstado == 'Activos' &&
          servicio.estadoServicio == 'Finalizado') {
        return false;
      }
      if (_filtroFacturacion != 'Todos') {
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
          _buildFilterBar(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.servicios.isEmpty
                ? _buildEmptyStateOriginal()
                : serviciosFiltrados.isEmpty
                ? _buildEmptyStateFiltros()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                    itemCount: serviciosFiltrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final servicio = serviciosFiltrados[index];
                      final colorFondo = _getColorByFacturacion(
                        servicio.facturacion,
                      );

                      // --- AQUÍ COMIENZA EL SLIDABLE ---
                      return Slidable(
                        key: ValueKey(servicio.idServicio ?? index),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.5,
                          children: [
                            SlidableAction(
                              onPressed: (_) => _editarServicio(servicio),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Editar',
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            // SlidableAction(
                            //   onPressed: (_) => _eliminarServicio(servicio),
                            //   backgroundColor: Colors.red,
                            //   foregroundColor: Colors.white,
                            //   icon: Icons.delete,
                            //   label: 'Borrar',
                            //   borderRadius: const BorderRadius.only(
                            //     topRight: Radius.circular(12),
                            //     bottomRight: Radius.circular(12),
                            //   ),
                            // ),
                          ],
                        ),

                        // El hijo es tu Card original
                        child: Card(
                          elevation: 2,
                          color: colorFondo,
                          margin: EdgeInsets
                              .zero, // Importante para que el Slidable se vea bien
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ... (El resto de tus widgets auxiliares _buildFilterBar, _buildChoiceChip, etc. se mantienen igual)
  Widget _buildFilterBar() {
    // ... (Mismo código que tenías)
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _buildChoiceChip(
                  label: 'Todos',
                  selected:
                      _filtroEstado == 'Todos' && _filtroFacturacion == 'Todos',
                  onSelected: (bool selected) {
                    setState(() {
                      _filtroEstado = 'Todos';
                      _filtroFacturacion = 'Todos';
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
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
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

  Widget _buildEmptyStateOriginal() {
    // ... (Mismo código que tenías)
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

  Widget _buildEmptyStateFiltros() {
    // ... (Mismo código que tenías)
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
