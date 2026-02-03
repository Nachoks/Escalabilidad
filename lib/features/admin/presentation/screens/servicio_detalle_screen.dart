import 'package:flutter/material.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/servicio_model.dart';
import 'package:somnolence_app/features/admin/data/models/oc_cliente_model.dart';
// 👇 Asegúrate de crear este archivo (el segundo código que te mandaré si me lo pides)
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

  // Método para actualizar la UI
  void _actualizarLocalmente(Function updateFn) {
    if (mounted) {
      setState(() {
        updateFn();
      });
    }
  }

  // Recargar datos al volver de la pantalla de OC
  Future<void> _recargarDatos() async {
    // Aquí idealmente harías un fetch del servicio actualizado desde la API
    // Por ahora hacemos un setState para asegurar que se refresque la vista si hubo cambios
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isFinalizado = servicioActual.estadoServicio == 'Finalizado';
    Color estadoColor = isFinalizado ? Colors.grey : Colors.green;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          servicioActual.centroCosto ?? "Detalle Servicio",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isFinalizado ? Colors.grey : AppColors.primary,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tarjeta de Información General
              _buildInfoCard(isFinalizado, estadoColor),
              const SizedBox(height: 24),

              // 2. Sección de Órdenes de Compra (OC)
              _buildSectionHeader(
                "Órdenes de Compra (OC)",
                () => _showAddOcDialog(),
              ),
              const SizedBox(height: 10),

              // Lista de OCs
              if (servicioActual.ocs.isEmpty)
                _buildEmptyState()
              else
                Column(
                  children: servicioActual.ocs
                      .map((oc) => _buildOcCard(oc))
                      .toList(),
                ),

              const SizedBox(height: 40),

              // 3. Botones de Acción (Modificar, Finalizar, Reactivar)
              _buildActionButtons(isFinalizado),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE LA LISTA ---

  Widget _buildOcCard(OcClienteModel oc) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () async {
          // NAVEGACIÓN A LA VISTA DE HAS (OC DETALLE)
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OcDetalleScreen(oc: oc)),
          );
          // Al volver, recargamos (opcional)
          _recargarDatos();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_off, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "No hay Órdenes de Compra registradas",
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE INFORMACIÓN (Tus widgets originales) ---

  Widget _buildInfoCard(bool isFinalizado, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              servicioActual.nombreServicio,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            _rowInfo("Fecha Inicio:", servicioActual.fechaInicio ?? "---"),
            _rowInfo(
              "Fecha Término:",
              servicioActual.fechaTermino ?? "En curso",
            ),
            const SizedBox(height: 8),
            _rowInfo(
              "Facturación:",
              servicioActual.facturacion ?? "No facturado",
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Text(
                servicioActual.estadoServicio,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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

  Widget _buildActionButtons(bool isFinalizado) {
    return Column(
      children: [
        // BOTÓN 1: MODIFICAR INFO
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
            label: const Text("MODIFICAR INFO (Fechas / Facturación)"),
            onPressed: _showEditInfoDialog,
          ),
        ),
        const SizedBox(height: 16),

        // BOTÓN 2: FINALIZAR / ACTUALIZAR FECHA
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
              isFinalizado ? "ACTUALIZAR FECHA TÉRMINO" : "FINALIZAR SERVICIO",
            ),
            onPressed: _showFinalizarDialog,
          ),
        ),

        // BOTÓN 3: REACTIVAR
        if (isFinalizado) ...[
          const SizedBox(height: 16),
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
              label: const Text("REACTIVAR SERVICIO"),
              onPressed: _showReactivarDialog,
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // === LÓGICA DE DIÁLOGOS ===
  // ===========================================================================

  // 1. Agregar SOLO OC
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

                            // 1. LLAMADA AL API (Esperamos el ID)
                            final int? nuevoIdReal = await ApiService.agregarOc(
                              servicioActual.idServicio!,
                              codigoOc,
                            );

                            if (nuevoIdReal != null) {
                              // ÉXITO: Tenemos el ID real del servidor
                              if (dialogContext.mounted)
                                Navigator.pop(dialogContext);

                              // 2. ACTUALIZAMOS LA LISTA CON EL ID REAL
                              _actualizarLocalmente(() {
                                servicioActual.ocs.add(
                                  OcClienteModel(
                                    idOcCliente:
                                        nuevoIdReal, // <--- ID REAL (No 0)
                                    idServicio: servicioActual.idServicio!,
                                    codOcCliente: codigoOc,
                                    guias: [],
                                  ),
                                );
                              });

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text("OC Agregada correctamente"),
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

  // 2. Modificar Info (Tus funciones originales intactas)
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
                      title: Text(nuevaFecha ?? "Toca para elegir fecha"),
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
                            final messenger = ScaffoldMessenger.of(
                              this.context,
                            );

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
                                // Reconstruimos el modelo con los datos nuevos
                                servicioActual = ServicioModel(
                                  idServicio: servicioActual.idServicio,
                                  nombreServicio: servicioActual.nombreServicio,
                                  idCliente: servicioActual.idCliente,
                                  idArea: servicioActual.idArea,
                                  centroCosto: servicioActual.centroCosto,
                                  fechaTermino: servicioActual.fechaTermino,
                                  estadoServicio: servicioActual.estadoServicio,
                                  ocs: servicioActual.ocs, // Mantenemos OCs
                                  fechaInicio: nuevaFecha,
                                  facturacion: nuevaFacturacion,
                                );
                              });

                              if (dialogContext.mounted)
                                Navigator.pop(dialogContext);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text("Actualizado"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              if (sbContext.mounted)
                                setStateBd(() => isSaving = false);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text("Error al actualizar"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
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

  // 3. Finalizar Servicio
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
                  title: Text(fechaFin ?? "Seleccionar Fecha Término"),
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
                        final messenger = ScaffoldMessenger.of(this.context);

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
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("Servicio FINALIZADO"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          if (sbContext.mounted)
                            setStateBd(() => isSaving = false);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("Error al finalizar."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("FINALIZAR"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Reactivar Servicio
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
                        final messenger = ScaffoldMessenger.of(this.context);

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
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("Servicio REACTIVADO"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          if (sbContext.mounted)
                            setStateBd(() => isSaving = false);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text("Error al reactivar"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("REACTIVAR"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
