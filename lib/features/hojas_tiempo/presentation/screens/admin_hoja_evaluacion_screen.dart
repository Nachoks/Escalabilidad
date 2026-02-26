import 'package:flutter/material.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import '../../data/models/hoja_tiempo_model.dart';
import '../../data/services/hoja_tiempo_service.dart';

class AdminHojaEvaluacionScreen extends StatefulWidget {
  final int idHojaSemana;

  const AdminHojaEvaluacionScreen({Key? key, required this.idHojaSemana})
    : super(key: key);

  @override
  State<AdminHojaEvaluacionScreen> createState() =>
      _AdminHojaEvaluacionScreenState();
}

class _AdminHojaEvaluacionScreenState extends State<AdminHojaEvaluacionScreen> {
  final HojaTiempoService _hojaService = HojaTiempoService();
  late Future<HojaTiempoSemana> _futureDetalle;

  @override
  void initState() {
    super.initState();
    _futureDetalle = _hojaService.obtenerDetalleHoja(widget.idHojaSemana);
  }

  // --- Helpers de Tiempo ---
  String _obtenerNombreDia(DateTime fecha) {
    const nombres = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];
    return nombres[fecha.weekday - 1];
  }

  String _formatFecha(String fecha) {
    final partes = fecha.split('-');
    if (partes.length == 3) return "${partes[2]}-${partes[1]}-${partes[0]}";
    return fecha;
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  double _calcularHorasBrutas(TimeOfDay inicio, TimeOfDay fin) {
    int minInicio = inicio.hour * 60 + inicio.minute;
    int minFin = fin.hour * 60 + fin.minute;
    int diff = minFin - minInicio;
    if (diff < 0) diff += 1440;
    return diff / 60.0;
  }

  // --- Modal de Evaluación ---
  void _mostrarModalEvaluacion(BuildContext context, bool esAprobacion) {
    final TextEditingController obsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    esAprobacion ? Icons.check_circle : Icons.cancel,
                    color: esAprobacion ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    esAprobacion ? 'Aprobar Hoja' : 'Rechazar Hoja',
                    style: TextStyle(
                      color: esAprobacion ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      esAprobacion
                          ? '¿Estás seguro de que deseas aprobar esta hoja de tiempo? Las horas se contabilizarán formalmente.'
                          : 'Por favor, ingresa el motivo del rechazo para que el trabajador pueda corregirlo.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: obsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: esAprobacion
                            ? 'Observación (Opcional)'
                            : 'Motivo del Rechazo',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (!esAprobacion &&
                            (value == null || value.trim().isEmpty)) {
                          return 'La observación es obligatoria para rechazar.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: esAprobacion ? Colors.green : Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setStateModal(() => isLoading = true);
                            try {
                              final estado = esAprobacion
                                  ? 'Aprobada'
                                  : 'Rechazada';
                              await _hojaService.evaluarHoja(
                                widget.idHojaSemana,
                                estado,
                                obsController.text.trim(),
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pop(
                                  context,
                                  true,
                                ); // Regresamos y avisamos recarga
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hoja $estado exitosamente'),
                                    backgroundColor: esAprobacion
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              setStateModal(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          esAprobacion
                              ? 'CONFIRMAR APROBACIÓN'
                              : 'CONFIRMAR RECHAZO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : const Color(0xFFF4F6F8),

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
                        'Evaluar Hoja de Tiempo',
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
                    'Evaluar Hoja de Tiempo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  iconTheme: const IconThemeData(color: Colors.white),
                  elevation: 0,
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

          // --- CUERPO ---
          body: FutureBuilder<HojaTiempoSemana>(
            future: _futureDetalle,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData)
                return const Center(child: Text('No se encontró información.'));

              final hoja = snapshot.data!;
              final dias = hoja.dias ?? [];
              final nombreServicio =
                  hoja.nombreServicio ?? "Servicio no especificado";

              // Cálculos
              double sumHabiles = 0,
                  sumNoHabiles = 0,
                  sumFestivas = 0,
                  sumViaje = 0;
              for (var dia in dias) {
                sumViaje += (dia.viajeHoras).toDouble();
                if (dia.actividades != null && dia.actividades!.isNotEmpty) {
                  String tipoDia = dia.tipoDia.toUpperCase();
                  TimeOfDay horInicio = dia.horarioInicio != null
                      ? _parseTime(dia.horarioInicio!)
                      : const TimeOfDay(hour: 8, minute: 0);
                  TimeOfDay horFin = dia.horarioFin != null
                      ? _parseTime(dia.horarioFin!)
                      : const TimeOfDay(hour: 18, minute: 0);

                  for (var act in dia.actividades!) {
                    TimeOfDay tInicio = _parseTime(act.horaInicio);
                    TimeOfDay tFin = _parseTime(act.horaFin);
                    double totalTramo = _calcularHorasBrutas(tInicio, tFin);

                    if (tipoDia == 'FERIADO')
                      sumFestivas += totalTramo;
                    else if (tipoDia == 'NO_HABIL')
                      sumNoHabiles += totalTramo;
                    else {
                      int tramoI = tInicio.hour * 60 + tInicio.minute;
                      int tramoF = tFin.hour * 60 + tFin.minute;
                      if (tramoF < tramoI) tramoF += 1440;
                      int hI = horInicio.hour * 60 + horInicio.minute;
                      int hF = horFin.hour * 60 + horFin.minute;
                      if (hF < hI) hF += 1440;

                      int overlapI = tramoI > hI ? tramoI : hI;
                      int overlapF = tramoF < hF ? tramoF : hF;
                      int overlapMins = overlapF - overlapI;
                      if (overlapMins < 0) overlapMins = 0;

                      double habiles = overlapMins / 60.0;
                      double noHabiles = totalTramo - habiles;
                      if (noHabiles < 0.01) noHabiles = 0;

                      sumHabiles += habiles;
                      sumNoHabiles += noHabiles;
                    }
                  }
                }
              }
              double sumTotalTrabajo = sumHabiles + sumNoHabiles + sumFestivas;

              if (isDesktop) {
                // =====================================
                // 💻 DISEÑO ESCRITORIO (2 COLUMNAS)
                // =====================================
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // PANEL IZQUIERDO
                                Expanded(
                                  flex: 4,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        _buildInfoPanelDesktop(
                                          hoja,
                                          nombreServicio,
                                        ),
                                        const SizedBox(height: 24),
                                        _buildDesktopCalendar(
                                          hoja.fechaInicio,
                                          hoja.fechaFin,
                                        ),
                                        const SizedBox(height: 24),
                                        _buildResumenPanel(
                                          sumHabiles,
                                          sumNoHabiles,
                                          sumFestivas,
                                          sumTotalTrabajo,
                                          sumViaje,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                // PANEL DERECHO
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
                                            children: [
                                              const Icon(
                                                Icons.date_range,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                "Días Registrados (Semana ${hoja.numeroSemana})",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        Expanded(
                                          child: dias.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    "No hay días generados para esta semana.",
                                                  ),
                                                )
                                              : ListView.separated(
                                                  padding: const EdgeInsets.all(
                                                    24,
                                                  ),
                                                  itemCount: dias.length,
                                                  separatorBuilder: (_, __) =>
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                  itemBuilder:
                                                      (context, index) =>
                                                          _buildDiaCard(
                                                            dias[index],
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
                          ),
                          // BOTONES INFERIORES WEB (CENTRADOS)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // <--- AQUÍ SE CENTRAN LOS BOTONES
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.cancel_outlined),
                                    label: const Text(
                                      'RECHAZAR',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _mostrarModalEvaluacion(context, false),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                    ),
                                    label: const Text(
                                      'APROBAR',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _mostrarModalEvaluacion(context, true),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // =====================================
              // 📱 DISEÑO MÓVIL (Mantenido Igual)
              // =====================================
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildInfoPanelMobile(hoja, nombreServicio),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildResumenPanel(
                              sumHabiles,
                              sumNoHabiles,
                              sumFestivas,
                              sumTotalTrabajo,
                              sumViaje,
                            ),
                          ),
                          if (dias.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text("No hay días generados."),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dias.length,
                              padding: const EdgeInsets.only(
                                bottom: 24,
                                left: 8,
                                right: 8,
                              ),
                              itemBuilder: (context, index) =>
                                  _buildDiaCard(dias[index], isDesktop: false),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text(
                                'RECHAZAR',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () =>
                                  _mostrarModalEvaluacion(context, false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text(
                                'APROBAR',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () =>
                                  _mostrarModalEvaluacion(context, true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildInfoPanelDesktop(HojaTiempoSemana hoja, String nombreServicio) {
    Color colorEstado;
    IconData iconEstado;
    if (hoja.estado == 'Aprobada') {
      colorEstado = Colors.green;
      iconEstado = Icons.check_circle;
    } else if (hoja.estado == 'Rechazada') {
      colorEstado = Colors.red;
      iconEstado = Icons.cancel;
    } else if (hoja.estado == 'Enviada') {
      colorEstado = Colors.blue;
      iconEstado = Icons.access_time_filled;
    } else {
      colorEstado = Colors.orange;
      iconEstado = Icons.edit_document;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
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
          Text(
            hoja.nombreComprobante ?? "Sin Nombre",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nombreServicio,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Semana: ${hoja.numeroSemana} (${_formatFecha(hoja.fechaInicio)} al ${_formatFecha(hoja.fechaFin)})",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorEstado.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconEstado, size: 18, color: colorEstado),
                const SizedBox(width: 6),
                Text(
                  hoja.estado.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorEstado,
                  ),
                ),
              ],
            ),
          ),
          if (hoja.observacion != null && hoja.observacion!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: Colors.blue.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Nota del trabajador: ${hoja.observacion}",
                      style: TextStyle(
                        color: Colors.blue.shade900,
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
    );
  }

  Widget _buildInfoPanelMobile(HojaTiempoSemana hoja, String nombreServicio) {
    Color colorEstado;
    IconData iconEstado;
    if (hoja.estado == 'Aprobada') {
      colorEstado = Colors.green;
      iconEstado = Icons.check_circle;
    } else if (hoja.estado == 'Rechazada') {
      colorEstado = Colors.red;
      iconEstado = Icons.cancel;
    } else if (hoja.estado == 'Enviada') {
      colorEstado = Colors.blue;
      iconEstado = Icons.access_time_filled;
    } else {
      colorEstado = Colors.orange;
      iconEstado = Icons.edit_document;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hoja.nombreComprobante ?? "Sin Nombre",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nombreServicio,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Semana: ${hoja.numeroSemana} (${_formatFecha(hoja.fechaInicio)} al ${_formatFecha(hoja.fechaFin)})",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorEstado.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconEstado, size: 18, color: colorEstado),
                const SizedBox(width: 6),
                Text(
                  hoja.estado.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                    color: colorEstado,
                  ),
                ),
              ],
            ),
          ),
          if (hoja.observacion != null && hoja.observacion!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: Colors.blue.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Nota del trabajador: ${hoja.observacion}",
                      style: TextStyle(
                        color: Colors.blue.shade900,
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
    );
  }

  Widget _buildResumenPanel(
    double habiles,
    double noHabiles,
    double festivas,
    double total,
    double viaje,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: const Text(
              "Resumen de Horas Reportadas",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BuildResumenItem("Hábiles", habiles, Colors.blue),
                _BuildResumenItem("Extras", noHabiles, Colors.orange),
                _BuildResumenItem("Feriado", festivas, Colors.red),
                _BuildResumenItem("Total", total, Colors.green),
                Container(width: 1, height: 35, color: Colors.grey.shade300),
                _BuildResumenItem("Viajes", viaje, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaCard(dynamic dia, {required bool isDesktop}) {
    final nombreDia = _obtenerNombreDia(dia.fecha);
    final cantidadActividades = dia.actividades?.length ?? 0;

    return Card(
      margin: isDesktop
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: isDesktop ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade300)
            : BorderSide.none,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: dia.tipoDia == 'HABIL'
                ? Colors.blue
                : dia.tipoDia == 'NO_HABIL'
                ? Colors.orange
                : dia.tipoDia == 'FERIADO'
                ? Colors.red
                : Colors.grey,
            child: Text(
              dia.fecha.day.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            nombreDia,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "${dia.tipoDia} • ${dia.lugar} \n${cantidadActividades > 0 ? '$cantidadActividades actividades' : 'Sin actividades'} | Viaje: ${dia.viajeHoras}h",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          children: [
            if (cantidadActividades == 0)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No hay actividades registradas este día.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  children: dia.actividades!
                      .map<Widget>(
                        (act) => ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.work_history_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            act.descripcion,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('${act.horaInicio} a ${act.horaFin}'),
                          trailing: Text(
                            '${act.horasHabiles + act.horasNoHabiles + act.horasFestivas} hrs',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DEL CALENDARIO VISUAL PARA WEB ---
  Widget _buildDesktopCalendar(String fechaInicioStr, String fechaFinStr) {
    try {
      DateTime parseDateSafe(String d) {
        if (d.contains('-') && d.split('-')[0].length == 2) {
          final p = d.split('-');
          return DateTime.parse("${p[2]}-${p[1]}-${p[0]}");
        }
        return DateTime.parse(d);
      }

      final DateTime inicioBruto = parseDateSafe(fechaInicioStr);
      final DateTime finBruto = parseDateSafe(fechaFinStr);
      final DateTime inicio = DateTime(
        inicioBruto.year,
        inicioBruto.month,
        inicioBruto.day,
      );
      final DateTime fin = DateTime(
        finBruto.year,
        finBruto.month,
        finBruto.day,
      );
      const meses = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
      final mesNombre = "${meses[inicio.month - 1]} ${inicio.year}";

      final primerDiaMes = DateTime(inicio.year, inicio.month, 1);
      final ultimoDiaMes = DateTime(inicio.year, inicio.month + 1, 0);
      int offsetDias = primerDiaMes.weekday - 1;

      List<Widget> diasWidgets = [];
      const diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
      for (var d in diasSemana) {
        diasWidgets.add(
          Center(
            child: Text(
              d,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        );
      }
      for (int i = 0; i < offsetDias; i++) {
        diasWidgets.add(const SizedBox.shrink());
      }
      for (int day = 1; day <= ultimoDiaMes.day; day++) {
        DateTime currentDate = DateTime(inicio.year, inicio.month, day);
        bool isSelected =
            currentDate.isAtSameMomentAs(inicio) ||
            currentDate.isAtSameMomentAs(fin) ||
            (currentDate.isAfter(inicio) && currentDate.isBefore(fin));
        bool isStart = currentDate.isAtSameMomentAs(inicio);
        bool isEnd = currentDate.isAtSameMomentAs(fin);

        diasWidgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: isStart && isEnd
                  ? BorderRadius.circular(8)
                  : isStart
                  ? const BorderRadius.horizontal(left: Radius.circular(8))
                  : isEnd
                  ? const BorderRadius.horizontal(right: Radius.circular(8))
                  : BorderRadius.zero,
            ),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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
            Text(
              mesNombre.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              childAspectRatio: 1.2,
              physics: const NeverScrollableScrollPhysics(),
              children: diasWidgets,
            ),
          ],
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          "Error al cargar calendario: $e",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }
}

class _BuildResumenItem extends StatelessWidget {
  final String titulo;
  final double valor;
  final Color color;

  const _BuildResumenItem(this.titulo, this.valor, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
