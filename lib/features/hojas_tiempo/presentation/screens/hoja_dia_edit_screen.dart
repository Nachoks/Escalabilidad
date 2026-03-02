import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:printing/printing.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/hoja_tiempo_model.dart';
import '../providers/hoja_tiempo_provider.dart';
import '../utils/hoja_tiempo_pdf_builder.dart';

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
  final bool isReadOnly;
  final String nombreCliente;

  const HojaDiaEditScreen({
    super.key,
    required this.dia,
    this.isReadOnly = false,
    required this.nombreCliente,
  });

  @override
  State<HojaDiaEditScreen> createState() => _HojaDiaEditScreenState();
}

class _HojaDiaEditScreenState extends State<HojaDiaEditScreen> {
  late String _lugar;
  late String _tipoDia;
  final TextEditingController _viajeController = TextEditingController();
  final FocusNode _viajeFocusNode = FocusNode();

  List<String> _opcionesArea = [];
  String? _selectedArea;
  final TextEditingController _areaManualController = TextEditingController();

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

    _opcionesArea = _getOpcionesPorCliente(widget.nombreCliente);
    String areaGuardada = widget.dia.area ?? '';

    if (areaGuardada.isEmpty) {
      _selectedArea = _opcionesArea.first;
    } else if (_opcionesArea.contains(areaGuardada)) {
      _selectedArea = areaGuardada;
    } else {
      _selectedArea = 'Otro';
      _areaManualController.text = areaGuardada;
    }

    _viajeFocusNode.addListener(() {
      if (_viajeFocusNode.hasFocus) {
        if (_viajeController.text == '0.0' || _viajeController.text == '0') {
          _viajeController.text = '';
        }
      } else {
        String texto = _viajeController.text.trim().replaceAll(',', '.');
        if (texto.isEmpty) {
          _viajeController.text = '0.0';
        } else {
          double? valor = double.tryParse(texto);
          if (valor != null) {
            _viajeController.text = valor.toStringAsFixed(1);
          } else {
            _viajeController.text = '0.0';
          }
        }
      }
    });

