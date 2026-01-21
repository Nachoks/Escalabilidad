import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/constants/app_constants.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/widget/add_gasto_dialog.dart';
// IMPORTANTE: Asegúrate de importar el archivo PDF Builder que creamos arriba
import 'package:somnolence_app/features/rendiciones/presentation/utils/rendicion_pdf_builder.dart';

class RendicionDetailScreen extends StatefulWidget {
  final RendicionModel rendicion;
  final bool soloLectura;

  const RendicionDetailScreen({
    super.key,
    required this.rendicion,
    this.soloLectura = false,
  });

  @override
  State<RendicionDetailScreen> createState() => _RendicionDetailScreenState();
}

class _RendicionDetailScreenState extends State<RendicionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GastoProvider>().cargarGastos(widget.rendicion.idRendicion!);
    });
  }

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // --- FUNCIÓN PARA GENERAR EL PDF ---
  Future<void> _generarPdf() async {
    final provider = context.read<GastoProvider>();
    final gastos = provider.gastos;

    if (gastos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay gastos para generar el reporte.")),
      );
      return;
    }

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Generando PDF..."),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // Llamamos a nuestro utilitario
      await RendicionPdfBuilder.imprimirRendicion(widget.rendicion, gastos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al generar PDF: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- VISUALIZAR EVIDENCIA (POPUP) ---
  void _verEvidencia(BuildContext context, dynamic archivo) {
    final baseUrl = AppConstants.apiUrl.replaceAll(RegExp(r'/api/?$'), '');
    String rutaLimpia = archivo.rutaRelativa;
    if (rutaLimpia.startsWith('public/')) {
      rutaLimpia = rutaLimpia.replaceFirst('public/', '');
    }
    final urlImagen = "$baseUrl/storage/$rutaLimpia";
    final bool esPdf = archivo.extension == 'pdf';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Evidencia Adjunta",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: esPdf
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                size: 80,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Documento PDF",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              urlImagen,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DE ARCHIVOS ---
  Future<void> _adjuntarEvidencia(int idGasto) async {
    final ImagePicker picker = ImagePicker();
    String? pathSeleccionado;
    final String? opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Tomar Foto"),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Galería"),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("PDF"),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );
    if (opcion == null) return;
    if (opcion == 'camera' || opcion == 'gallery') {
      final XFile? photo = await picker.pickImage(
        source: opcion == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50,
      );
      pathSeleccionado = photo?.path;
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      pathSeleccionado = result?.files.single.path;
    }

    if (pathSeleccionado != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subiendo..."),
          duration: Duration(seconds: 1),
        ),
      );
      await context.read<GastoProvider>().subirEvidencia(
        idGasto,
        widget.rendicion.idRendicion!,
        pathSeleccionado,
      );
    }
  }

  Future<void> _borrarArchivo(int idGasto) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Evidencia"),
        content: const Text("¿Borrar archivo?"),
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
    if (confirmar == true && mounted) {
      await context.read<GastoProvider>().eliminarEvidencia(
        idGasto,
        widget.rendicion.idRendicion!,
      );
    }
  }

  Future<void> _confirmarBorrarGasto(int idGasto) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Gasto"),
        content: const Text("¿Eliminar gasto completo?"),
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
    if (confirmar == true && mounted) {
      await context.read<GastoProvider>().eliminarGastoCompleto(idGasto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GastoProvider>();
    final gastos = provider.gastos;

    int totalEnVivo = gastos.fold(0, (sum, item) => sum + item.monto);
    int montoEntregado = widget.rendicion.montoEntregado;
    int saldo = montoEntregado - totalEnVivo;

    // LÓGICA DE EDICIÓN
    final bool esEditable =
        !widget.soloLectura &&
        ['Borrador', 'Observada'].contains(widget.rendicion.estado);

    // LÓGICA DE IMPRESIÓN (NUEVO)
    // Se puede imprimir si es 'Pagada' o 'Aprobada', o si estamos en el Historial (soloLectura)
    final bool puedeImprimir =
        widget.soloLectura ||
        ['Pagada', 'Aprobada'].contains(widget.rendicion.estado);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.soloLectura ? "Historial Detalle" : "Detalle Rendición",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        // --- AQUÍ ESTÁ EL BOTÓN DE PDF EN LA BARRA SUPERIOR ---
        actions: [
          if (puedeImprimir)
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: "Generar PDF",
              onPressed: _generarPdf, // Llama a la función que creamos arriba
            ),
        ],
      ),
      floatingActionButton: esEditable
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AddGastoDialog(
                    idRendicion: widget.rendicion.idRendicion!,
                  ),
                );
              },
              label: const Text("Agregar Gasto"),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          // PANEL DE CONTROL
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ASIGNADO",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      _formatMoney(montoEntregado),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey[300]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "TOTAL (con iva)",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      _formatMoney(totalEnVivo),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey[300]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "POR RENDIR",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      _formatMoney(saldo),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: saldo >= 0
                            ? Colors.green[700]
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : gastos.isEmpty
                ? const Center(child: Text("No hay gastos registrados"))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: gastos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final gasto = gastos[index];
                      final bool tieneEvidencia = gasto.fotos.isNotEmpty;
                      final bool esRechazado = gasto.estado == 'Rechazado';
                      final String? comentario = gasto.comentario;

                      final Color colorEstado = esRechazado
                          ? Colors.red
                          : (tieneEvidencia ? Colors.green : Colors.orange);
                      final Color colorFondo = esRechazado
                          ? Colors.red.shade50
                          : (tieneEvidencia
                                ? Colors.white
                                : Colors.orange.shade50);

                      return Slidable(
                        key: ValueKey(gasto.idGasto),
                        enabled: esEditable,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.3,
                          children: [
                            SlidableAction(
                              onPressed: (_) =>
                                  _confirmarBorrarGasto(gasto.idGasto!),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Borrar',
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: tieneEvidencia ? 1 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: colorEstado.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          color: colorFondo,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  isThreeLine: true,
                                  onLongPress: esEditable
                                      ? () => _confirmarBorrarGasto(
                                          gasto.idGasto!,
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorEstado.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      esRechazado
                                          ? Icons.highlight_off
                                          : Icons.receipt_long,
                                      color: colorEstado,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    gasto.detalle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        "${gasto.fecha} • ${gasto.tipoDocumento}",
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorEstado,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              esRechazado
                                                  ? "RECHAZADO"
                                                  : (tieneEvidencia
                                                        ? "EVIDENCIA OK"
                                                        : "FALTA FOTO"),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatMoney(gasto.monto),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),

                                      // BOTONES DE ACCIÓN (Ojo / Cámara / Candado)
                                      if (esEditable)
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          onTap: () {
                                            if (!tieneEvidencia) {
                                              _adjuntarEvidencia(
                                                gasto.idGasto!,
                                              );
                                            } else {
                                              _borrarArchivo(gasto.idGasto!);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              tieneEvidencia
                                                  ? Icons.delete_forever
                                                  : Icons.camera_alt,
                                              color: tieneEvidencia
                                                  ? Colors.red.shade400
                                                  : colorEstado,
                                              size: 26,
                                            ),
                                          ),
                                        )
                                      else if (tieneEvidencia)
                                        // SI ES SOLO LECTURA y tiene evidencia -> Icono de OJO para ver
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          onTap: () => _verEvidencia(
                                            context,
                                            gasto.fotos[0],
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.visibility,
                                              size: 24,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        )
                                      else
                                        // Si es solo lectura y NO tiene evidencia -> Candado
                                        const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.lock_outline,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (esRechazado &&
                                    comentario != null &&
                                    comentario.isNotEmpty) ...[
                                  const Divider(
                                    color: Colors.red,
                                    height: 20,
                                    thickness: 0.5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      8,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.comment,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Observación: $comentario",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
}
