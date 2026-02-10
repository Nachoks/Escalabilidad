import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/constants/app_constants.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';

class RendicionValidacionScreen extends StatefulWidget {
  final RendicionModel rendicion;

  const RendicionValidacionScreen({super.key, required this.rendicion});

  @override
  State<RendicionValidacionScreen> createState() =>
      _RendicionValidacionScreenState();
}

class _RendicionValidacionScreenState extends State<RendicionValidacionScreen> {
  // Estado local para manejar las decisiones antes de enviar
  // Map<IdGasto, Estado>
  final Map<int, String> _decisiones = {};
  // Map<IdGasto, Comentario>
  final Map<int, String> _comentarios = {};

  @override
  void initState() {
    super.initState();
    // Cargamos los gastos al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GastoProvider>().cargarGastos(widget.rendicion.idRendicion!);
    });
  }

  // Helper para establecer decisión
  void _setDecision(int idGasto, String decision) {
    setState(() {
      _decisiones[idGasto] = decision;
      // Si aprueba, limpiamos comentario por si había escrito algo antes
      if (decision == 'Aprobado') {
        _comentarios.remove(idGasto);
      }
    });
  }

  // Guardar comentario
  void _setComentario(int idGasto, String texto) {
    _comentarios[idGasto] = texto;
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
    final urlImagen = Uri.encodeFull(urlString);

    print("Abriendo evidencia: $urlImagen");

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
                maxHeight:
                    MediaQuery.of(context).size.height *
                    0.8, // Aumenté un poco la altura
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
                      esPdf ? "Documento PDF" : "Evidencia Adjunta",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    // --- CAMBIO PRINCIPAL AQUÍ ---
                    child: esPdf
                        ? const PDF(
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
                          )
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
                              errorBuilder: (context, error, stackTrace) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    Text("Error al cargar imagen"),
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

  // --- ENVIAR AL BACKEND ---
  Future<void> _finalizarRevision() async {
    final gastos = context.read<GastoProvider>().gastos;

    // 1. Validar que TODO esté revisado
    if (_decisiones.length < gastos.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "⚠️ Debes Aprobar o Rechazar todos los gastos antes de finalizar.",
          ),
        ),
      );
      return;
    }

    // 2. Validar que los rechazados tengan comentario
    for (var gasto in gastos) {
      if (_decisiones[gasto.idGasto] == 'Rechazado') {
        final comentario = _comentarios[gasto.idGasto];
        if (comentario == null || comentario.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "⚠️ Falta comentario en el gasto: ${gasto.detalle}",
              ),
            ),
          );
          return;
        }
      }
    }

    // 3. Preparar Data
    List<Map<String, dynamic>> payload = [];
    bool hayRechazos = false;

    for (var gasto in gastos) {
      final estado = _decisiones[gasto.idGasto]!;
      if (estado == 'Rechazado') hayRechazos = true;

      payload.add({
        'id_gasto': gasto.idGasto,
        'estado': estado,
        'comentario': _comentarios[gasto.idGasto] ?? '',
      });
    }

    // 4. Confirmación Visual
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Validación"),
        content: Text(
          hayRechazos
              ? "Esta rendición quedará OBSERVADA y volverá al usuario para correcciones."
              : "Esta rendición quedará APROBADA y pasará a Tesorería para pago.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: hayRechazos ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 5. Enviar
    if (mounted) {
      final exito = await context
          .read<RendicionesProvider>()
          .enviarValidacionAdmin(widget.rendicion.idRendicion!, payload);

      if (mounted && exito) {
        Navigator.pop(context); // Volver al Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hayRechazos ? "Rendición Observada" : "Rendición Aprobada",
            ),
            backgroundColor: hayRechazos ? Colors.orange : Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GastoProvider>();
    final gastos = provider.gastos;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Revisión de Gastos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _finalizarRevision,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "FINALIZAR REVISIÓN",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: gastos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final gasto = gastos[index];
                final decision =
                    _decisiones[gasto
                        .idGasto]; // 'Aprobado', 'Rechazado' o null

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: decision == 'Aprobado'
                          ? Colors.green
                          : decision == 'Rechazado'
                          ? Colors.red
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Datos del Gasto
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                gasto.detalle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              "\$${gasto.monto}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${_formatearFecha(gasto.fecha)} • ${gasto.tipoDocumento}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),

                        const Divider(height: 20),

                        // 2. Ver Evidencia (Botón)
                        if (gasto.fotos.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                // Llamamos a la función pasando el primer archivo
                                _verEvidencia(context, gasto.fotos[0]);
                              },
                              icon: Icon(
                                gasto.fotos[0].extension == 'pdf'
                                    ? Icons.picture_as_pdf
                                    : Icons.image,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                "Ver Evidencia (${gasto.fotos[0].extension.toUpperCase()})",
                                style: TextStyle(color: AppColors.primary),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          )
                        else
                          const Text(
                            "⚠️ Sin evidencia adjunta",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),

                        const SizedBox(height: 10),

                        // 3. Botones de Decisión
                        Row(
                          children: [
                            Expanded(
                              child: _BotonDecision(
                                label: "Rechazar",
                                icon: Icons.thumb_down,
                                color: Colors.red,
                                isSelected: decision == 'Rechazado',
                                onTap: () =>
                                    _setDecision(gasto.idGasto!, 'Rechazado'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _BotonDecision(
                                label: "Aprobar",
                                icon: Icons.thumb_up,
                                color: Colors.green,
                                isSelected: decision == 'Aprobado',
                                onTap: () =>
                                    _setDecision(gasto.idGasto!, 'Aprobado'),
                              ),
                            ),
                          ],
                        ),

                        // 4. Campo de Comentario (Solo si es Rechazado)
                        if (decision == 'Rechazado') ...[
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Motivo del rechazo (Obligatorio)",
                              border: const OutlineInputBorder(),
                              fillColor: Colors.red.shade50,
                              filled: true,
                              prefixIcon: const Icon(
                                Icons.comment,
                                color: Colors.red,
                              ),
                            ),
                            onChanged: (val) =>
                                _setComentario(gasto.idGasto!, val),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Widget auxiliar para botones bonitos
class _BotonDecision extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _BotonDecision({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
