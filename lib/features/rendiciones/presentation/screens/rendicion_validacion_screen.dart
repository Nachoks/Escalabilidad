import 'package:flutter/material.dart';
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

  void _verEvidencia(BuildContext context, dynamic archivo) {
    // 1. Construir la URL completa
    // Asumimos que AppConstants.apiUrl es algo como "http://192.168.1.X/api"
    // Las imágenes en Laravel suelen estar en "http://192.168.1.X/storage/..."
    // Ajustamos la URL base quitando el '/api' final si existe.
    final baseUrl = AppConstants.apiUrl.replaceAll(RegExp(r'/api/?$'), '');

    // 2. Limpieza de Ruta Relativa
    // Si la ruta en BD viene como 'public/gastos/foto.jpg', debemos quitar 'public/'
    // porque en la URL web 'storage' ya apunta a 'public'.
    String rutaLimpia = archivo.rutaRelativa;
    if (rutaLimpia.startsWith('public/')) {
      rutaLimpia = rutaLimpia.replaceFirst('public/', '');
    }

    // 3. Construcción Final
    final urlImagen = "$baseUrl/storage/$rutaLimpia";

    // DEBUG: Imprimir en consola para verificar si la URL es accesible desde el navegador
    print("URL GENERADA: $urlImagen");

    final bool esPdf = archivo.extension == 'pdf';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor:
            Colors.transparent, // Fondo transparente para efecto moderno
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // CONTENIDO
            Container(
              width: double.infinity,
              // Altura dinámica hasta un máximo
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
                  // Cabecera del Dialog
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

                  // Cuerpo: Imagen o Icono PDF
                  Expanded(
                    child: esPdf
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                size: 80,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Documento PDF",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  archivo.nombreOriginal,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Nota: Para abrir PDF real se requiere 'url_launcher'
                              const Text(
                                "(Visualización de PDF disponible en versión Web)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          )
                        : InteractiveViewer(
                            // Permite hacer Zoom con los dedos
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(
                              urlImagen,
                              fit: BoxFit.contain,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (ctx, error, stackTrace) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("No se pudo cargar la imagen"),
                                  // Útil para depurar: Muestra la URL que intentó cargar
                                  Text(
                                    urlImagen,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // BOTÓN CERRAR FLOTANTE (Estilo Instagram/Facebook)
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
        title: const Text("Revisión de Gastos"),
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
                          "${gasto.fecha} • ${gasto.tipoDocumento}",
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
