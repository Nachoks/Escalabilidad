import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import '../../data/models/hoja_tiempo_model.dart';
import '../providers/hoja_tiempo_provider.dart';

// --- CLASE AUXILIAR PARA MANEJAR CADA TRAMO DE TRABAJO ---
class ActividadForm {
  TimeOfDay horaInicio;
  TimeOfDay horaFin;
  TextEditingController descripcionController;

  ActividadForm({
    required this.horaInicio,
    required this.horaFin,
    String descripcion = '',
  }) : descripcionController = TextEditingController(text: descripcion);
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

  // Lista dinámica de actividades
  List<ActividadForm> _actividades = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _lugar = widget.dia.lugar;
    _tipoDia = widget.dia.tipoDia;
    _viajeController.text = widget.dia.viajeHoras.toString();

    // Si el día ya tenía actividades guardadas, las cargamos en la lista
    if (widget.dia.actividades != null) {
      for (var act in widget.dia.actividades!) {
        _actividades.add(
          ActividadForm(
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
    for (var act in _actividades) {
      act.descripcionController.dispose();
    }
    super.dispose();
  }

  // Utilidad para convertir "08:00:00" que viene de la BD a TimeOfDay de Flutter
  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Utilidad para convertir TimeOfDay a "08:00" para mandar a Laravel
  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // Abre el reloj para elegir la hora
  Future<void> _seleccionarHora(
    BuildContext context,
    int index,
    bool isInicio,
  ) async {
    final inicial = isInicio
        ? _actividades[index].horaInicio
        : _actividades[index].horaFin;
    final picked = await showTimePicker(
      context: context,
      initialTime: inicial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true), // Formato 24h
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _actividades[index].horaInicio = picked;
        } else {
          _actividades[index].horaFin = picked;
        }
      });
    }
  }

  void _agregarActividad() {
    setState(() {
      _actividades.add(
        ActividadForm(
          horaInicio: const TimeOfDay(hour: 8, minute: 0),
          horaFin: const TimeOfDay(hour: 18, minute: 0),
        ),
      );
    });
  }

  void _eliminarActividad(int index) {
    setState(() {
      _actividades[index].descripcionController.dispose();
      _actividades.removeAt(index);
    });
  }

  Future<void> _guardarCambios() async {
    // Validación básica
    for (var act in _actividades) {
      if (act.descripcionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Las actividades deben tener una descripción"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    final provider = context.read<HojaTiempoProvider>();

    // Armamos el JSON con la configuración base + la lista de actividades
    final data = {
      "lugar": _lugar,
      "tipo_dia": _tipoDia,
      "viaje_horas": double.tryParse(_viajeController.text) ?? 0.0,
      "actividades": _actividades
          .map(
            (a) => {
              "hora_inicio": _formatTime(a.horaInicio),
              "hora_fin": _formatTime(a.horaFin),
              "descripcion": a.descripcionController.text.trim(),
              // Enviamos las horas en 0 por defecto, Laravel o el proceso de validación posterior puede calcularlas
              "horas_habiles": 0,
              "horas_no_habiles": 0,
              "horas_festivas": 0,
            },
          )
          .toList(),
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
            // --- 1. CONFIGURACIÓN DEL DÍA ---
            const Text(
              "Configuración General",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

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
                      labelText: "Tipo",
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

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(thickness: 2),
            ),

            // --- 2. TRAMOS DE TRABAJO (ACTIVIDADES) ---
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
                IconButton(
                  onPressed: _agregarActividad,
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                    size: 30,
                  ),
                  tooltip: "Agregar Actividad",
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_actividades.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "No hay actividades registradas. Presiona el botón verde para agregar una.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            // Lista de tarjetas de actividad
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Para que haga scroll con toda la pantalla
              itemCount: _actividades.length,
              itemBuilder: (context, index) {
                final act = _actividades[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Actividad #${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _eliminarActividad(index),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    _seleccionarHora(context, index, true),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: "Inicio",
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _formatTime(act.horaInicio),
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
                                onTap: () =>
                                    _seleccionarHora(context, index, false),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: "Fin",
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _formatTime(act.horaFin),
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
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: act.descripcionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: "Descripción del trabajo realizado",
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // --- 3. BOTÓN GUARDAR FIJO ABAJO ---
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
