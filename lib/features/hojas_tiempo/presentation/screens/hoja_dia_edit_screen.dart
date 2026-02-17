import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import '../../data/models/hoja_tiempo_model.dart';
import '../providers/hoja_tiempo_provider.dart';

class ActividadTramo {
  TimeOfDay horaInicio;
  TimeOfDay horaFin;
  String descripcion;

  ActividadTramo({
    required this.horaInicio,
    required this.horaFin,
    required this.descripcion,
  });
}

class HojaDiaEditScreen extends StatefulWidget {
  final HojaTiempoDiaria dia;

  const HojaDiaEditScreen({super.key, required this.dia});

  @override
  State<HojaDiaEditScreen> createState() => _HojaDiaEditScreenState();
}

class _HojaDiaEditScreenState extends State<HojaDiaEditScreen> {
  late String _lugar;
  late String _tipoDia;
  final TextEditingController _viajeController = TextEditingController();

  TimeOfDay _horarioInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _horarioFin = const TimeOfDay(hour: 18, minute: 0);

  List<ActividadTramo> _actividades = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _lugar = widget.dia.lugar;
    _tipoDia = widget.dia.tipoDia;
    _viajeController.text = widget.dia.viajeHoras.toString();

    if (widget.dia.horarioInicio != null) {
      _horarioInicio = _parseTime(widget.dia.horarioInicio!);
    }
    if (widget.dia.horarioFin != null) {
      _horarioFin = _parseTime(widget.dia.horarioFin!);
    }

    if (widget.dia.actividades != null) {
      for (var act in widget.dia.actividades!) {
        _actividades.add(
          ActividadTramo(
            horaInicio: _parseTime(act.horaInicio),
            horaFin: _parseTime(act.horaFin),
            descripcion: act.descripcion,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _viajeController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  double _calcularHorasBrutas(TimeOfDay inicio, TimeOfDay fin) {
    int minInicio = inicio.hour * 60 + inicio.minute;
    int minFin = fin.hour * 60 + fin.minute;
    int diff = minFin - minInicio;
    if (diff < 0) diff += 1440;
    return diff / 60.0;
  }

  // --- NUEVA LÓGICA: DETECCIÓN DE CRUCE DE HORARIOS ---
  bool _haySuperposicion(TimeOfDay nuevoInicio, TimeOfDay nuevoFin) {
    int nuevoInMin = nuevoInicio.hour * 60 + nuevoInicio.minute;
    int nuevoFinMin = nuevoFin.hour * 60 + nuevoFin.minute;

    // Si cruza la medianoche, sumamos 24h
    if (nuevoFinMin <= nuevoInMin) nuevoFinMin += 1440;

    for (var act in _actividades) {
      int existInMin = act.horaInicio.hour * 60 + act.horaInicio.minute;
      int existFinMin = act.horaFin.hour * 60 + act.horaFin.minute;

      if (existFinMin <= existInMin) existFinMin += 1440;

      // REGLA: Si el inicio del nuevo es menor al fin del existente,
      // Y el fin del nuevo es mayor al inicio del existente -> CHOCAN
      if (nuevoInMin < existFinMin && nuevoFinMin > existInMin) {
        return true;
      }
    }
    return false;
  }

  Map<String, double> _desglosarHorasTramo(TimeOfDay tInicio, TimeOfDay tFin) {
    double total = _calcularHorasBrutas(tInicio, tFin);

    if (_tipoDia == 'FERIADO') {
      return {'habiles': 0, 'noHabiles': 0, 'festivas': total};
    } else if (_tipoDia == 'NO_HABIL') {
      return {'habiles': 0, 'noHabiles': total, 'festivas': 0};
    } else {
      int tramoI = tInicio.hour * 60 + tInicio.minute;
      int tramoF = tFin.hour * 60 + tFin.minute;
      if (tramoF < tramoI) tramoF += 1440;

      int horI = _horarioInicio.hour * 60 + _horarioInicio.minute;
      int horF = _horarioFin.hour * 60 + _horarioFin.minute;
      if (horF < horI) horF += 1440;

      int overlapI = tramoI > horI ? tramoI : horI;
      int overlapF = tramoF < horF ? tramoF : horF;

      int overlapMins = overlapF - overlapI;
      if (overlapMins < 0) overlapMins = 0;

      double habiles = overlapMins / 60.0;
      double noHabiles = total - habiles;

      if (noHabiles < 0.01) noHabiles = 0;

      return {'habiles': habiles, 'noHabiles': noHabiles, 'festivas': 0};
    }
  }

  Future<void> _seleccionarHorarioBase(bool isInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horarioInicio : _horarioFin,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isInicio)
          _horarioInicio = picked;
        else
          _horarioFin = picked;
      });
    }
  }

