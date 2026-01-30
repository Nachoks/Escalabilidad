import 'package:flutter/material.dart';
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
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarHas(has.idHasGuia),
                          ),
                          onTap: () {
                            // Aquí podrías abrir la imagen
                            if (tieneArchivo) {
                              // Lógica para ver archivo
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Esta guía no tiene archivo adjunto",
                                  ),
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

  void _showAddHasDialog() {
    _codigoHasController.clear();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Evita cerrar al tocar fuera si está guardando
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
                    decoration: const InputDecoration(labelText: "Código HAS"),
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 10),
                  // Aquí iría el botón de subir foto
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

                          setStateBd(() => isSaving = true); // Activar loading

                          // LLAMADA A LA API
                          final success = await ApiService.agregarHas(
                            widget.oc.idOcCliente,
                            _codigoHasController.text,
                          );

                          if (success) {
                            if (dialogContext.mounted)
                              Navigator.pop(dialogContext);
                            _cargarGuias(); // Recargar lista
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text("Guía HAS agregada"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setStateBd(
                              () => isSaving = false,
                            ); // Desactivar loading
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
                      ? SizedBox(
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

  void _eliminarHas(int idHas) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Eliminar"),
            content: const Text("¿Borrar esta HAS?"),
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
