import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/hoja_dia_edit_screen.dart';
import '../providers/hoja_tiempo_provider.dart';

class HojaDetailScreen extends StatefulWidget {
  final int idHojaSemana;

  const HojaDetailScreen({super.key, required this.idHojaSemana});

  @override
  State<HojaDetailScreen> createState() => _HojaDetailScreenState();
}

class _HojaDetailScreenState extends State<HojaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HojaTiempoProvider>().cargarDetalleHoja(widget.idHojaSemana);
    });
  }

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

  // --- NUEVA FUNCIÓN: POPUP PARA ENVIAR CON OBSERVACIÓN ---
  void _mostrarDialogoEnvio(BuildContext context, int idHoja) {
    final TextEditingController obsController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.send, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    "Enviar a Validación",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Una vez enviada, no podrás editar las horas hasta que sea revisada.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: obsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Observaciones (Opcional)",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Ej: Vehículo averiado el martes...",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setModalState(() => isSubmitting = true);

                          final provider = context.read<HojaTiempoProvider>();
                          final exito = await provider.enviarSemana(
                            idHoja,
                            obsController.text.trim(),
                          );

                          if (!context.mounted) return;
                          setModalState(() => isSubmitting = false);

                          if (exito) {
                            Navigator.pop(context); // Cierra el modal
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Semana enviada a validación"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error al enviar la semana"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Confirmar Envío",
                          style: TextStyle(color: Colors.white),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalle de la Semana",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<HojaTiempoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final hoja = provider.hojaSeleccionada;
          if (hoja == null) {
            return const Center(child: Text("No se encontró información."));
          }

          final dias = hoja.dias ?? [];
          final nombreServicio =
              hoja.nombreServicio ?? "Servicio no especificado";

          // --- LÓGICA DE SUMA SEMANAL ---
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

          // Verificamos si la hoja ya está enviada/aprobada para ocultar el botón
          bool modoLectura = hoja.estado != 'Borrador';

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
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreServicio,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const SizedBox(width: 4),
                                  Text(
                                    "${hoja.centroCosto}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: modoLectura
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: modoLectura
                                  ? Colors.green.shade300
                                  : Colors.orange.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                modoLectura
                                    ? Icons.check_circle
                                    : Icons.edit_document,
                                size: 18,
                                color: modoLectura
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                hoja.estado.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                  color: modoLectura
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                        "Resumen de Horas (Toda la Semana)",
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
                            "Trabajo",
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

              // --- 3. LISTA DE LOS 7 DÍAS ---
              Expanded(
                child: dias.isEmpty
                    ? const Center(
                        child: Text("No hay días generados para esta semana."),
                      )
                    : ListView.builder(
                        itemCount: dias.length,
                        padding: const EdgeInsets.only(
                          bottom: 24,
                          left: 8,
                          right: 8,
                        ),
                        itemBuilder: (context, index) {
                          final dia = dias[index];
                          final nombreDia = _obtenerNombreDia(dia.fecha);
                          final cantidadActividades =
                              dia.actividades?.length ?? 0;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: dia.tipoDia == 'HABIL'
                                    ? AppColors.primary
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text("${dia.tipoDia} • ${dia.lugar}"),
                                  if (cantidadActividades > 0)
                                    Text(
                                      "$cantidadActividades actividad(es) registrada(s)",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  if ((dia.viajeHoras) > 0)
                                    Text(
                                      "${dia.viajeHoras} hrs de viaje",
                                      style: const TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: modoLectura
                                  ? null
                                  : const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                              onTap: modoLectura
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HojaDiaEditScreen(dia: dia),
                                        ),
                                      );
                                    },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      // --- 4. BOTÓN INFERIOR FIJO (Se oculta si ya se envió) ---
      bottomNavigationBar: Consumer<HojaTiempoProvider>(
        builder: (context, provider, child) {
          final hoja = provider.hojaSeleccionada;
          if (hoja == null || hoja.estado != 'Borrador') {
            return const SizedBox.shrink(); // Si no es borrador, ocultamos el botón
          }

          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () =>
                    _mostrarDialogoEnvio(context, hoja.idHojaSemana!),
                child: const Text(
                  "ENVIAR A VALIDAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
