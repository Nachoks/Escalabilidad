import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/servicio_model.dart';
import 'package:somnolence_app/features/admin/data/models/oc_cliente_model.dart';
import 'oc_detalle_screen.dart';

class ServicioDetalleScreen extends StatefulWidget {
  final ServicioModel servicio;

  const ServicioDetalleScreen({super.key, required this.servicio});

  @override
  State<ServicioDetalleScreen> createState() => _ServicioDetalleScreenState();
}

class _ServicioDetalleScreenState extends State<ServicioDetalleScreen> {
  late ServicioModel servicioActual;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    servicioActual = widget.servicio;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _actualizarLocalmente(Function updateFn) {
    if (mounted) {
      setState(() {
        updateFn();
      });
    }
  }

  String _formatearFecha(String fechaString) {
    if (fechaString.isEmpty) return "";
    try {
      final DateTime fecha = DateTime.parse(fechaString);
      return DateFormat('dd-MM-yyyy').format(fecha);
    } catch (e) {
      return fechaString;
    }
  }

  Future<void> _recargarDatos() async {
    setState(() {});
  }

  // --- LÓGICA PARA ELIMINAR OC ---
  Future<void> _eliminarOc(OcClienteModel oc) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Orden de Compra"),
        content: Text(
          "¿Estás seguro de eliminar la OC '${oc.codOcCliente}'?\n\n Esto eliminará también todas sus Guías HAS asociadas.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Eliminando OC...")));

    final success = await ApiService.eliminarOc(oc.idOcCliente);

    if (!mounted) return;

    if (success) {
      _actualizarLocalmente(() {
        servicioActual.ocs.removeWhere(
          (item) => item.idOcCliente == oc.idOcCliente,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ OC eliminada correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error al eliminar OC"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFinalizado = servicioActual.estadoServicio == 'Finalizado';
    Color estadoColor = isFinalizado ? Colors.grey : Colors.green;

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
                  backgroundColor: isFinalizado
                      ? Colors.grey.shade700
                      : AppColors.primary,
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
                      Text(
                        "Servicio: ${servicioActual.centroCosto ?? 'Sin CC'}",
                        style: const TextStyle(
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
                  title: Text(
                    servicioActual.centroCosto ?? "Detalle Servicio",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: isFinalizado
                      ? Colors.grey
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: isFinalizado
                          ? null
                          : LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                            ),
                    ),
                  ),
                ),

          // --- CUERPO ADAPTATIVO ---
          body: isDesktop
              ? _buildDesktopLayout(isFinalizado, estadoColor)
              : _buildMobileLayout(isFinalizado, estadoColor),
        );
      },
    );
  }

  // ==========================================================
  // 💻 DISEÑO 1: ESCRITORIO (WEB / PC) - 2 COLUMNAS
  // ==========================================================
  Widget _buildDesktopLayout(bool isFinalizado, Color estadoColor) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200), // Ancho máximo
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COLUMNA IZQUIERDA: Info del Servicio y Botones
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildInfoCard(isFinalizado, estadoColor, isDesktop: true),
                    const SizedBox(height: 24),
                    _buildActionButtons(isFinalizado),
                  ],
                ),
              ),
              const SizedBox(width: 40),

              // COLUMNA DERECHA: Lista de OCs
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildSectionHeader(
                          "Órdenes de Compra (OC)",
                          _showAddOcDialog,
                          isDesktop: true,
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        // Permite scrollear la lista de OCs sin mover la info de la izquierda
                        child: servicioActual.ocs.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding: const EdgeInsets.all(24),
                                itemCount: servicioActual.ocs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) =>
                                    _buildOcCardDesktop(
                                      servicioActual.ocs[index],
                                    ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 📱 DISEÑO 2: MÓVIL (Mantenido casi igual)
  // ==========================================================
  Widget _buildMobileLayout(bool isFinalizado, Color estadoColor) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(isFinalizado, estadoColor, isDesktop: false),
            const SizedBox(height: 24),
            _buildSectionHeader(
              "Órdenes de Compra (OC)",
              _showAddOcDialog,
              isDesktop: false,
            ),
            const SizedBox(height: 10),
            if (servicioActual.ocs.isEmpty)
              _buildEmptyState()
            else
              Column(
                children: servicioActual.ocs
                    .map((oc) => _buildOcCardMobile(oc))
                    .toList(),
              ),
            const SizedBox(height: 40),
            _buildActionButtons(isFinalizado),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE INFORMACIÓN ---
  Widget _buildInfoCard(
    bool isFinalizado,
    Color color, {
    required bool isDesktop,
  }) {
    return Card(
      elevation: isDesktop ? 0 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          children: [
            Text(
              servicioActual.nombreServicio,
              style: TextStyle(
                fontSize: isDesktop ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _rowInfo(
              "Fecha Inicio:",
              _formatearFecha(servicioActual.fechaInicio ?? "---"),
            ),
            const SizedBox(height: 12),
            _rowInfo(
              "Fecha Término:",
              _formatearFecha(servicioActual.fechaTermino ?? "---"),
            ),
            const SizedBox(height: 12),
            _rowInfo(
              "Facturación:",
              servicioActual.facturacion ?? "No facturado",
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color),
              ),
              child: Text(
                servicioActual.estadoServicio.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    VoidCallback onAdd, {
    required bool isDesktop,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (isDesktop)
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Agregar OC"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          )
        else
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.primary,
              size: 30,
            ),
            onPressed: onAdd,
            tooltip: "Agregar OC",
          ),
      ],
    );
  }

  // --- WIDGETS DE LA LISTA DE OCs ---

  // Para Móvil: Usa Slidable
  Widget _buildOcCardMobile(OcClienteModel oc) {
    return Slidable(
      key: ValueKey(oc.idOcCliente),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) => _eliminarOc(oc),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Borrar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: _buildOcCardContent(oc),
    );
  }

  // Para Web/PC: Usa Botón Icono explícito (Sin Slidable)
  Widget _buildOcCardDesktop(OcClienteModel oc) {
    return _buildOcCardContent(oc, isDesktop: true);
  }

  // Contenido base de la tarjeta (Compartido)
  Widget _buildOcCardContent(OcClienteModel oc, {bool isDesktop = false}) {
    return Card(
      elevation: isDesktop ? 0 : 2,
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.shopping_bag, color: AppColors.primary),
        ),
        title: Text(
          oc.codOcCliente,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "${oc.guias.length} Guías asociadas",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isDesktop
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Eliminar OC',
                    onPressed: () => _eliminarOc(oc),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              )
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OcDetalleScreen(oc: oc)),
          );
          _recargarDatos();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay Órdenes de Compra registradas",
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTONES DE ACCIÓN (Compartidos) ---
  Widget _buildActionButtons(bool isFinalizado) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.edit_calendar),
            label: const Text(
              "MODIFICAR INFO",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _showEditInfoDialog,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isFinalizado
                  ? Colors.blueGrey
                  : Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(
              isFinalizado ? Icons.update : Icons.check_circle_outline,
            ),
            label: Text(
              isFinalizado ? "ACTUALIZAR FECHA" : "FINALIZAR SERVICIO",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _showFinalizarDialog,
          ),
        ),
        if (isFinalizado) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.restore_from_trash),
              label: const Text(
                "REACTIVAR SERVICIO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _showReactivarDialog,
            ),
          ),
        ],
      ],
    );
  }

  // ==========================
  // === LÓGICA DE DIÁLOGOS (Sin cambios) ===
  // ==========================

  void _showAddOcDialog() {
    _textController.clear();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateBd) {
            return PopScope(
              canPop: !isSaving,
              child: AlertDialog(
                title: const Text("Agregar Orden de Compra"),
                content: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: "Código OC",
                    hintText: "Ej: OC-4500123",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                  enabled: !isSaving,
                ),
                actions: [
                  if (!isSaving)
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("Cancelar"),
                    ),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (_textController.text.isEmpty) return;
                            setStateBd(() => isSaving = true);
                            final codigoOc = _textController.text;
                            final int? nuevoIdReal = await ApiService.agregarOc(
                              servicioActual.idServicio!,
                              codigoOc,
                            );

                            if (nuevoIdReal != null) {
                              if (dialogContext.mounted)
                                Navigator.pop(dialogContext);
                              _actualizarLocalmente(() {
                                servicioActual.ocs.add(
                                  OcClienteModel(
                                    idOcCliente: nuevoIdReal,
                                    idServicio: servicioActual.idServicio!,
                                    codOcCliente: codigoOc,
                                    guias: [],
                                  ),
                                );
                              });
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text("OC Agregada"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              if (context.mounted)
                                setStateBd(() => isSaving = false);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text("Error al guardar OC"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Guardar"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditInfoDialog() {
    String? nuevaFecha = servicioActual.fechaInicio;
    String nuevaFacturacion = servicioActual.facturacion ?? "No facturado";
    final List<String> opciones = [
      "Totalmente facturado",
      "Parcialmente facturado",
      "No facturado",
    ];
    if (!opciones.contains(nuevaFacturacion)) nuevaFacturacion = "No facturado";

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (sbContext, setStateBd) {
            return PopScope(
              canPop: !isSaving,
              child: AlertDialog(
                title: const Text("Actualizar Info"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        _formatearFecha(nuevaFecha ?? "Toca para elegir fecha"),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      enabled: !isSaving,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setStateBd(
                            () => nuevaFecha = picked.toIso8601String().split(
                              'T',
                            )[0],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: nuevaFacturacion,
                      items: opciones
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: isSaving
                          ? null
                          : (val) {
                              if (val != null)
                                setStateBd(() => nuevaFacturacion = val);
                            },
                      decoration: const InputDecoration(
                        labelText: "Estado Facturación",
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (!isSaving)
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("Cancelar"),
                    ),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setStateBd(() => isSaving = true);
                            bool success = false;
                            try {
                              success = await ApiService.updateServiceInfo(
                                servicioActual.idServicio!,
                                nuevaFecha,
                                nuevaFacturacion,
                              );
                            } catch (e) {
                              success = false;
                            }

                            if (success) {
                              _actualizarLocalmente(() {
                                servicioActual = ServicioModel(
                                  idServicio: servicioActual.idServicio,
                                  nombreServicio: servicioActual.nombreServicio,
                                  idCliente: servicioActual.idCliente,
                                  idArea: servicioActual.idArea,
                                  centroCosto: servicioActual.centroCosto,
                                  fechaTermino: servicioActual.fechaTermino,
                                  estadoServicio: servicioActual.estadoServicio,
                                  ocs: servicioActual.ocs,
                                  fechaInicio: nuevaFecha,
                                  facturacion: nuevaFacturacion,
                                );
                              });
                              if (dialogContext.mounted)
                                Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text("Actualizado"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              if (sbContext.mounted)
                                setStateBd(() => isSaving = false);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text("Error al actualizar"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Guardar"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFinalizarDialog() {
    String? fechaFin = servicioActual.fechaTermino;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (sbContext, setStateBd) => PopScope(
          canPop: !isSaving,
          child: AlertDialog(
            title: const Text("Finalizar Servicio"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Selecciona la fecha de término del servicio."),
                const SizedBox(height: 20),
                ListTile(
                  tileColor: Colors.grey[100],
                  title: Text(_formatearFecha(fechaFin ?? "---")),
                  trailing: const Icon(Icons.event_busy, color: Colors.red),
                  enabled: !isSaving,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setStateBd(
                        () => fechaFin = picked.toIso8601String().split('T')[0],
                      );
                    }
                  },
                ),
              ],
            ),
            actions: [
              if (!isSaving)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancelar"),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        if (fechaFin == null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text("Selecciona una fecha"),
                            ),
                          );
                          return;
                        }
                        setStateBd(() => isSaving = true);
                        bool success = false;
                        try {
                          success = await ApiService.finalizarServicio(
                            servicioActual.idServicio!,
                            fechaFin!,
                          );
                        } catch (e) {
                          success = false;
                        }

                        if (success) {
                          _actualizarLocalmente(() {
                            servicioActual = ServicioModel(
                              idServicio: servicioActual.idServicio,
                              nombreServicio: servicioActual.nombreServicio,
                              idCliente: servicioActual.idCliente,
                              idArea: servicioActual.idArea,
                              centroCosto: servicioActual.centroCosto,
                              fechaTermino: fechaFin,
                              estadoServicio: 'Finalizado',
                              ocs: servicioActual.ocs,
                              fechaInicio: servicioActual.fechaInicio,
                              facturacion: servicioActual.facturacion,
                            );
                          });
                          if (dialogContext.mounted)
                            Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text("Servicio FINALIZADO"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          if (sbContext.mounted)
                            setStateBd(() => isSaving = false);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text("Error al finalizar."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("FINALIZAR"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReactivarDialog() {
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (sbContext, setStateBd) => PopScope(
          canPop: !isSaving,
          child: AlertDialog(
            title: const Text("Reactivar Servicio"),
            content: const Text(
              "¿Deseas habilitar este servicio nuevamente?\nSe borrará la fecha de término y volverá al estado 'Activo'.",
            ),
            actions: [
              if (!isSaving)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancelar"),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        setStateBd(() => isSaving = true);
                        bool success = false;
                        try {
                          success = await ApiService.reactivarServicio(
                            servicioActual.idServicio!,
                          );
                        } catch (e) {
                          success = false;
                        }

                        if (success) {
                          _actualizarLocalmente(() {
                            servicioActual = ServicioModel(
                              idServicio: servicioActual.idServicio,
                              nombreServicio: servicioActual.nombreServicio,
                              idCliente: servicioActual.idCliente,
                              idArea: servicioActual.idArea,
                              centroCosto: servicioActual.centroCosto,
                              fechaTermino: null,
                              estadoServicio: 'Activo',
                              ocs: servicioActual.ocs,
                              fechaInicio: servicioActual.fechaInicio,
                              facturacion: servicioActual.facturacion,
                            );
                          });
                          if (dialogContext.mounted)
                            Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text("Servicio REACTIVADO"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          if (sbContext.mounted)
                            setStateBd(() => isSaving = false);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text("Error al reactivar"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("REACTIVAR"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
