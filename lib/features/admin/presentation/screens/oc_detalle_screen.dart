import 'dart:io';
import 'dart:typed_data'; // <-- IMPORTANTE PARA LOS BYTES EN WEB
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Para saber si estamos en Web
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:somnolence_app/core/api/api_service.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/oc_cliente_model.dart';
import 'package:somnolence_app/features/admin/data/models/has_guia_model.dart';

class OcDetalleScreen extends StatefulWidget {
  final OcClienteModel oc;

  const OcDetalleScreen({super.key, required this.oc});

  @override
  State<OcDetalleScreen> createState() => _OcDetalleScreenState();
}

class _OcDetalleScreenState extends State<OcDetalleScreen> {
  List<HasGuiaModel> _guias = [];
  bool _isLoading = true;
  final TextEditingController _codigoHasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarGuias();
  }

  Future<void> _cargarGuias() async {
    setState(() => _isLoading = true);
    final guias = await ApiService.getHasByOc(widget.oc.idOcCliente);
    if (mounted) {
      setState(() {
        _guias = guias;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop ? const Color(0xFFF4F6F8) : Colors.white,

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
                      const Text(
                        "Detalle Orden de Compra",
                        style: TextStyle(
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
                    "OC: ${widget.oc.codOcCliente}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
            onPressed: _showAddHasDialog,
            label: isDesktop
                ? const Text(
                    "NUEVA GUÍA HAS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text("Agregar HAS"),
            icon: const Icon(Icons.add),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),

          // --- CUERPO ---
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 900 : double.infinity,
              ), // Centrado en PC
              child: Column(
                children: [
                  // --- HEADER RESUMEN ---
                  Container(
                    margin: EdgeInsets.all(isDesktop ? 32 : 0),
                    padding: EdgeInsets.all(isDesktop ? 32 : 24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDesktop ? Colors.white : Colors.grey[100],
                      borderRadius: isDesktop
                          ? BorderRadius.circular(16)
                          : BorderRadius.zero,
                      boxShadow: isDesktop
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                      border: isDesktop
                          ? Border.all(color: Colors.grey.shade200)
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Código Orden de Compra",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isDesktop ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.oc.codOcCliente,
                          style: TextStyle(
                            fontSize: isDesktop ? 32 : 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isDesktop) const Divider(height: 1),

                  // --- LISTA DE GUÍAS HAS ---
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 0,
                      ),
                      decoration: isDesktop
                          ? BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              border: Border.all(color: Colors.grey.shade200),
                            )
                          : null,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _guias.isEmpty
                          ? _buildEmptyState(isDesktop)
                          : ListView.separated(
                              padding: EdgeInsets.all(isDesktop ? 24 : 16),
                              itemCount: _guias.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final has = _guias[index];
                                return isDesktop
                                    ? _buildHasCardDesktop(has)
                                    : _buildHasCardMobile(has);
                              },
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
  // 💻 TARJETA HAS ESCRITORIO (Sin Slidable, botón visible)
  // ==========================================================
  Widget _buildHasCardDesktop(HasGuiaModel has) {
    return _buildHasCardContent(has, isDesktop: true);
  }

  // ==========================================================
  // 📱 TARJETA HAS MÓVIL (Con Slidable original)
  // ==========================================================
  Widget _buildHasCardMobile(HasGuiaModel has) {
    return Slidable(
      key: ValueKey(has.idHasGuia),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _eliminarHas(has.idHasGuia),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Borrar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: _buildHasCardContent(has, isDesktop: false),
    );
  }

  // Contenido base de la tarjeta HAS
  Widget _buildHasCardContent(HasGuiaModel has, {required bool isDesktop}) {
    final tieneArchivo = has.archivos.isNotEmpty;

    return Card(
      elevation: isDesktop ? 0 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tieneArchivo ? Colors.green.shade200 : Colors.grey.shade300,
          width: tieneArchivo ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: tieneArchivo
              ? Colors.green.shade50
              : Colors.grey.shade100,
          child: Icon(
            tieneArchivo ? Icons.attachment : Icons.insert_drive_file_outlined,
            color: tieneArchivo ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          has.codHasGuia,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          tieneArchivo ? "Archivo adjunto" : "Sin archivo",
          style: TextStyle(
            color: tieneArchivo ? Colors.green.shade700 : Colors.grey.shade600,
            fontWeight: tieneArchivo ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tieneArchivo)
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.orange),
                tooltip: "Borrar archivo",
                onPressed: () => _borrarImagen(has),
              )
            else
              IconButton(
                icon: const Icon(Icons.cloud_upload, color: Colors.blue),
                tooltip: "Subir archivo",
                onPressed: () => _subirImagen(has, isDesktop),
              ),

            // Si es escritorio, el botón de eliminar HAS debe estar visible aquí (porque no hay Slidable)
            if (isDesktop) ...[
              Container(
                height: 24,
                width: 1,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: "Eliminar HAS",
                onPressed: () => _eliminarHas(has.idHasGuia),
              ),
            ],
          ],
        ),
        onTap: () {
          if (tieneArchivo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Visualización pendiente de implementar"),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Esta guía no tiene archivo")),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay Guías HAS",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text("Crea una nueva con el botón flotante"),
        ],
      ),
    );
  }

  // --- DIÁLOGOS DE AGREGAR Y ELIMINAR ---
  void _showAddHasDialog() {
    _codigoHasController.clear();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateBd) {
            return AlertDialog(
              title: const Text("Nueva Guía HAS"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _codigoHasController,
                    decoration: const InputDecoration(
                      labelText: "Código HAS",
                      prefixIcon: Icon(Icons.qr_code),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Podrás subir el archivo después de crearla.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
                          if (_codigoHasController.text.isEmpty) return;
                          setStateBd(() => isSaving = true);
                          final success = await ApiService.agregarHas(
                            widget.oc.idOcCliente,
                            _codigoHasController.text,
                          );
                          if (success) {
                            if (dialogContext.mounted)
                              Navigator.pop(dialogContext);
                            _cargarGuias();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text("Guía HAS agregada"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setStateBd(() => isSaving = false);
                            if (mounted)
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text("Error al agregar HAS"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // --- LÓGICA DE SUBIDA CORREGIDA PARA WEB Y MÓVIL ---
  // ==========================================================
  void _subirImagen(HasGuiaModel has, bool isDesktop) {
    final ImagePicker picker = ImagePicker();

    Widget menuOpciones = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (!kIsWeb) // La cámara nativa solo funciona en móviles
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Tomar Foto'),
            onTap: () async {
              Navigator.pop(context);
              final XFile? photo = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 80,
              );
              if (photo != null) {
                // Móvil: usamos el Path normal
                _procesarSubidaMovil(has.idHasGuia, File(photo.path));
              }
            },
          ),
        ListTile(
          leading: const Icon(Icons.photo_library, color: Colors.green),
          title: const Text('Seleccionar Imagen'),
          onTap: () async {
            Navigator.pop(context);
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
            if (image != null) {
              if (kIsWeb) {
                // WEB: Extraemos los BYTES
                final bytes = await image.readAsBytes();
                _procesarSubidaWeb(has.idHasGuia, bytes, image.name);
              } else {
                // MÓVIL: Usamos el Path normal
                _procesarSubidaMovil(has.idHasGuia, File(image.path));
              }
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: const Text('Subir PDF'),
          onTap: () async {
            Navigator.pop(context);
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
              withData: kIsWeb, // ESTO ES CLAVE PARA LA WEB
            );

            if (result != null) {
              if (kIsWeb) {
                // WEB: Extraemos los bytes del PDF
                final bytes = result.files.single.bytes;
                final fileName = result.files.single.name;
                if (bytes != null) {
                  _procesarSubidaWeb(has.idHasGuia, bytes, fileName);
                }
              } else {
                // MÓVIL: Extraemos el Path del PDF
                if (result.files.single.path != null) {
                  _procesarSubidaMovil(
                    has.idHasGuia,
                    File(result.files.single.path!),
                  );
                }
              }
            }
          },
        ),
      ],
    );

    // En PC abrimos un Dialog, en Celular un BottomSheet
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Subir Documento"),
          content: SizedBox(width: 300, child: menuOpciones),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) =>
            SafeArea(child: Wrap(children: [menuOpciones])),
      );
    }
  }

  // Procesar subida en MÓVIL (Con File y Path)
  Future<void> _procesarSubidaMovil(int idHas, File archivo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final success = await ApiService.subirArchivoHas(idHas, archivo);
    if (mounted) Navigator.pop(context);
    _manejarResultadoSubida(success);
  }

  // Procesar subida en WEB (Con Uint8List / Bytes)
  Future<void> _procesarSubidaWeb(
    int idHas,
    Uint8List bytes,
    String fileName,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    // IMPORTANTE: Asegúrate de haber agregado esta función en tu ApiService
    final success = await ApiService.subirArchivoHasWeb(idHas, bytes, fileName);
    if (mounted) Navigator.pop(context);
    _manejarResultadoSubida(success);
  }

  // Manejar el Snackbar tras la subida
  void _manejarResultadoSubida(bool success) {
    if (success) {
      _cargarGuias();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Archivo guardado"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al subir"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- LÓGICA DE BORRADO ---
  void _borrarImagen(HasGuiaModel has) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Eliminar Archivo"),
            content: const Text("¿Estás seguro de borrar el archivo adjunto?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Borrar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final success = await ApiService.deleteArchivoHas(has.idHasGuia);
      if (mounted) Navigator.pop(context);
      if (success) {
        _cargarGuias();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Archivo eliminado"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al eliminar"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _eliminarHas(int idHas) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Eliminar"),
            content: const Text("¿Borrar esta HAS y sus archivos?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Sí", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      final success = await ApiService.deleteHas(idHas);
      if (success) {
        _cargarGuias();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("HAS eliminada"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al eliminar"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
