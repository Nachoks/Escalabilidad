import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para TextInputFormatter
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/data/models/servicio_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';

class AddRendicionDialog extends StatefulWidget {
  const AddRendicionDialog({super.key});

  @override
  State<AddRendicionDialog> createState() => _AddRendicionDialogState();
}

// --- CLASE PARA FORMATEAR CON PUNTOS ---
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si está vacío, retornamos nada
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 1. Limpiamos cualquier cosa que no sea número
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Si después de limpiar no queda nada, retornamos vacío
    if (newText.isEmpty) return newValue;

    // 3. Formateamos con puntos (Locale de Chile para miles)
    final int value = int.parse(newText);
    final formatter = NumberFormat.decimalPattern('es_CL');
    String newString = formatter.format(value);

    // 4. Retornamos el valor formateado manteniendo el cursor al final
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class _AddRendicionDialogState extends State<AddRendicionDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _propositoController = TextEditingController();
  final TextEditingController _montoController = TextEditingController(
    text: '0', // Valor inicial
  );
  final TextEditingController _fechaController = TextEditingController();

  ClienteModel? _clienteSeleccionado;
  ServicioModel? _servicioSeleccionado;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargar clientes al abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClienteProvider>().cargarClientes();
    });

    // Fecha por defecto: Hoy
    _fechaController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_servicioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes seleccionar un servicio")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- CORRECCIÓN AQUÍ ---
    // 1. Obtenemos el texto (Ej: "50.000")
    // 2. Quitamos los puntos (Ej: "50000")
    // 3. Convertimos a int
    String montoLimpio = _montoController.text.replaceAll('.', '');
    int montoFinal = int.tryParse(montoLimpio) ?? 0;

    final provider = context.read<RendicionesProvider>();
    final exito = await provider.crearRendicion(
      idServicio: _servicioSeleccionado!.idServicio!,
      proposito: _propositoController.text,
      montoEntregado: montoFinal, // Enviamos el número limpio
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (exito) {
        Navigator.pop(context); // Cerrar diálogo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rendición creada exitosamente")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al crear rendición")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = context.watch<ClienteProvider>();
    final servicioProvider = context.watch<ServicioProvider>();

    return AlertDialog(
      title: const Text("Nueva Rendición"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. DROPDOWN CLIENTE
                DropdownButtonFormField<ClienteModel>(
                  decoration: const InputDecoration(labelText: "Cliente"),
                  value: _clienteSeleccionado,
                  isExpanded: true,
                  items: clienteProvider.clientes.map((cliente) {
                    return DropdownMenuItem(
                      value: cliente,
                      child: Text(
                        cliente.nombreCliente,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (cliente) {
                    setState(() {
                      _clienteSeleccionado = cliente;
                      _servicioSeleccionado = null; // Resetear servicio
                    });
                    if (cliente?.idCliente != null) {
                      context
                          .read<ServicioProvider>()
                          .cargarServiciosPorCliente(cliente!.idCliente!);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 2. DROPDOWN SERVICIO
                DropdownButtonFormField<ServicioModel>(
                  decoration: const InputDecoration(labelText: "Servicio"),
                  value: _servicioSeleccionado,
                  isExpanded: true,
                  hint: servicioProvider.isLoading
                      ? const Text("Cargando servicios...")
                      : const Text("Selecciona un servicio"),
                  items: servicioProvider.servicios.map((servicio) {
                    return DropdownMenuItem(
                      value: servicio,
                      child: Text(
                        "${servicio.nombreServicio} (${servicio.centroCosto ?? 'S/CC'})",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (servicio) {
                    setState(() => _servicioSeleccionado = servicio);
                  },
                ),
                const SizedBox(height: 16),

                // 3. PROPÓSITO
                TextFormField(
                  controller: _propositoController,
                  decoration: const InputDecoration(
                    labelText: "Propósito del gasto",
                    hintText: "Ej: Viáticos Norte",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 16),

                // 4. MONTO ENTREGADO (FONDO) - CORREGIDO
                TextFormField(
                  controller: _montoController,
                  keyboardType: TextInputType.number,
                  // --- CORRECCIÓN AQUÍ: Agregamos los formatters ---
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Solo números
                    ThousandsSeparatorInputFormatter(), // Puntos visuales
                  ],
                  decoration: const InputDecoration(
                    labelText: "Monto Entregado (Fondo)",
                    helperText: "Ingresa 0 si no recibiste anticipo",
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                    hintText: "Ej: 50.000",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text("Crear Rendición"),
        ),
      ],
    );
  }
}
