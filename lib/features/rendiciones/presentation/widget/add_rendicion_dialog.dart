import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (newValue.text.isEmpty) return newValue;
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) return newValue;

    final int value = int.parse(newText);
    final formatter = NumberFormat.decimalPattern('es_CL');
    String newString = formatter.format(value);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class _AddRendicionDialogState extends State<AddRendicionDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _propositoController = TextEditingController();
  final TextEditingController _montoController = TextEditingController(
    text: '0',
  );
  final TextEditingController _fechaController = TextEditingController();

  ClienteModel? _clienteSeleccionado;
  ServicioModel? _servicioSeleccionado;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClienteProvider>().cargarClientes();
    });
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

    String montoLimpio = _montoController.text.replaceAll('.', '');
    int montoFinal = int.tryParse(montoLimpio) ?? 0;

    final provider = context.read<RendicionesProvider>();
    final exito = await provider.crearRendicion(
      idServicio: _servicioSeleccionado!.idServicio!,
      proposito: _propositoController.text,
      montoEntregado: montoFinal,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rendición creada exitosamente"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al crear rendición"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = context.watch<ClienteProvider>();
    final servicioProvider = context.watch<ServicioProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "Nueva Rendición",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: isDesktop ? 22 : 18,
                ),
              ),
            ],
          ),
          content: SizedBox(
            // En web restringimos el ancho a 500px, en móvil usa todo el disponible
            width: isDesktop ? 500 : double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Información del Cliente",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ClienteModel>(
                      decoration: InputDecoration(
                        labelText: "Cliente",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
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
                          _servicioSeleccionado = null;
                        });
                        if (cliente?.idCliente != null) {
                          context
                              .read<ServicioProvider>()
                              .cargarServiciosPorCliente(cliente!.idCliente!);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ServicioModel>(
                      decoration: InputDecoration(
                        labelText: "Servicio",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.work_outline),
                      ),
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
                      onChanged: (servicio) =>
                          setState(() => _servicioSeleccionado = servicio),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),

                    const Text(
                      "Detalles del Gasto",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _propositoController,
                      decoration: InputDecoration(
                        labelText: "Propósito del gasto",
                        hintText: "Ej: Viáticos Norte",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.edit_note),
                      ),
                      validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _montoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: "Monto Entregado (Fondo)",
                        helperText: "Ingresa 0 si no recibiste anticipo",
                        prefixStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Ej: 50.000",
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.save, size: 18),
              label: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Crear Rendición",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );
      },
    );
  }
}