    if (widget.dia.horarioInicio != null)
      _horarioInicio = _parseTime(widget.dia.horarioInicio!);
    if (widget.dia.horarioFin != null)
      _horarioFin = _parseTime(widget.dia.horarioFin!);

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
    _viajeFocusNode.dispose();
    _areaManualController.dispose();
    super.dispose();
  }

  List<String> _getOpcionesPorCliente(String cliente) {
    String c = cliente.toLowerCase();
    if (c.contains('centinela')) return ['Planta', 'Puerto Centinela', 'Otro'];
    if (c.contains('softys')) return ['Puente Alto', 'Talagante', 'Otro'];
    if (c.contains('cmpc') || c.contains('pulp'))
      return ['Pacifico', 'Laja', 'Otro'];
    if (c.contains('bhp')) return ['Escondida', 'Puerto coloso', 'Otro'];
    return ['Otro'];
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
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

  bool _haySuperposicion(TimeOfDay nuevoInicio, TimeOfDay nuevoFin) {
    int nuevoInMin = nuevoInicio.hour * 60 + nuevoInicio.minute;
    int nuevoFinMin = nuevoFin.hour * 60 + nuevoFin.minute;
    if (nuevoFinMin <= nuevoInMin) nuevoFinMin += 1440;

    for (var act in _actividades) {
      int existInMin = act.horaInicio.hour * 60 + act.horaInicio.minute;
      int existFinMin = act.horaFin.hour * 60 + act.horaFin.minute;
      if (existFinMin <= existInMin) existFinMin += 1440;

      if (nuevoInMin < existFinMin && nuevoFinMin > existInMin) return true;
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
    if (widget.isReadOnly) return;
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
    if (widget.isReadOnly) return;
    TimeOfDay inicio = _horarioInicio;
    TimeOfDay fin = _horarioFin;
    final descController = TextEditingController();
    bool errorDescripcion = false;
    String? errorCruce;

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
                  errorCruce = null;
                });
                setState(() {});
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Nuevo Tramo",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => seleccionarHoraPopup(true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Inicio",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatTime(inicio),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => seleccionarHoraPopup(false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Fin",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatTime(fin),
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
                    if (errorCruce != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorCruce!,
                          style: const TextStyle(
                            color: Colors.red,
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
                        border: const OutlineInputBorder(),
                        errorText: errorDescripcion ? 'Requerido' : null,
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
                    if (descController.text.trim().isEmpty) {
                      setModalState(() => errorDescripcion = true);
                      return;
                    }
                    if (_haySuperposicion(inicio, fin)) {
                      setModalState(() => errorCruce = "Horario ocupado");
                      return;
                    }
                    setState(() {
                      _actividades.add(
                        ActividadTramo(
                          horaInicio: inicio,
                          horaFin: fin,
                          descripcion: descController.text.trim(),
                        ),
                      );
                    });
                    Navigator.pop(context);
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
    if (widget.isReadOnly) return;
    setState(() => _actividades.removeAt(index));
  }

  Future<void> _guardarCambios() async {
    if (widget.isReadOnly) return;
    FocusScope.of(context).unfocus();

    double totalHorasActividades = 0;
    for (var act in _actividades) {
      totalHorasActividades += _calcularHorasBrutas(
        act.horaInicio,
        act.horaFin,
      );
    }
    double horasViaje = double.tryParse(_viajeController.text) ?? 0.0;
    double totalDia = totalHorasActividades + horasViaje;

    if (totalDia > 24.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: La suma de trabajo y viaje ($totalDia hrs) supera 24 horas.",
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    String areaFinal = _selectedArea == 'Otro'
        ? _areaManualController.text.trim()
        : _selectedArea ?? 'Otro';

    setState(() => _isSaving = true);

    try {
      final provider = context.read<HojaTiempoProvider>();
      final data = {
        "lugar": _lugar,
        "tipo_dia": _tipoDia,
        "area": areaFinal,
        "horario_inicio": _formatTime(_horarioInicio),
        "horario_fin": _formatTime(_horarioFin),
        "viaje_horas": horasViaje,
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
            content: Text("Día guardado"),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? "Error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error Interno: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _mostrarDialogoConfirmacionSalida() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Descartar cambios?"),
        content: const Text(
          "Si sales sin guardar, perderás los cambios de este día.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _generarPdfDiario() async {
    final semana = context.read<HojaTiempoProvider>().hojaSeleccionada;
    final user = context.read<AuthProvider>().currentUser;
    if (semana == null) return;

    try {
      final pdfBytes = await HojaTiempoPdfBuilder.buildPdfDiario(
        semana: semana,
        dia: widget.dia,
        nombreUsuario: user?.nombreCompleto ?? 'Usuario',
      );
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Reporte_Diario.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error PDF: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double sumHabiles = 0, sumNoHabiles = 0, sumFestivas = 0, sumTotal = 0;
    for (var a in _actividades) {
      final desglose = _desglosarHorasTramo(a.horaInicio, a.horaFin);
      sumHabiles += desglose['habiles']!;
      sumNoHabiles += desglose['noHabiles']!;
      sumFestivas += desglose['festivas']!;
      sumTotal += _calcularHorasBrutas(a.horaInicio, a.horaFin);
    }

    return WillPopScope(
      onWillPop: () async {
        if (widget.isReadOnly) return true;
        final salir = await _mostrarDialogoConfirmacionSalida();
        return salir ?? false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 850;

          return Scaffold(
            backgroundColor: isDesktop ? const Color(0xFFF4F6F8) : Colors.white,

            // --- APPBAR ---
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
                        Text(
                          "Edición de Día: ${widget.dia.fecha.day}/${widget.dia.fecha.month}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    iconTheme: const IconThemeData(color: Colors.white),
                    actions: [
                      ElevatedButton.icon(
                        onPressed: _generarPdfDiario,
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text("Imprimir Diario"),
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
                    title: Text(
                      "Día: ${widget.dia.fecha.day}/${widget.dia.fecha.month}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    iconTheme: const IconThemeData(color: Colors.white),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.print),
                        onPressed: _generarPdfDiario,
                      ),
                    ],
                  ),

            // --- CUERPO PRINCIPAL ---
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
                child: Column(
                  children: [
                    // --- ZONA DE CONTENIDO (Scrollable o Fija según dispositivo) ---
                    Expanded(
                      child: isDesktop
                          // EN ESCRITORIO: Contenedor estático, la lista derecha scrollea sola.
                          ? _buildDesktopContent(
                              sumHabiles,
                              sumNoHabiles,
                              sumFestivas,
                              sumTotal,
                            )
                          // EN MÓVIL: Toda la pantalla scrollea junta.
                          : _buildMobileContent(
                              sumHabiles,
                              sumNoHabiles,
                              sumFestivas,
                              sumTotal,
                            ),
                    ),

                    // --- BOTÓN GUARDAR INFERIOR (Compartido, siempre visible) ---
                    if (!widget.isReadOnly)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: SafeArea(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSaving ? null : _guardarCambios,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "GUARDAR DÍA",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
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
      ),
    );
  }

  // ==========================================================
  // 💻 DISEÑO ESCRITORIO (2 COLUMNAS INDEPENDIENTES)
  // ==========================================================
  Widget _buildDesktopContent(
    double sumHabiles,
    double sumNoHabiles,
    double sumFestivas,
    double sumTotal,
  ) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Ambas columnas toman el alto máximo
          children: [
            // COLUMNA IZQUIERDA: Formulario Base y Resumen (Scroll interno por si la pantalla es pequeña)
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  right: 16,
                ), // Espacio para la barra de scroll
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isReadOnly) _buildReadOnlyAlert(),
                    const Text(
                      "Configuración del Día",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildLugarDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTipoDiaDropdown()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: _selectedArea == 'Otro' ? 1 : 2,
                          child: _buildAreaDropdown(),
                        ),
                        if (_selectedArea == 'Otro') ...[
                          const SizedBox(width: 16),
                          Expanded(child: _buildAreaManualField()),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHorarioBaseSelector(),
                    const SizedBox(height: 16),
                    _buildHorasViajeField(),
                    const SizedBox(height: 32),

                    // Resumen de Horas en la columna izquierda
                    _buildResumenHorasPanel(
                      sumHabiles,
                      sumNoHabiles,
                      sumFestivas,
                      sumTotal,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 32), // Espacio entre columnas
            // COLUMNA DERECHA: Tramos de Trabajo (¡Con Scroll Independiente!)
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Detalle Actividades",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (!widget.isReadOnly)
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
                    const Divider(height: 32),

                    // EL SECRETO ESTÁ AQUÍ: Expanded + ListView (sin shrinkWrap)
                    Expanded(
                      child: _actividades.isEmpty
                          ? const Center(
                              child: Text(
                                "No hay tramos registrados.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                right: 8,
                              ), // Para la barra de scroll
                              itemCount: _actividades.length,
                              itemBuilder: (context, index) =>
                                  _buildTramoCard(index, isDesktop: true),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 📱 DISEÑO MÓVIL (Todo en 1 columna hacia abajo)
  // ==========================================================
  Widget _buildMobileContent(
    double sumHabiles,
    double sumNoHabiles,
    double sumFestivas,
    double sumTotal,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isReadOnly) _buildReadOnlyAlert(),
          Row(
            children: [
              Expanded(child: _buildLugarDropdown()),
              const SizedBox(width: 10),
              Expanded(child: _buildTipoDiaDropdown()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: _selectedArea == 'Otro' ? 1 : 2,
                child: _buildAreaDropdown(),
              ),
              if (_selectedArea == 'Otro') ...[
                const SizedBox(width: 10),
                Expanded(child: _buildAreaManualField()),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildHorarioBaseSelector(),
          const SizedBox(height: 16),
          _buildHorasViajeField(),
          const SizedBox(height: 32),

          _buildResumenHorasPanel(
            sumHabiles,
            sumNoHabiles,
            sumFestivas,
            sumTotal,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Divider(thickness: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tramos de Trabajo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (!widget.isReadOnly)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _mostrarPopupActividad,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    "Agregar Tramo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap:
                true, // IMPORTANTE EN MÓVIL (Porque ya está dentro de un SingleChildScrollView)
            physics:
                const NeverScrollableScrollPhysics(), // IMPORTANTE EN MÓVIL
            itemCount: _actividades.length,
            itemBuilder: (context, index) =>
                _buildTramoCard(index, isDesktop: false),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA LIMPIAR EL BUILD ---

  Widget _buildReadOnlyAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, size: 20, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Text(
            "Modo Lectura - No se puede editar",
            style: TextStyle(
              color: Colors.orange.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenHorasPanel(
    double habiles,
    double noHabiles,
    double festivas,
    double total,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: const Text(
              "Resumen de Horas (Trabajo)",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BuildResumenItem("Hábiles", habiles, Colors.blue),
                _BuildResumenItem("No Hábiles", noHabiles, Colors.orange),
                _BuildResumenItem("Feriado", festivas, Colors.red),
                _BuildResumenItem("Total", total, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTramoCard(int index, {required bool isDesktop}) {
    final act = _actividades[index];
    final desglose = _desglosarHorasTramo(act.horaInicio, act.horaFin);

    return Card(
      elevation: isDesktop ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: 8,
        ),
        title: Row(
          children: [
            Text(
              "${_formatTime(act.horaInicio)} - ${_formatTime(act.horaFin)}",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(width: 16),
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
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            act.descripcion,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
        ),
        trailing: widget.isReadOnly
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: "Borrar tramo",
                onPressed: () => _eliminarActividad(index),
              ),
      ),
    );
  }

  // --- COMPONENTES FORMULARIO (SIN CAMBIOS) ---

  Widget _buildLugarDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Lugar",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: _lugar,
      items: [
        'OFICINA',
        'TERRENO',
        'DESCANSO',
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: widget.isReadOnly
          ? null
          : (val) => setState(() => _lugar = val!),
    );
  }

  Widget _buildTipoDiaDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Tipo Día",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: _tipoDia,
      items: ['HABIL', 'NO_HABIL', 'FERIADO']
          .map(
            (e) =>
                DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' '))),
          )
          .toList(),
      onChanged: widget.isReadOnly
          ? null
          : (val) => setState(() => _tipoDia = val!),
    );
  }

  Widget _buildAreaDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Área",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: _selectedArea,
      items: _opcionesArea
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: widget.isReadOnly
          ? null
          : (val) {
              setState(() {
                _selectedArea = val;
                if (val != 'Otro') _areaManualController.clear();
              });
            },
    );
  }

  Widget _buildAreaManualField() {
    return TextFormField(
      controller: _areaManualController,
      readOnly: widget.isReadOnly,
      decoration: InputDecoration(
        labelText: "Especifique",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildHorarioBaseSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _seleccionarHorarioBase(true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Entrada Base",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                child: Text(
                  _formatTime(_horarioInicio),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "-",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _seleccionarHorarioBase(false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Salida Base",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                child: Text(
                  _formatTime(_horarioFin),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorasViajeField() {
    return TextFormField(
      controller: _viajeController,
      focusNode: _viajeFocusNode,
      readOnly: widget.isReadOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: "Horas de Viaje",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.directions_car),
        suffixText: " hrs",
        suffixStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
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
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          valor.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
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
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
