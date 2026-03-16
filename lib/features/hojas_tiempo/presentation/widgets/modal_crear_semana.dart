import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <--- IMPORTANTE: Añadido para dar formato bonito a las fechas
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/auth/presentation/providers/auth_provider.dart';
import '../../data/services/hoja_tiempo_service.dart';
import '../providers/hoja_tiempo_provider.dart';

class ModalCrearSemana extends StatefulWidget {
  const ModalCrearSemana({super.key});

  @override
  State<ModalCrearSemana> createState() => _ModalCrearSemanaState();
}

class _ModalCrearSemanaState extends State<ModalCrearSemana> {
  final HojaTiempoService _service = HojaTiempoService();
  final TextEditingController _hctController = TextEditingController();

  // 👇 AHORA INICIA NULA PARA OBLIGAR A SELECCIONARLA 👇
  DateTime? _fechaSeleccionada;

  List<dynamic> _clientes = [];
  List<dynamic> _servicios = [];
  List<dynamic> _ocs = [];

  String? _clienteSeleccionado;
  String? _servicioSeleccionado;
  String? _ocSeleccionada;

  bool _isLoadingListas = false;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _hctController.dispose();
    super.dispose();
  }

  // --- MAGIA: CÁLCULOS AUTOMÁTICOS DE LA SEMANA ---
  // Obtiene el Lunes de la semana del día seleccionado
  DateTime? get _lunesDeLaSemana {
    if (_fechaSeleccionada == null) return null;
    int daysToSubtract = _fechaSeleccionada!.weekday - 1;
    return _fechaSeleccionada!.subtract(Duration(days: daysToSubtract));
  }

  // Obtiene el Domingo de la semana del día seleccionado
  DateTime? get _domingoDeLaSemana {
    if (_fechaSeleccionada == null) return null;
    int daysToAdd = 7 - _fechaSeleccionada!.weekday;
    return _fechaSeleccionada!.add(Duration(days: daysToAdd));
  }

  Future<void> _cargarClientes() async {
    setState(() => _isLoadingListas = true);
    try {
      final data = await _service.obtenerClientes();
      setState(() => _clientes = data);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoadingListas = false);
    }
  }

  Future<void> _cargarServicios(String idCliente) async {
    setState(() => _isLoadingListas = true);
    try {
      final data = await _service.obtenerServicios(idCliente);
      setState(() => _servicios = data);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoadingListas = false);
    }
  }

  Future<void> _cargarOcs(String idServicio) async {
    setState(() => _isLoadingListas = true);
    try {
      final data = await _service.obtenerOcs(idServicio);
      setState(() => _ocs = data);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoadingListas = false);
    }
  }

  Future<void> _crearSemana() async {
    // 👇 AÑADIMOS VALIDACIÓN DE FECHA 👇
    if (_servicioSeleccionado == null ||
        _ocSeleccionada == null ||
        _hctController.text.trim().isEmpty ||
        _fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Completa todos los campos obligatorios y selecciona una fecha",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    // Le enviamos la fecha del LUNES al backend, para mantener todo perfectamente ordenado
    final lunes = _lunesDeLaSemana!;
    final String fechaFormat =
        "${lunes.year}-${lunes.month.toString().padLeft(2, '0')}-${lunes.day.toString().padLeft(2, '0')}";

    final provider = context.read<HojaTiempoProvider>();
    final exito = await provider.crearNuevaSemana(
      idUsuario: user.id,
      idServicio: int.parse(_servicioSeleccionado!),
      idOcCliente: int.parse(_ocSeleccionada!),
      fecha: fechaFormat,
      numeroHct: int.parse(_hctController.text.trim()),
    );

    if (!mounted) return;

    if (exito) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Semana creada con éxito!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Error al crear"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<HojaTiempoProvider>().isLoading;

    // Generamos los textos visuales para el usuario
    final lunes = _lunesDeLaSemana;
    final domingo = _domingoDeLaSemana;
    final formatoFecha = DateFormat('dd/MM/yyyy');

    // Si no hay fecha, mostramos un texto invitando a seleccionarla
    final String textoRango = (lunes != null && domingo != null)
        ? "Del ${formatoFecha.format(lunes)} al ${formatoFecha.format(domingo)}"
        : "Toca para seleccionar una fecha";

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Generar Nueva Semana",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // --- VISUALIZACIÓN DEL RANGO DE LA SEMANA ---
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              tileColor: _fechaSeleccionada != null
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.orange.shade50, // Fondo de alerta si está vacío
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _fechaSeleccionada != null
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.date_range,
                  color: _fechaSeleccionada != null
                      ? AppColors.primary
                      : Colors.orange.shade800,
                ),
              ),
              title: const Text(
                "Semana a registrar",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              subtitle: Text(
                textoRango,
                style: TextStyle(
                  fontWeight: _fechaSeleccionada != null
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: _fechaSeleccionada != null
                      ? AppColors.primary
                      : Colors.orange.shade900,
                  fontSize: _fechaSeleccionada != null ? 15 : 14,
                ),
              ),
              trailing: const Icon(
                Icons.edit,
                size: 20,
                color: AppColors.primary,
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _fechaSeleccionada ??
                      DateTime.now(), // Usa hoy solo al abrir el calendario
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                  locale: const Locale('es', 'ES'), // Calendario en español
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          onSurface: Colors.black87,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _fechaSeleccionada = picked);
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "1. Cliente",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _clienteSeleccionado,
              hint: _isLoadingListas && _clientes.isEmpty
                  ? const Text("Cargando...")
                  : const Text("Elige un cliente"),
              items: _clientes
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c['id_cliente'].toString(),
                      child: Text(c['nombre_cliente']),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _clienteSeleccionado = val;
                    _servicioSeleccionado = null;
                    _ocSeleccionada = null;
                    _servicios = [];
                    _ocs = [];
                  });
                  _cargarServicios(val);
                }
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "2. Servicio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _servicioSeleccionado,
              hint: const Text("Elige un servicio"),
              items: _servicios
                  .map(
                    (s) => DropdownMenuItem<String>(
                      value: s['id_servicio'].toString(),
                      child: Text(s['nombre_servicio']),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _servicioSeleccionado = val;
                    _ocSeleccionada = null;
                    _ocs = [];
                  });
                  _cargarOcs(val);
                }
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "3. Orden de Compra",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _ocSeleccionada,
              hint: const Text("Elige OC"),
              items: _ocs
                  .map(
                    (o) => DropdownMenuItem<String>(
                      value: o['id_oc_cliente'].toString(),
                      child: Text(o['cod_oc_cliente'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _ocSeleccionada = val),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _hctController,
              keyboardType: TextInputType.number,
              maxLength: 2,
              decoration: InputDecoration(
                labelText: "4. Correlativo HCT (1-99)",
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isCreating ? null : _crearSemana,
              child: isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Crear Semana",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
