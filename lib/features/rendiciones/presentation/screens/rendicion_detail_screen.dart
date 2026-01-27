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
    if (widget.rendicion.idRendicion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GastoProvider>().cargarGastos(
          widget.rendicion.idRendicion!,
        );
      });
    }
  }

  String _formatMoney(int? amount) {
    if (amount == null) return "\$0";
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // --- GENERAR PDF ---
  Future<void> _generarPdf() async {
    final provider = context.read<GastoProvider>();
    final gastos = provider.gastos;

    if (gastos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay gastos para generar el reporte.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Generando PDF..."),
        duration: Duration(seconds: 1),
      ),
    );

    try {
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

  // --- VER EVIDENCIA (MEJORADO CON HEADERS) ---
  void _verEvidencia(BuildContext context, dynamic archivo) {
    String rutaLimpia = archivo.rutaRelativa.replaceAll('\\', '/');

    if (rutaLimpia.startsWith('public/')) {
      rutaLimpia = rutaLimpia.replaceFirst('public/', '');
    }
    if (rutaLimpia.startsWith('/')) {
      rutaLimpia = rutaLimpia.substring(1);
    }

    final apiUrl = AppConstants.apiUrl.endsWith('/')
        ? AppConstants.apiUrl.substring(0, AppConstants.apiUrl.length - 1)
        : AppConstants.apiUrl;

    final urlString = "$apiUrl/evidencia/$rutaLimpia";
    // EncodeFull es vital para espacios
    final urlImagen = Uri.encodeFull(urlString);

    print("Abriendo imagen: $urlImagen");

    final ext = archivo.extension?.toLowerCase() ?? 'jpg';
    final bool esPdf = ext == 'pdf';

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
                              // AGREGAMOS HEADERS PARA EVITAR ERRORES 403/406
                              headers: const {
                                'User-Agent': 'SomnolenceApp/1.0',
                                'Accept':
                                    'image/jpeg,image/png,application/pdf',
                              },
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print("Error carga imagen: $error");
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "No se pudo cargar la imagen",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      urlImagen,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                );
                              },
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

  // --- SUBIR ARCHIVO ---
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

  // --- FUNCIÓN PARA VER COMPROBANTE DE PAGO ---
  void _verComprobanteDePago() {
    final ruta = widget.rendicion.rutaComprobante;
    if (ruta == null) return;

    String rutaLimpia = ruta.replaceAll('\\', '/');
    if (rutaLimpia.startsWith('public/'))
      rutaLimpia = rutaLimpia.replaceFirst('public/', '');
    if (rutaLimpia.startsWith('/')) rutaLimpia = rutaLimpia.substring(1);

    final apiUrl = AppConstants.apiUrl.endsWith('/')
        ? AppConstants.apiUrl.substring(0, AppConstants.apiUrl.length - 1)
        : AppConstants.apiUrl;

    final urlFinal = Uri.encodeFull("$apiUrl/evidencia/$rutaLimpia");
    final bool esPdf = rutaLimpia.toLowerCase().endsWith('.pdf');

    print("Viendo comprobante: $urlFinal");

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
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Comprobante de Pago",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
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
                              Text(
                                "Documento PDF",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Image.network(
                            urlFinal,
                            fit: BoxFit.contain,
                            // HEADERS TAMBIÉN AQUÍ
                            headers: const {
                              'User-Agent': 'SomnolenceApp/1.0',
                              'Accept': 'image/jpeg,image/png,application/pdf',
                            },
                            loadingBuilder: (_, child, prog) => prog == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            errorBuilder: (_, __, ___) => const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                Text("No se pudo cargar la imagen"),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: Container(
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GastoProvider>();
    final gastos = provider.gastos;

    final bool estaPagada = widget.rendicion.estado == 'Pagada';
    final bool tieneComprobante =
        widget.rendicion.rutaComprobante != null &&
        widget.rendicion.rutaComprobante!.isNotEmpty;

    int totalEnVivo = gastos.fold(0, (sum, item) => sum + item.monto);
    int montoEntregado = widget.rendicion.montoEntregado;
    int saldo = montoEntregado - totalEnVivo;

    final bool esEditable =
        !widget.soloLectura &&
        ['Borrador', 'Observada'].contains(widget.rendicion.estado);

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
        actions: [
          if (estaPagada && tieneComprobante)
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: "Ver Comprobante de Pago",
              onPressed: _verComprobanteDePago,
            ),
          if (puedeImprimir)
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: "Generar PDF",
              onPressed: _generarPdf,
            ),
        ],
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
      floatingActionButton: esEditable
          ? FloatingActionButton.extended(
              onPressed: () {
                if (widget.rendicion.idRendicion != null) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AddGastoDialog(
                      idRendicion: widget.rendicion.idRendicion!,
                    ),
                  );
                }
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

          // LISTA DE GASTOS
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
                      if (gasto.idGasto == null) return SizedBox.shrink();

                      final bool tieneEvidencia = gasto.fotos.isNotEmpty;
                      final bool esRechazado = gasto.estado == 'Rechazado';
                      final String? comentario = gasto.comentario;

                      final String extension = tieneEvidencia
                          ? (gasto.fotos[0].extension).toUpperCase()
                          : '';
                      final bool esPdf = extension == 'PDF';

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

                                      // --- BADGES + BOTÓN DE VER ARCHIVO ---
                                      Row(
                                        children: [
                                          // Badge Estado
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

                                          // Badge Tipo Archivo
                                          if (tieneEvidencia) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: esPdf
                                                    ? Colors.red.shade700
                                                    : Colors.blue.shade600,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    esPdf
                                                        ? Icons.picture_as_pdf
                                                        : Icons.image,
                                                    color: Colors.white,
                                                    size: 10,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    extension,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // --- NUEVO BOTÓN "VER" AQUÍ ---
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () => _verEvidencia(
                                                context,
                                                gasto.fotos[0],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  color: Colors.white,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.visibility,
                                                      size: 12,
                                                      color: Colors.black87,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Text(
                                                      "VER",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // -------------------------------
                                          ],
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
                                      else if (!esEditable)
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
