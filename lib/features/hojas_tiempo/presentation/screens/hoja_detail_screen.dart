import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:somnolence_app/features/hojas_tiempo/presentation/screens/hoja_dia_edit_screen.dart';
import '../providers/hoja_tiempo_provider.dart';
import '../utils/hoja_tiempo_semanal_pdf_builder.dart';

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

  Future<void> _generarPdfSemanal() async {
    final provider = context.read<HojaTiempoProvider>();
    final semana = provider.hojaSeleccionada;
    final user = context.read<AuthProvider>().currentUser;
    final nombreUsuario = user?.nombreCompleto ?? 'Usuario';

    if (semana == null) return;

    try {
      final pdfBytes = await HojaTiempoSemanalPdfBuilder.buildPdfSemanal(
        semana: semana,
        nombreUsuario: nombreUsuario,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Reporte_Semanal_S${semana.numeroSemana}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al generar PDF Semanal: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  // --- DIÁLOGO PARA ENVIAR LA SEMANA COMPLETA ---
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
                    "Enviar Semana",
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
                    "Se enviarán a validación todos los días que sigan en estado borrador. Una vez enviados, no podrás editarlos.",
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
                      hintText: "Ej: Corregí las horas del martes...",
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
                            Navigator.pop(context);
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

  // --- DIÁLOGO NUEVO: ENVIAR UN SOLO DÍA ---
  void _mostrarDialogoEnvioDia(
    BuildContext context,
    int idHojaDiaria,
    int idHojaSemana,
    String nombreDia,
  ) {
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
              title: Row(
                children: [
                  const Icon(Icons.send, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "Enviar $nombreDia",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Text(
                "¿Estás seguro de enviar tu registro del día $nombreDia a validación?\n\nUna vez enviado, no podrás modificar las horas de este día hasta que sea revisado por un administrador.",
                style: const TextStyle(fontSize: 14),
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
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setModalState(() => isSubmitting = true);
                          final provider = context.read<HojaTiempoProvider>();
                          final exito = await provider.enviarDia(
                            idHojaDiaria,
                            idHojaSemana,
                          );

                          if (!context.mounted) return;
                          setModalState(() => isSubmitting = false);

                          if (exito) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "$nombreDia enviado a validación",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error al enviar el día"),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        // 👇 Lógica para saber si mostrar el botón de la impresora
        final provider = context.watch<HojaTiempoProvider>();
        final hoja = provider.hojaSeleccionada;
        final bool mostrarBotonImprimir =
            !provider.isLoading && hoja != null && hoja.estado == 'Aprobada';

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : Colors.grey.shade50,

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
                        "Detalle de la Semana",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    if (mostrarBotonImprimir) // <--- SOLO SI ESTÁ APROBADA
                      ElevatedButton.icon(
                        onPressed: _generarPdfSemanal,
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text("Imprimir Reporte"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                        ),
                      ),
                    const SizedBox(width: 32),
                  ],
                )
              : AppBar(
                  title: const Text(
                    "Detalle de la Semana",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    if (mostrarBotonImprimir) // <--- SOLO SI ESTÁ APROBADA
                      IconButton(
                        icon: const Icon(Icons.print),
                        tooltip: 'Imprimir Reporte Semanal',
                        onPressed: _generarPdfSemanal,
                      ),
                  ],
                  backgroundColor: AppColors.primary,
                  iconTheme: const IconThemeData(color: Colors.white),
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
          body: Consumer<HojaTiempoProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final hoja = provider.hojaSeleccionada;
              if (hoja == null) {
                return const Center(child: Text("No se encontró información."));
              }

              // Cálculos de la semana
              final dias = hoja.dias ?? [];
              final nombreServicio =
                  hoja.nombreServicio ?? "Servicio no especificado";
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

              // =====================================
              // VISTA ESCRITORIO (PANEL DIVIDIDO)
              // =====================================
              if (isDesktop) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PANEL IZQUIERDO: Info, Calendario y Resumen
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Tarjeta de Cabecera
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hoja.nombreComprobante ??
                                              "Sin Nombre",
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
                                          "${hoja.centroCosto}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Periodo: ${_formatFecha(hoja.fechaInicio)} al ${_formatFecha(hoja.fechaFin)}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // --- EL CALENDARIO VISUAL ---
                                  _buildDesktopCalendar(
                                    hoja.fechaInicio,
                                    hoja.fechaFin,
                                  ),

                                  const SizedBox(height: 24),

                                  // Resumen de Horas
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
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
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(16),
                                                ),
                                          ),
                                          child: const Text(
                                            "Resumen de Horas Semanal",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _BuildResumenItem(
                                                "Hábiles",
                                                sumHabiles,
                                                Colors.blue,
                                              ),
                                              _BuildResumenItem(
                                                "Extras",
                                                sumNoHabiles,
                                                Colors.orange,
                                              ),
                                              _BuildResumenItem(
                                                "Feriado",
                                                sumFestivas,
                                                Colors.red,
                                              ),
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
                                              _BuildResumenItem(
                                                "Viajes",
                                                sumViaje,
                                                Colors.purple,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  // Botón de Envío Global (Semana)
                                  if (hoja.estado == 'Borrador' ||
                                      hoja.estado == 'Rechazada')
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => _mostrarDialogoEnvio(
                                          context,
                                          hoja.idHojaSemana!,
                                        ),
                                        child: const Text(
                                          "ENVIAR SEMANA RESTANTE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),

                          // PANEL DERECHO: Lista de Días interactivos
                          Expanded(
                            flex: 6,
                            child: Container(
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
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
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
                                            padding: const EdgeInsets.all(24),
                                            itemCount: dias.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(height: 12),
                                            itemBuilder: (context, index) =>
                                                _buildDiaCard(
                                                  dias[index],
                                                  hoja.nombreCliente,
                                                  isDesktop,
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
                  ),
                );
              }

              // =====================================
              // VISTA MÓVIL
              // =====================================
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
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
                                  Text(
                                    "${hoja.centroCosto}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Periodo: ${_formatFecha(hoja.fechaInicio)} al ${_formatFecha(hoja.fechaFin)}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
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
                              _BuildResumenItem(
                                "Hábiles",
                                sumHabiles,
                                Colors.blue,
                              ),
                              _BuildResumenItem(
                                "Extras",
                                sumNoHabiles,
                                Colors.orange,
                              ),
                              _BuildResumenItem(
                                "Feriado",
                                sumFestivas,
                                Colors.red,
                              ),
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
                              _BuildResumenItem(
                                "Viajes",
                                sumViaje,
                                Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: dias.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay días generados para esta semana.",
                            ),
                          )
                        : ListView.builder(
                            itemCount: dias.length,
                            padding: const EdgeInsets.only(
                              bottom: 24,
                              left: 8,
                              right: 8,
                            ),
                            itemBuilder: (context, index) => _buildDiaCard(
                              dias[index],
                              hoja.nombreCliente,
                              isDesktop,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: !isDesktop
              ? Consumer<HojaTiempoProvider>(
                  builder: (context, provider, child) {
                    final hoja = provider.hojaSeleccionada;
                    if (hoja == null ||
                        (hoja.estado != 'Borrador' &&
                            hoja.estado != 'Rechazada')) {
                      return const SizedBox.shrink();
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
                            "ENVIAR SEMANA RESTANTE",
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
                )
              : null,
        );
      },
    );
  }

  // --- WIDGET PARA LA TARJETA DEL DÍA ACTUALIZADO (SLIDABLE Y BOTÓN) ---
  Widget _buildDiaCard(dynamic dia, String? nombreCliente, bool isDesktop) {
    final nombreDia = _obtenerNombreDia(dia.fecha);
    final cantidadActividades = dia.actividades?.length ?? 0;

    // El modo lectura ahora depende del estado de ESTE día en particular
    final modoLecturaDia = dia.estado == 'Enviada' || dia.estado == 'Aprobada';

    // Solo se puede enviar si está en Borrador o Rechazada, y si tiene algo registrado
    final bool sePuedeEnviar =
        (dia.estado == 'Borrador' || dia.estado == 'Rechazada') &&
        (cantidadActividades > 0 || dia.viajeHoras > 0);

    // Colores y diseño según el estado individual
    Color colorEstado;
    IconData iconEstado;
    if (dia.estado == 'Aprobada') {
      colorEstado = Colors.green;
      iconEstado = Icons.check_circle;
    } else if (dia.estado == 'Rechazada') {
      colorEstado = Colors.red;
      iconEstado = Icons.cancel;
    } else if (dia.estado == 'Enviada') {
      colorEstado = Colors.blue;
      iconEstado = Icons.access_time_filled;
    } else {
      colorEstado = Colors.orange;
      iconEstado = Icons.edit_document;
    }

    Widget contentTile = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: dia.tipoDia == 'HABIL'
            ? Colors.blue.withOpacity(0.8)
            : dia.tipoDia == 'NO_HABIL'
            ? Colors.orange.withOpacity(0.8)
            : dia.tipoDia == 'FERIADO'
            ? Colors.red.withOpacity(0.8)
            : Colors.grey,
        child: Text(
          dia.fecha.day.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nombreDia,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // Etiqueta del estado
          Row(
            children: [
              Icon(iconEstado, size: 14, color: colorEstado),
              const SizedBox(width: 4),
              Text(
                dia.estado.toUpperCase(),
                style: TextStyle(
                  color: colorEstado,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text("${dia.tipoDia} • ${dia.lugar}"),
          if (cantidadActividades > 0)
            Text(
              "$cantidadActividades actividad(es)",
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
          if (dia.estado == 'Rechazada' && dia.observacion != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "Rechazo: ${dia.observacion}",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      trailing: isDesktop
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sePuedeEnviar)
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoEnvioDia(
                      context,
                      dia.idHojaDiaria,
                      dia.idHojaSemana,
                      nombreDia,
                    ),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text("Enviar Día"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Icon(
                  modoLecturaDia ? Icons.visibility : Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            )
          : Icon(
              modoLecturaDia ? Icons.visibility : Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
      onTap: () {
        final provider = context.read<HojaTiempoProvider>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HojaDiaEditScreen(
              dia: dia,
              isReadOnly: modoLecturaDia,
              nombreCliente: nombreCliente ?? 'Desconocido',
            ),
          ),
        ).then((_) => provider.cargarDetalleHoja(widget.idHojaSemana));
      },
    );

    // Si es móvil y se puede enviar, envolvemos en un Slidable
    if (!isDesktop && sePuedeEnviar) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.35,
            children: [
              SlidableAction(
                onPressed: (context) => _mostrarDialogoEnvioDia(
                  context,
                  dia.idHojaDiaria,
                  dia.idHojaSemana,
                  nombreDia,
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.send,
                label: 'Enviar',
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: contentTile,
          ),
        ),
      );
    }

    // Si es Web o no se puede enviar, mostramos la tarjeta normal
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: contentTile,
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