  void _mostrarPopupActividad() {
    TimeOfDay inicio = _horarioInicio;
    TimeOfDay fin = _horarioFin;
    final descController = TextEditingController();

    bool errorDescripcion = false;
    String? errorCruce; // Variable para mostrar el error de choque de horas

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> seleccionarHoraPopup(bool isInicio) async {
              final picked = await showTimePicker(
                context: context,
                initialTime: isInicio ? inicio : fin,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                ),
              );
              if (picked != null) {
                setModalState(() {
                  if (isInicio)
                    inicio = picked;
                  else
                    fin = picked;
                  errorCruce =
                      null; // Si el usuario cambia la hora, borramos el error previo
                });
                setState(() {});
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Nuevo Tramo de Trabajo",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => seleccionarHoraPopup(true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Hora Inicio",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatTime(inicio),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("-", style: TextStyle(fontSize: 24)),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => seleccionarHoraPopup(false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Hora Fin",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatTime(fin),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- MOSTRAR MENSAJE DE ERROR SI CHOCAN LAS HORAS ---
                    if (errorCruce != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorCruce!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Descripción",
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                        errorText: errorDescripcion
                            ? 'La descripción es obligatoria'
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    // Validación 1: Descripción obligatoria
                    if (descController.text.trim().isEmpty) {
                      setModalState(() => errorDescripcion = true);
                      return;
                    } else {
                      setModalState(() => errorDescripcion = false);
                    }

                    // Validación 2: Superposición de horas
                    if (_haySuperposicion(inicio, fin)) {
                      setModalState(() {
                        errorCruce =
                            "Este horario se cruza con un tramo ya registrado.";
                      });
                      return; // Detiene el guardado, no cierra el modal
                    }

                    // Si pasa las validaciones, se guarda
                    setState(() {
                      _actividades.add(
                        ActividadTramo(
                          horaInicio: inicio,
                          horaFin: fin,
                          descripcion: descController.text.trim(),
                        ),
                      );
                    });
                    Navigator.pop(context); // Cierra el modal
                  },
                  child: const Text(
                    "Agregar",
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

  void _eliminarActividad(int index) {
    setState(() {
      _actividades.removeAt(index);
    });
  }

  Future<void> _guardarCambios() async {
    setState(() => _isSaving = true);
    final provider = context.read<HojaTiempoProvider>();

    final data = {
      "lugar": _lugar,
      "tipo_dia": _tipoDia,
      "horario_inicio": _formatTime(_horarioInicio),
      "horario_fin": _formatTime(_horarioFin),
      "viaje_horas": double.tryParse(_viajeController.text) ?? 0.0,
      "actividades": _actividades.map((a) {
        final desglose = _desglosarHorasTramo(a.horaInicio, a.horaFin);
        return {
          "hora_inicio": _formatTime(a.horaInicio),
          "hora_fin": _formatTime(a.horaFin),
          "descripcion": a.descripcion,
          "horas_habiles": desglose['habiles'],
          "horas_no_habiles": desglose['noHabiles'],
          "horas_festivas": desglose['festivas'],
        };
      }).toList(),
    };

    final exito = await provider.actualizarDia(widget.dia.idHojaDiaria, data);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Día guardado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Error al guardar"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double sumHabiles = 0;
    double sumNoHabiles = 0;
    double sumFestivas = 0;
    double sumTotal = 0;

    for (var a in _actividades) {
      final desglose = _desglosarHorasTramo(a.horaInicio, a.horaFin);
      sumHabiles += desglose['habiles']!;
      sumNoHabiles += desglose['noHabiles']!;
      sumFestivas += desglose['festivas']!;
      sumTotal += _calcularHorasBrutas(a.horaInicio, a.horaFin);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Día: ${widget.dia.fecha.day}/${widget.dia.fecha.month}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Configuración del Día",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Lugar",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    value: _lugar,
                    items: ['OFICINA', 'TERRENO', 'DESCANSO']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _lugar = val!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Tipo Día",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    value: _tipoDia,
                    items: ['HABIL', 'NO_HABIL', 'FERIADO']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.replaceAll('_', ' '),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _tipoDia = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Horario Base (Normal)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _seleccionarHorarioBase(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Entrada",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                            ),
                            child: Text(
                              _formatTime(_horarioInicio),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("-", style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _seleccionarHorarioBase(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Salida",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                            ),
                            child: Text(
                              _formatTime(_horarioFin),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _viajeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: "Horas de Viaje (Ej: 1.5)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.directions_car),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
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
                      "Resumen de Horas (Trabajo)",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BuildResumenItem("Hábiles", sumHabiles, Colors.blue),
                        _BuildResumenItem(
                          "No Hábiles",
                          sumNoHabiles,
                          Colors.orange,
                        ),
                        _BuildResumenItem("Feriado", sumFestivas, Colors.red),
                        _BuildResumenItem("Total", sumTotal, Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(thickness: 2),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tramos de Trabajo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _mostrarPopupActividad,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Agregar"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_actividades.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "No hay actividades. Presiona 'Agregar' para registrar tu trabajo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _actividades.length,
              itemBuilder: (context, index) {
                final act = _actividades[index];
                final desglose = _desglosarHorasTramo(
                  act.horaInicio,
                  act.horaFin,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Row(
                      children: [
                        Text(
                          "${_formatTime(act.horaInicio)} - ${_formatTime(act.horaFin)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (desglose['habiles']! > 0)
                          _Badge(
                            "${desglose['habiles']!.toStringAsFixed(1)}h",
                            Colors.blue,
                          ),
                        if (desglose['noHabiles']! > 0)
                          _Badge(
                            "${desglose['noHabiles']!.toStringAsFixed(1)}h",
                            Colors.orange,
                          ),
                        if (desglose['festivas']! > 0)
                          _Badge(
                            "${desglose['festivas']!.toStringAsFixed(1)}h",
                            Colors.red,
                          ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(act.descripcion),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarActividad(index),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isSaving ? null : _guardarCambios,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "GUARDAR DÍA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
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
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String texto;
  final Color color;
  const _Badge(this.texto, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
