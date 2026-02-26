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
  final Map<int, String> _decisiones = {};
  final Map<int, String> _comentarios = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GastoProvider>().cargarGastos(widget.rendicion.idRendicion!);
    });
  }

  void _setDecision(int idGasto, String decision) {
    setState(() {
      _decisiones[idGasto] = decision;
      if (decision == 'Aprobado') {
        _comentarios.remove(idGasto);
      }
    });
  }

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

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  void _verEvidencia(BuildContext context, dynamic archivo) {
    String rutaLimpia = archivo.rutaRelativa.replaceAll('\\', '/');
    if (rutaLimpia.startsWith('public/'))
      rutaLimpia = rutaLimpia.replaceFirst('public/', '');
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
              ),
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

  Future<void> _finalizarRevision() async {
    final gastos = context.read<GastoProvider>().gastos;

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

    if (mounted) {
      final exito = await context
          .read<RendicionesProvider>()
          .enviarValidacionAdmin(widget.rendicion.idRendicion!, payload);

      if (mounted && exito) {
        Navigator.pop(context);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : Colors.grey.shade50,

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
                        "Revisión de Rendición",
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
                  title: const Text(
                    "Revisión de Gastos",
                    style: TextStyle(fontWeight: FontWeight.bold),
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

          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity,
                    ), // Ancho grande para 2 columnas
                    child: isDesktop
                        // ==========================================
                        // 💻 VISTA ESCRITORIO (2 COLUMNAS)
                        // ==========================================
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // --- PANEL IZQUIERDO: RESUMEN FIJO ---
                                Expanded(
                                  flex: 4,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: _buildResumenRendicionPanel(),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // --- PANEL DERECHO: LISTA DE GASTOS SCROLLEABLE ---
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.fact_check_outlined,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    "Gastos a Revisar (${gastos.length})",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Contador de avance
                                              Text(
                                                "${_decisiones.length} / ${gastos.length} evaluados",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      _decisiones.length ==
                                                          gastos.length
                                                      ? Colors.green
                                                      : Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        Expanded(
                                          child: gastos.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    "No hay gastos registrados en esta rendición.",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                              : ListView.separated(
                                                  padding: const EdgeInsets.all(
                                                    24,
                                                  ),
                                                  itemCount: gastos.length,
                                                  separatorBuilder: (_, __) =>
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                  itemBuilder:
                                                      (context, index) =>
                                                          _buildGastoCard(
                                                            gastos[index],
                                                            isDesktop: true,
                                                          ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        // ==========================================
                        // 📱 VISTA MÓVIL (1 COLUMNA)
                        // ==========================================
                        : Column(
                            children: [
                              _buildResumenRendicionPanel(isMobile: true),
                              Expanded(
                                child: gastos.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "No hay gastos registrados en esta rendición.",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: gastos.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 20),
                                        itemBuilder: (context, index) =>
                                            _buildGastoCard(
                                              gastos[index],
                                              isDesktop: false,
                                            ),
                                      ),
                              ),
                            ],
                          ),
                  ),
                ),

          // --- BOTÓN INFERIOR FIJO ---
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 600 : double.infinity,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _finalizarRevision,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "FINALIZAR REVISIÓN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
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

  // --- WIDGETS AUXILIARES ---

  // Panel Informativo Lateral (Izquierda en PC, Arriba en Móvil)
  Widget _buildResumenRendicionPanel({bool isMobile = false}) {
    final rendicion = widget.rendicion;
    final int asignado = rendicion.montoEntregado;
    final int gastado = rendicion.totalGastado;
    final int saldo = asignado - gastado;
    final bool esReembolso = saldo < 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
        border: isMobile
            ? Border(bottom: BorderSide(color: Colors.grey.shade300))
            : Border.all(color: Colors.grey.shade200),
        boxShadow: isMobile
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: const Icon(Icons.person, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Solicitante",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      rendicion.nombreUsuario,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            rendicion.proposito,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Fecha: ${_formatearFecha(rendicion.fecha)}",
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),

          // Bloque financiero
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ASIGNADO",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatMoney(asignado),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL GASTADO",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatMoney(gastado),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      esReembolso ? "REEMBOLSO" : "DEVOLUCIÓN",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      _formatMoney(saldo.abs()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: esReembolso
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta individual de gasto (Derecha en PC, Abajo en móvil)
  Widget _buildGastoCard(dynamic gasto, {required bool isDesktop}) {
    final decision = _decisiones[gasto.idGasto];

    return Card(
      elevation: isDesktop ? 0 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: decision == 'Aprobado'
              ? Colors.green
              : decision == 'Rechazado'
              ? Colors.red
              : (isDesktop ? Colors.grey.shade300 : Colors.transparent),
          width: decision != null ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    gasto.detalle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  _formatMoney(gasto.monto),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "${_formatearFecha(gasto.fecha)} • ${gasto.tipoDocumento}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const Divider(height: 24),

            if (gasto.fotos.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _verEvidencia(context, gasto.fotos[0]),
                  icon: Icon(
                    gasto.fotos[0].extension == 'pdf'
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    "Ver Evidencia (${gasto.fotos[0].extension.toUpperCase()})",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BotonDecision(
                    label: "Rechazar",
                    icon: Icons.thumb_down,
                    color: Colors.red,
                    isSelected: decision == 'Rechazado',
                    onTap: () => _setDecision(gasto.idGasto!, 'Rechazado'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BotonDecision(
                    label: "Aprobar",
                    icon: Icons.thumb_up,
                    color: Colors.green,
                    isSelected: decision == 'Aprobado',
                    onTap: () => _setDecision(gasto.idGasto!, 'Aprobado'),
                  ),
                ),
              ],
            ),
            if (decision == 'Rechazado') ...[
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Motivo del rechazo (Obligatorio)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fillColor: Colors.red.shade50,
                  filled: true,
                  prefixIcon: const Icon(Icons.comment, color: Colors.red),
                ),
                onChanged: (val) => _setComentario(gasto.idGasto!, val),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: color, width: 1.5),
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
