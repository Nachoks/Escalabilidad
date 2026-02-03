import 'dart:io'; // Fundamental para manejar File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Para Cámara y Galería
import 'package:file_picker/file_picker.dart'; // Para PDF
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
    return Scaffold(
      appBar: AppBar(
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
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              children: [
                const Text(
                  "Código Orden de Compra",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  widget.oc.codOcCliente,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista de HAS
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _guias.isEmpty
                ? const Center(child: Text("No hay Guías HAS cargadas."))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _guias.length,
                    itemBuilder: (context, index) {
                      final has = _guias[index];
                      final tieneArchivo = has.archivos.isNotEmpty;

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            tieneArchivo
                                ? Icons.attachment
                                : Icons.insert_drive_file_outlined,
                            color: tieneArchivo ? Colors.green : Colors.grey,
                          ),
                          title: Text(has.codHasGuia),
                          subtitle: Text(
                            tieneArchivo ? "Archivo adjunto" : "Sin archivo",
                            style: TextStyle(
                              color: tieneArchivo ? Colors.green : Colors.grey,
                              fontWeight: tieneArchivo
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          // --- ZONA DE BOTONES ---
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. Botón de Archivo (Subir o Borrar)
                              if (tieneArchivo)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.orange,
                                  ), // Icono para quitar
                                  tooltip: "Borrar imagen/archivo adjunto",
                                  onPressed: () => _borrarImagen(has),
                                )
                              else
                                IconButton(
                                  icon: const Icon(
                                    Icons.cloud_upload,
                                    color: Colors.blue,
                                  ),
                                  tooltip: "Subir imagen o PDF",
                                  onPressed: () => _subirImagen(has),
                                ),

                              // 2. Botón Eliminar HAS
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: "Eliminar HAS completa",
                                onPressed: () => _eliminarHas(has.idHasGuia),
                              ),
                            ],
                          ),
                          // -----------------------
                          onTap: () {
                            if (tieneArchivo) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Visualización pendiente de implementar",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Esta guía no tiene archivo"),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHasDialog,
        label: const Text("Agregar HAS"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // --- DIÁLOGO DE CREAR HAS ---
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
                    ),
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Podrás subir el archivo (Imagen/PDF) después de crearla.",
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
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text("Error al agregar HAS"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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

  // --- FUNCIÓN 1: SUBIR ARCHIVO (Cámara, Galería, PDF) ---
  void _subirImagen(HasGuiaModel has) {
    final ImagePicker _picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Tomar Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (photo != null) {
                    _procesarSubida(has.idHasGuia, File(photo.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Galería de Imágenes'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    _procesarSubida(has.idHasGuia, File(image.path));
                  }
                },
              ),
              // --- NUEVA OPCIÓN PDF ---
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Subir PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  // Usamos FilePicker para seleccionar PDF
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'], // Restringimos solo a PDF
                      );

                  if (result != null && result.files.single.path != null) {
                    File file = File(result.files.single.path!);
                    _procesarSubida(has.idHasGuia, file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Auxiliar para procesar la subida al Backend
  Future<void> _procesarSubida(int idHas, File archivo) async {
    // Mostrar Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Llamada al servicio que ya creaste
    final success = await ApiService.subirArchivoHas(idHas, archivo);

    if (mounted) Navigator.pop(context); // Cerrar Loading

    if (success) {
      _cargarGuias(); // Recargar lista para ver el cambio de icono
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Archivo guardado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al subir archivo"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- FUNCIÓN 2: BORRAR ARCHIVO ---
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
        _cargarGuias(); // Recargar lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Archivo eliminado"),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al eliminar archivo"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- ELIMINAR HAS COMPLETA ---
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
