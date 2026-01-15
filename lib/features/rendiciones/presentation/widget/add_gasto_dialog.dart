import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';

class AddGastoDialog extends StatefulWidget {
  final int idRendicion;

  const AddGastoDialog({super.key, required this.idRendicion});

  @override
  State<AddGastoDialog> createState() => _AddGastoDialogState();
}

class _AddGastoDialogState extends State<AddGastoDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _numDocController = TextEditingController();

  // Listas para los Dropdowns
  String _tipoSeleccionado = 'Boleta';
  final List<String> _tipos = ['Boleta', 'Factura', 'Vale', 'Ticket', 'Otro'];

  String _detalleSeleccionado = 'Alimentación';
  final List<String> _detalles = [
    'Alimentación',
    'Transporte',
    'Combustible',
    'Peaje',
    'Alojamiento',
    'Estacionamiento',
    'Equipos de computo',
    'Material de oficina',
    'Material de taller',
    'Prevención de Riesgos',
    'Otros',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Fecha de hoy por defecto
    _fechaController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Usamos el GastoProvider
    final success = await context.read<GastoProvider>().crearGasto(
      idRendicion: widget.idRendicion,
      fecha: _fechaController.text,
      monto: _montoController.text,
      numDocumento: _numDocController.text,
      tipoDoc: _tipoSeleccionado,
      detalle: _detalleSeleccionado,
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context); // Cerrar diálogo al terminar con éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gasto creado. No olvides adjuntar la foto."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nuevo Gasto"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. FECHA
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Fecha",
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      _fechaController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(picked);
                    }
                  },
                ),
                const SizedBox(height: 12),

                // 2. TIPO DOCUMENTO
                DropdownButtonFormField<String>(
                  value: _tipoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Tipo Documento",
                    border: OutlineInputBorder(),
                  ),
                  items: _tipos
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setState(() => _tipoSeleccionado = val!),
                ),
                const SizedBox(height: 12),

                // 3. ÍTEM / DETALLE
                DropdownButtonFormField<String>(
                  value: _detalleSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Ítem / Categoría",
                    border: OutlineInputBorder(),
                  ),
                  items: _detalles
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _detalleSeleccionado = val!),
                ),
                const SizedBox(height: 12),

                // 4. N° DOCUMENTO (Opcional)
                TextFormField(
                  controller: _numDocController,
                  decoration: const InputDecoration(
                    labelText: "N° Documento (Opcional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // 5. MONTO
                TextFormField(
                  controller: _montoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Monto Total",
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "El monto es obligatorio" : null,
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
          onPressed: _isSaving ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text("Guardar"),
        ),
      ],
    );
  }
}
