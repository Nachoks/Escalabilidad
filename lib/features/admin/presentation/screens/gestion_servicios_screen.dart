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

  Color _getColorByFacturacion(String? facturacion) {
    switch (facturacion) {
      case 'Totalmente facturado':
        return Colors.green.shade50;
      case 'Parcialmente facturado':
        return Colors.amber.shade50;
      case 'No facturado':
      default:
        return Colors.red.shade50;
    }
  }

  void _editarServicio(dynamic servicio) async {
    final resultado = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EditNombreServicioDialog(servicio: servicio),
    );

    if (resultado == true && mounted) {
      context.read<ServicioProvider>().cargarServiciosPorCliente(
        widget.cliente.idCliente!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicioProvider>();

    final serviciosFiltrados = provider.servicios.where((servicio) {
      if (_filtroEstado == 'Finalizados' &&
          servicio.estadoServicio != 'Finalizado')
        return false;
      if (_filtroEstado == 'Activos' && servicio.estadoServicio == 'Finalizado')
        return false;
      if (_filtroFacturacion != 'Todos' &&
          (servicio.facturacion ?? 'No facturado') != _filtroFacturacion)
        return false;
      return true;
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
                            "Servicios",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            widget.cliente.nombreCliente,
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
                      tooltip: 'Recargar',
                      onPressed: () => provider.cargarServiciosPorCliente(
                        widget.cliente.idCliente!,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Servicios",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.cliente.nombreCliente,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
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
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    AddServicioDialog(cliente: widget.cliente),
              );
            },
            label: isDesktop
                ? const Text(
                    "NUEVO SERVICIO",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text("Nuevo Servicio"),
            icon: const Icon(Icons.add),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),

          // --- CUERPO ---
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
              child: Column(
                children: [
                  _buildFilterBar(isDesktop),

                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.servicios.isEmpty
                        ? _buildEmptyStateOriginal()
                        : serviciosFiltrados.isEmpty
                        ? _buildEmptyStateFiltros()
                        : isDesktop
                        // --- GRILLA PARA PC ---
                        ? GridView.builder(
                            padding: const EdgeInsets.all(32),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      2, // Dos columnas de tarjetas largas
                                  childAspectRatio: 3.5, // Tarjetas anchas
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                ),
                            itemCount: serviciosFiltrados.length,
                            itemBuilder: (context, index) =>
                                _buildServicioCardDesktop(
                                  serviciosFiltrados[index],
                                ),
                          )
                        // --- LISTA PARA MÓVIL ---
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                            itemCount: serviciosFiltrados.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) =>
                                _buildServicioCardMobile(
                                  serviciosFiltrados[index],
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

  // ==========================================================
  // 💻 DISEÑO 1: TARJETA DE SERVICIO WEB (Con botón visible)
  // ==========================================================
  Widget _buildServicioCardDesktop(dynamic servicio) {
    final colorFondo = _getColorByFacturacion(servicio.facturacion);

    return Card(
      elevation: 0,
      color: colorFondo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServicioDetalleScreen(servicio: servicio),
            ),
          ).then((_) {
            if (mounted)
              context.read<ServicioProvider>().cargarServiciosPorCliente(
                widget.cliente.idCliente!,
              );
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 24,
                child: const Icon(Icons.work_outline, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      servicio.nombreServicio,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
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
                              vertical: 4,
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      servicio.facturacion ?? "No facturado",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              // Botón de editar visible (en vez de Slidable)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Editar nombre',
                onPressed: () => _editarServicio(servicio),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 📱 DISEÑO 2: TARJETA DE SERVICIO MÓVIL (Con Slidable original)
  // ==========================================================
  Widget _buildServicioCardMobile(dynamic servicio) {
    final colorFondo = _getColorByFacturacion(servicio.facturacion);

    return Slidable(
      key: ValueKey(servicio.idServicio),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
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
        ],
      ),
      child: Card(
        elevation: 2,
        color: colorFondo,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.5),
            child: const Icon(Icons.work_outline, color: Colors.black54),
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
                        style: TextStyle(fontSize: 10, color: Colors.white),
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
                builder: (_) => ServicioDetalleScreen(servicio: servicio),
              ),
            ).then((_) {
              if (mounted)
                context.read<ServicioProvider>().cargarServiciosPorCliente(
                  widget.cliente.idCliente!,
                );
            });
          },
        ),
      ),
    );
  }

  // --- COMPONENTES AUXILIARES ---
  Widget _buildFilterBar(bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        // Si es web, le damos un borde redondeado para que no quede pegado a los bordes
        borderRadius: isDesktop
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: isDesktop ? 32 : 16,
      ),
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
                  onSelected: (b) => setState(() {
                    _filtroEstado = 'Todos';
                    _filtroFacturacion = 'Todos';
                  }),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Activos',
                  selected: _filtroEstado == 'Activos',
                  onSelected: (b) =>
                      setState(() => _filtroEstado = b ? 'Activos' : 'Todos'),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Finalizados',
                  selected: _filtroEstado == 'Finalizados',
                  onSelected: (b) => setState(
                    () => _filtroEstado = b ? 'Finalizados' : 'Todos',
                  ),
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                _buildChoiceChip(
                  label: 'Totalmente',
                  color: Colors.green.shade200,
                  selected: _filtroFacturacion == 'Totalmente facturado',
                  onSelected: (b) => setState(
                    () => _filtroFacturacion = b
                        ? 'Totalmente facturado'
                        : 'Todos',
                  ),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Parcialmente',
                  color: Colors.amber.shade200,
                  selected: _filtroFacturacion == 'Parcialmente facturado',
                  onSelected: (b) => setState(
                    () => _filtroFacturacion = b
                        ? 'Parcialmente facturado'
                        : 'Todos',
                  ),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'No facturado',
                  color: Colors.red.shade200,
                  selected: _filtroFacturacion == 'No facturado',
                  onSelected: (b) => setState(
                    () => _filtroFacturacion = b ? 'No facturado' : 'Todos',
                  ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay servicios",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text("Crea uno nuevo para comenzar"),
        ],
      ),
    );
  }

  Widget _buildEmptyStateFiltros() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay resultados",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() {
              _filtroEstado = 'Todos';
              _filtroFacturacion = 'Todos';
            }),
            child: const Text("Limpiar filtros"),
          ),
        ],
      ),
    );
  }
}
