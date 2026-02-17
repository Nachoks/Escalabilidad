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

  // --- Helpers de Tiempo (Igual que en la vista del usuario) ---
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

  // --- Modal de Evaluación Mejorado ---
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
                                Navigator.pop(context, true);
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

  String _formatFecha(String fecha) {
    // Convierte 2026-02-16 a 16-02-2026
    final partes = fecha.split('-');
    if (partes.length == 3) {
      return "${partes[2]}-${partes[1]}-${partes[0]}";
    }
    return fecha;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          'Evaluar Hoja de Tiempo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FutureBuilder<HojaTiempoSemana>(
        future: _futureDetalle,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró información.'));
          }

          final hoja = snapshot.data!;
          final dias = hoja.dias ?? [];
          final nombreServicio =
              hoja.nombreServicio ?? "Servicio no especificado";

          // --- CÁLCULO DE HORAS TOTALES ---
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

                if (tipoDia == 'FERIADO') {
                  sumFestivas += totalTramo;
                } else if (tipoDia == 'NO_HABIL') {
                  sumNoHabiles += totalTramo;
                } else {
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

          return Column(
            children: [
              // --- 1. CABECERA INFORMATIVA ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
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
                    if (hoja.observacion != null &&
                        hoja.observacion!.isNotEmpty) ...[
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
              ),

              // --- 2. TABLA DE RESUMEN SEMANAL ---
              Container(
                margin: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _BuildResumenItem("Hábiles", sumHabiles, Colors.blue),
                          _BuildResumenItem(
                            "Extras",
                            sumNoHabiles,
                            Colors.orange,
                          ),
                          _BuildResumenItem("Feriado", sumFestivas, Colors.red),
                          _BuildResumenItem(
                            "Total",
                            sumTotalTrabajo,
                            Colors.green,
                          ),
                          Container(
                            width: 1,
                            height: 35,
                            color: Colors.grey.shade300,
                          ),
                          _BuildResumenItem("Viajes", sumViaje, Colors.purple),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- 3. LISTA DE DÍAS (Expansible) ---
              Expanded(
                child: ListView.builder(
                  itemCount: dias.length,
                  padding: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
                  itemBuilder: (context, index) {
                    final dia = dias[index];
                    final nombreDia = _obtenerNombreDia(dia.fecha);
                    final cantidadActividades = dia.actividades?.length ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: dia.tipoDia == 'HABIL'
                                ? Colors.blue
                                : dia.tipoDia == 'NO_HABIL'
                                ? Colors
                                      .orange // Usamos naranjo/amarillo para mejor contraste con el texto blanco
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "${dia.tipoDia} • ${dia.lugar} \n${cantidadActividades > 0 ? '$cantidadActividades actividades' : 'Sin actividades'} | Viaje: ${dia.viajeHoras}h",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
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
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: dia.actividades!
                                      .map(
                                        (act) => ListTile(
                                          dense: true,
                                          leading: const Icon(
                                            Icons.work_history_outlined,
                                            color: AppColors.primary,
                                          ),
                                          title: Text(
                                            act.descripcion,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${act.horaInicio} a ${act.horaFin}',
                                          ),
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
                  },
                ),
              ),

              // --- 4. BOTONES DE ACCIÓN (Aprobar / Rechazar) ---
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                        onPressed: () => _mostrarModalEvaluacion(context, true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Widget auxiliar para el resumen
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
