import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // --- WIDGET PARA MOSTRAR BOTÓN DE PDF EN WEB (VER + DESCARGAR) ---
  Widget _buildPdfWebFallback(String url) {
    final Uri? parsedUri = Uri.tryParse(url);
    final bool isValidUrl = parsedUri != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Documento PDF",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Selecciona una opción para continuar:",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Botón para ver en línea
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isValidUrl ? () => _abrirPdfEnLinea(url) : null,
                icon: const Icon(Icons.open_in_browser),
                label: const Text(
                  "Ver en Línea",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Botón para descargar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _descargarPdfWeb(url),
                icon: const Icon(Icons.download),
                label: const Text(
                  "Descargar PDF",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ABRIR PDF EN LÍNEA EN NUEVA VENTANA ---
  Future<void> _abrirPdfEnLinea(String urlPdf) async {
    try {
      final uri = Uri.parse(urlPdf);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo abrir el PDF"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error abriendo PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al abrir: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- DESCARGAR PDF EN WEB ---
  Future<void> _descargarPdfWeb(String urlPdf) async {
    try {
      final uri = Uri.parse(urlPdf);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Error descargando PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al descargar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- VER EVIDENCIA ---
  void _verEvidencia(BuildContext context, dynamic archivo) {
    String rutaLimpia = archivo.rutaRelativa.replaceAll('\\', '/');
    if (rutaLimpia.startsWith('public/')) {
      rutaLimpia = rutaLimpia.replaceFirst('public/', '');
    }
    if (rutaLimpia.startsWith('/')) rutaLimpia = rutaLimpia.substring(1);

    final apiUrl = AppConstants.apiUrl.endsWith('/')
        ? AppConstants.apiUrl.substring(0, AppConstants.apiUrl.length - 1)
        : AppConstants.apiUrl;
    final urlString = "$apiUrl/evidencia/$rutaLimpia";
    final urlImagen = Uri.encodeFull(urlString);

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
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                maxWidth: 800,
              ), // Max width para web
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      esPdf ? "Documento PDF" : "Evidencia Adjunta",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: esPdf
                        // 👇 SI ES WEB MOSTRAMOS EL BOTÓN, SI ES MÓVIL EL PDFVIEWER 👇
                        ? (kIsWeb
                              ? _buildPdfWebFallback(urlImagen)
                              : const PDF(
                                  enableSwipe: true,
                                  swipeHorizontal: true,
                                  autoSpacing: false,
                                  pageFling: false,
                                ).fromUrl(
                                  urlImagen,
                                  placeholder: (progress) =>
                                      Center(child: Text('$progress %')),
                                  errorWidget: (error) => Center(
                                    child: Text("Error al cargar PDF: $error"),
                                  ),
                                ))
                        : InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              urlImagen,
                              fit: BoxFit.contain,
                              headers: const {
                                'User-Agent': 'SomnolenceApp/1.0',
                              },
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      Text("Error al cargar imagen"),
                                    ],
                                  ),
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
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- VER COMPROBANTE DE PAGO ---
  void _verComprobanteDePago() {
    final ruta = widget.rendicion.rutaComprobante;
    if (ruta == null) return;

    String rutaLimpia = ruta.replaceAll('\\', '/');
    if (rutaLimpia.startsWith('public/')) {
      rutaLimpia = rutaLimpia.replaceFirst('public/', '');
    }
    if (rutaLimpia.startsWith('/')) rutaLimpia = rutaLimpia.substring(1);

    final apiUrl = AppConstants.apiUrl.endsWith('/')
        ? AppConstants.apiUrl.substring(0, AppConstants.apiUrl.length - 1)
        : AppConstants.apiUrl;
    final urlFinal = "$apiUrl/evidencia/$rutaLimpia";
    final urlCodificada = Uri.encodeFull(urlFinal);
    final bool esPdf = rutaLimpia.toLowerCase().endsWith('.pdf');

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
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                maxWidth: 800,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
                        // 👇 SI ES WEB MOSTRAMOS EL BOTÓN, SI ES MÓVIL EL PDFVIEWER 👇
                        ? (kIsWeb
                              ? _buildPdfWebFallback(urlCodificada)
                              : const PDF(
                                  enableSwipe: true,
                                  swipeHorizontal: true,
                                  autoSpacing: false,
                                  pageFling: false,
                                ).fromUrl(
                                  urlCodificada,
                                  placeholder: (progress) =>
                                      Center(child: Text('$progress %')),
                                  errorWidget: (error) =>
                                      Center(child: Text("Error PDF: $error")),
                                ))
                        : InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              urlCodificada,
                              fit: BoxFit.contain,
                              headers: const {
                                'User-Agent': 'SomnolenceApp/1.0',
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
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SUBIR ARCHIVO ADAPTATIVO A WEB ---
  Future<void> _adjuntarEvidencia(int idGasto, bool isDesktop) async {
    final ImagePicker picker = ImagePicker();
    String? pathSeleccionado;
    Uint8List? fileBytes;
    String? fileName;

    // Menú de opciones (Cámara solo en móvil)
    Widget menuOpciones = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!kIsWeb)
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text("Tomar Foto"),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
        ListTile(
          leading: const Icon(Icons.photo_library, color: Colors.green),
          title: const Text("Galería / Imagen"),
          onTap: () => Navigator.pop(context, 'gallery'),
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: const Text("Documento PDF"),
          onTap: () => Navigator.pop(context, 'pdf'),
        ),
      ],
    );

    // Mostramos el menú según el dispositivo
    String? opcion;
    if (isDesktop) {
      opcion = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Adjuntar Evidencia"),
          content: SizedBox(width: 300, child: menuOpciones),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      );
    } else {
      opcion = await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) => SafeArea(child: menuOpciones),
      );
    }

    if (opcion == null) return;

    // --- PROCESAMIENTO SEGÚN PLATAFORMA ---
    if (opcion == 'camera' || opcion == 'gallery') {
      final XFile? photo = await picker.pickImage(
        source: opcion == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50,
      );

      if (photo != null) {
        if (kIsWeb) {
          fileBytes = await photo.readAsBytes();
          fileName = photo.name;
        } else {
          pathSeleccionado = photo.path;
        }
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
      );

      if (result != null) {
        if (kIsWeb) {
          fileBytes = result.files.single.bytes;
          fileName = result.files.single.name;
        } else {
          pathSeleccionado = result.files.single.path;
        }
      }
    }

    // --- SUBIDA A LA BASE DE DATOS ---
    if ((pathSeleccionado != null || fileBytes != null) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subiendo..."),
          duration: Duration(seconds: 1),
        ),
      );

      if (kIsWeb && fileBytes != null && fileName != null) {
        await context.read<GastoProvider>().subirEvidenciaWeb(
          idGasto,
          widget.rendicion.idRendicion!,
          fileBytes,
          fileName,
        );
      } else if (!kIsWeb && pathSeleccionado != null) {
        await context.read<GastoProvider>().subirEvidencia(
          idGasto,
          widget.rendicion.idRendicion!,
          pathSeleccionado,
        );
      }
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

  String _formatearFecha(String fechaString) {
    if (fechaString.isEmpty) return "";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(fechaString));
    } catch (e) {
      return fechaString;
    }
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
        ['Enviada', 'Pagada', 'Aprobada'].contains(widget.rendicion.estado);

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
                      Text(
                        widget.soloLectura
                            ? "Historial de Rendición"
                            : "Detalle Rendición",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    if (estaPagada && tieneComprobante)
                      ElevatedButton.icon(
                        onPressed: _verComprobanteDePago,
                        icon: const Icon(Icons.receipt_long, size: 18),
                        label: const Text("Ver Comprobante"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade800,
                          elevation: 0,
                        ),
                      ),
                    const SizedBox(width: 12),
                    if (puedeImprimir)
                      ElevatedButton.icon(
                        onPressed: _generarPdf,
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text("Imprimir"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                        ),
                      ),
                    const SizedBox(width: 32),
                  ],
                )
              : AppBar(
                  title: Text(
                    widget.soloLectura
                        ? "Historial Detalle"
                        : "Detalle Rendición",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  actions: [
                    if (estaPagada && tieneComprobante)
                      IconButton(
                        icon: const Icon(Icons.receipt_long),
                        tooltip: "Ver Comprobante",
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

          // --- BOTÓN FLOTANTE ---
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
                  label: isDesktop
                      ? const Text(
                          "AGREGAR GASTO",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : const Text("Agregar Gasto"),
                  icon: const Icon(Icons.add),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                )
              : null,

          // --- CUERPO PRINCIPAL ---
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1000 : double.infinity,
              ), // Panel central ancho
              child: Column(
                children: [
                  // --- PANEL DE CONTROL (SALDOS) ---
                  Container(
                    margin: EdgeInsets.all(isDesktop ? 32 : 0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: isDesktop
                          ? BorderRadius.circular(16)
                          : BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: isDesktop
                          ? Border.all(color: Colors.grey.shade200)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ASIGNADO",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMoney(montoEntregado),
                                style: TextStyle(
                                  fontSize: isDesktop ? 22 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "TOTAL (con iva)",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMoney(totalEnVivo),
                                style: TextStyle(
                                  fontSize: isDesktop ? 22 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "POR RENDIR",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMoney(saldo),
                                style: TextStyle(
                                  fontSize: isDesktop ? 22 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: saldo >= 0
                                      ? Colors.green[700]
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isDesktop) const SizedBox(height: 10),

                  // --- LISTA DE GASTOS ---
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : gastos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No hay gastos registrados",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 32 : 16,
                              isDesktop ? 0 : 16,
                              isDesktop ? 32 : 16,
                              120,
                            ),
                            itemCount: gastos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final gasto = gastos[index];
                              if (gasto.idGasto == null) {
                                return const SizedBox.shrink();
                              }

                              final bool tieneEvidencia =
                                  gasto.fotos.isNotEmpty;
                              final bool esRechazado =
                                  gasto.estado == 'Rechazado';
                              final String? comentario = gasto.comentario;
                              final String extension = tieneEvidencia
                                  ? (gasto.fotos[0].extension).toUpperCase()
                                  : '';
                              final bool esPdf = extension == 'PDF';

                              final Color colorEstado = esRechazado
                                  ? Colors.red
                                  : (tieneEvidencia
                                        ? Colors.green
                                        : Colors.orange);
                              final Color colorFondo = esRechazado
                                  ? Colors.red.shade50
                                  : (tieneEvidencia
                                        ? Colors.white
                                        : Colors.orange.shade50);

                              return isDesktop
                                  ? _buildGastoCardDesktop(
                                      gasto,
                                      tieneEvidencia,
                                      esRechazado,
                                      esPdf,
                                      extension,
                                      comentario,
                                      colorEstado,
                                      colorFondo,
                                      esEditable,
                                    )
                                  : _buildGastoCardMobile(
                                      gasto,
                                      tieneEvidencia,
                                      esRechazado,
                                      esPdf,
                                      extension,
                                      comentario,
                                      colorEstado,
                                      colorFondo,
                                      esEditable,
                                    );
                            },
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
  // 💻 TARJETA GASTO ESCRITORIO (Sin Slidable, Botones visibles)
  // ==========================================================
  Widget _buildGastoCardDesktop(
    dynamic gasto,
    bool tieneEvidencia,
    bool esRechazado,
    bool esPdf,
    String extension,
    String? comentario,
    Color colorEstado,
    Color colorFondo,
    bool esEditable,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorEstado.withOpacity(0.5), width: 1.5),
      ),
      color: colorFondo,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icono Izquierdo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    esRechazado ? Icons.highlight_off : Icons.receipt_long,
                    color: colorEstado,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Info Central
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gasto.detalle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${_formatearFecha(gasto.fecha)} • ${gasto.tipoDocumento}",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildBadge(
                            text: esRechazado
                                ? "RECHAZADO"
                                : (tieneEvidencia
                                      ? "EVIDENCIA OK"
                                      : "FALTA FOTO"),
                            color: colorEstado,
                          ),
                          if (tieneEvidencia) ...[
                            const SizedBox(width: 8),
                            _buildBadge(
                              text: extension,
                              color: esPdf
                                  ? Colors.red.shade700
                                  : Colors.blue.shade600,
                              icon: esPdf ? Icons.picture_as_pdf : Icons.image,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Info Derecha y Botones
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatMoney(gasto.monto),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (tieneEvidencia)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.indigo,
                              side: const BorderSide(color: Colors.indigo),
                            ),
                            onPressed: () =>
                                _verEvidencia(context, gasto.fotos[0]),
                            icon: const Icon(Icons.visibility, size: 16),
                            label: const Text("Ver"),
                          ),
                        if (esEditable) ...[
                          const SizedBox(width: 8),
                          if (tieneEvidencia)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepOrange,
                                side: const BorderSide(
                                  color: Colors.deepOrange,
                                ),
                              ),
                              onPressed: () => _borrarArchivo(gasto.idGasto!),
                              icon: const Icon(
                                Icons.image_not_supported,
                                size: 16,
                              ),
                              label: const Text("Borrar img"),
                            )
                          else
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              onPressed: () =>
                                  _adjuntarEvidencia(gasto.idGasto!, true),
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: const Text("Subir Respaldo"),
                            ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () =>
                                _confirmarBorrarGasto(gasto.idGasto!),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text("Eliminar Gasto"),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (esRechazado && comentario != null && comentario.isNotEmpty) ...[
              const Divider(color: Colors.red, height: 32, thickness: 0.5),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.comment, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Observación: $comentario",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade900,
                          fontStyle: FontStyle.italic,
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
    );
  }

  // ==========================================================
  // 📱 TARJETA GASTO MÓVIL (Mantenida exactamente igual)
  // ==========================================================
  Widget _buildGastoCardMobile(
    dynamic gasto,
    bool tieneEvidencia,
    bool esRechazado,
    bool esPdf,
    String extension,
    String? comentario,
    Color colorEstado,
    Color colorFondo,
    bool esEditable,
  ) {
    return Slidable(
      key: ValueKey(gasto.idGasto),
      enabled: esEditable || tieneEvidencia,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.75,
        children: [
          if (tieneEvidencia)
            SlidableAction(
              onPressed: (_) => _verEvidencia(context, gasto.fotos[0]),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              icon: Icons.visibility,
              label: 'Ver',
            ),
          if (esEditable)
            SlidableAction(
              onPressed: (_) {
                if (tieneEvidencia) {
                  _borrarArchivo(gasto.idGasto!);
                } else {
                  _adjuntarEvidencia(gasto.idGasto!, false);
                }
              },
              backgroundColor: tieneEvidencia ? Colors.deepOrange : Colors.blue,
              foregroundColor: Colors.white,
              icon: tieneEvidencia
                  ? Icons.image_not_supported
                  : Icons.camera_alt,
              label: tieneEvidencia ? 'Borrar img' : 'Subir',
            ),
          if (esEditable)
            SlidableAction(
              onPressed: (_) => _confirmarBorrarGasto(gasto.idGasto!),
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
          side: BorderSide(color: colorEstado.withOpacity(0.5), width: 1.5),
        ),
        color: colorFondo,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    esRechazado ? Icons.highlight_off : Icons.receipt_long,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "${_formatearFecha(gasto.fecha)} • ${gasto.tipoDocumento}",
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadge(
                          text: esRechazado
                              ? "RECHAZADO"
                              : (tieneEvidencia
                                    ? "EVIDENCIA OK"
                                    : "FALTA FOTO"),
                          color: colorEstado,
                        ),
                        if (tieneEvidencia) ...[
                          const SizedBox(width: 6),
                          _buildBadge(
                            text: extension,
                            color: esPdf
                                ? Colors.red.shade700
                                : Colors.blue.shade600,
                            icon: esPdf ? Icons.picture_as_pdf : Icons.image,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Text(
                  _formatMoney(gasto.monto),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (esRechazado &&
                  comentario != null &&
                  comentario.isNotEmpty) ...[
                const Divider(color: Colors.red, height: 20, thickness: 0.5),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.red, size: 16),
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
  }

  // Widget auxiliar para las etiquetas de colores (Badges)
  Widget _buildBadge({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 10),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
