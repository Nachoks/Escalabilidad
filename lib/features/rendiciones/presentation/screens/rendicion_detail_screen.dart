import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // <--- IMPORTANTE
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/widget/add_gasto_dialog.dart';

class RendicionDetailScreen extends StatefulWidget {
  final RendicionModel rendicion;

  const RendicionDetailScreen({super.key, required this.rendicion});

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

  // --- 1. LÓGICA PARA SUBIR ARCHIVO ---
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
              title: const Text("Galería de Imágenes"),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: Colors.redAccent,
              ),
              title: const Text("Documento PDF"),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );

    if (opcion == null) return;

    if (opcion == 'camera') {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      pathSeleccionado = photo?.path;
    } else if (opcion == 'gallery') {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      pathSeleccionado = photo?.path;
    } else if (opcion == 'pdf') {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        pathSeleccionado = result.files.single.path;
      }
    }

    if (pathSeleccionado != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subiendo archivo..."),
          duration: Duration(seconds: 1),
        ),
      );

      final exito = await context.read<GastoProvider>().subirEvidencia(
        idGasto,
        widget.rendicion.idRendicion!,
        pathSeleccionado,
      );

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Evidencia subida correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al subir archivo"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- 2. LÓGICA PARA BORRAR ARCHIVO ---
  Future<void> _borrarArchivo(int idGasto) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Evidencia"),
        content: const Text(
          "¿Estás seguro de borrar este archivo? Tendrás que subir uno nuevo.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Eliminando archivo...")));

      final exito = await context.read<GastoProvider>().eliminarEvidencia(
        idGasto,
        widget.rendicion.idRendicion!,
      );

      if (mounted) {
        if (exito) {
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
  }

  // --- 3. LÓGICA PARA BORRAR GASTO COMPLETO ---
  Future<void> _confirmarBorrarGasto(int idGasto) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Gasto"),
        content: const Text(
          "¿Estás seguro de eliminar este gasto completo? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Eliminando gasto...")));

      final exito = await context.read<GastoProvider>().eliminarGastoCompleto(
        idGasto,
      );

      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gasto eliminado"),
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

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GastoProvider>();
    final gastos = provider.gastos;

    // Cálculos en vivo
    int totalEnVivo = gastos.fold(0, (sum, item) => sum + item.monto);
    int montoEntregado = widget.rendicion.montoEntregado;
    int saldo = montoEntregado - totalEnVivo;

    // Determinamos si es editable para habilitar/deshabilitar el slide
    final bool esEditable = [
      'Borrador',
      'Observada',
    ].contains(widget.rendicion.estado);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Detalle Rendición",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton:
          widget.rendicion.estado == 'Borrador' ||
              widget.rendicion.estado == 'Observada'
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
          // --- PANEL DE CONTROL (CABECERA) ---
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
                // Columna 1: Asignado
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ASIGNADO",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
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
                // Columna 2: Gastado
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "TOTAL (con iva)",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
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
                // Columna 3: Saldo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "POR RENDIR",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
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

          // --- LISTA DE GASTOS ---
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

                      // Colores: Verde si OK, Naranja si falta
                      final Color colorEstado = tieneEvidencia
                          ? Colors.green
                          : Colors.orange;
                      final Color colorFondo = tieneEvidencia
                          ? Colors.white
                          : Colors.orange.shade50;

                      // --- AQUI ESTA EL SLIDABLE INTEGRADO ---
                      return Slidable(
                        key: ValueKey(gasto.idGasto),

                        // Solo permite deslizar si se puede editar la rendición
                        enabled: esEditable,

                        // Panel derecho (Deslizar a la izquierda) -> BORRAR
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          dismissible: DismissiblePane(
                            onDismissed: () {
                              _confirmarBorrarGasto(gasto.idGasto!);
                            },
                          ),
                          children: [
                            SlidableAction(
                              onPressed: (_) =>
                                  _confirmarBorrarGasto(gasto.idGasto!),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Borrar',
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),

                        child: Card(
                          margin:
                              EdgeInsets.zero, // El margen lo pone el ListView
                          elevation: tieneEvidencia ? 1 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: colorEstado.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          color: colorFondo,
                          child: ListTile(
                            isThreeLine: true,
                            // Mantenemos el onLongPress como alternativa
                            onLongPress: () {
                              _confirmarBorrarGasto(gasto.idGasto!);
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorEstado.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long,
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
                                Text("${gasto.fecha} • ${gasto.tipoDocumento}"),
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
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        tieneEvidencia
                                            ? "EVIDENCIA OK"
                                            : "FALTA FOTO",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    if (tieneEvidencia &&
                                        gasto.fotos.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              gasto.fotos[0].extension == 'pdf'
                                              ? Colors.red.shade700
                                              : Colors.blue.shade600,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              gasto.fotos[0].extension == 'pdf'
                                                  ? Icons.picture_as_pdf
                                                  : Icons.image,
                                              color: Colors.white,
                                              size: 10,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              gasto.fotos[0].extension
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    if (!tieneEvidencia) {
                                      _adjuntarEvidencia(gasto.idGasto!);
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
                                ),
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
