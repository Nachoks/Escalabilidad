import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  DateTime _fechaSeleccionada = DateTime.now();

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
    if (_servicioSeleccionado == null ||
        _ocSeleccionada == null ||
        _hctController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos obligatorios"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final String fechaFormat =
        "${_fechaSeleccionada.year}-${_fechaSeleccionada.month.toString().padLeft(2, '0')}-${_fechaSeleccionada.day.toString().padLeft(2, '0')}";

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

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_month,
                color: AppColors.primary,
              ),
              title: const Text("Semana a registrar"),
              subtitle: Text(
                "${_fechaSeleccionada.day}-${_fechaSeleccionada.month}-${_fechaSeleccionada.year}",
              ),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _fechaSeleccionada,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _fechaSeleccionada = picked);
              },
            ),
            const Divider(),
            const SizedBox(height: 10),

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
