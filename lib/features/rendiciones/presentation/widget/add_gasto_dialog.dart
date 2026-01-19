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

  // Controladores básicos
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _numDocController = TextEditingController();

  // Controladores para cuando seleccionan "Otro"
  final TextEditingController _otroTipoController = TextEditingController();
  final TextEditingController _otroDetalleController = TextEditingController();

  // Listas
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
    _fechaController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // --- AQUÍ ESTÁ LA LÓGICA QUE PIDES ---

    // 1. Definir qué guardar en TIPO
    String tipoFinalParaBD;
    if (_tipoSeleccionado == 'Otro') {
      // Si eligió "Otro", ignoramos la palabra "Otro" y guardamos lo que escribió
      tipoFinalParaBD = _otroTipoController.text.trim();
    } else {
      // Si eligió "Boleta", guardamos "Boleta"
      tipoFinalParaBD = _tipoSeleccionado;
    }

    // 2. Definir qué guardar en DETALLE (Ítem)
    String detalleFinalParaBD;
    if (_detalleSeleccionado == 'Otros') {
      // Si eligió "Otros", ignoramos la palabra y guardamos lo que escribió
      detalleFinalParaBD = _otroDetalleController.text.trim();
    } else {
      // Si eligió "Peaje", guardamos "Peaje"
      detalleFinalParaBD = _detalleSeleccionado;
    }

    // Enviamos a la BD los valores finales limpios
    final success = await context.read<GastoProvider>().crearGasto(
      idRendicion: widget.idRendicion,
      fecha: _fechaController.text,
      monto: _montoController.text,
      numDocumento: _numDocController.text,
      tipoDoc: tipoFinalParaBD, // Se enviará "Vale Vista" (no "Otro")
      detalle: detalleFinalParaBD, // Se enviará "Repuestos" (no "Otros")
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gasto creado correctamente."),
          backgroundColor: Colors.green,
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

                // 2. TIPO DOCUMENTO (Dropdown)
                DropdownButtonFormField<String>(
                  value: _tipoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Tipo Documento",
                    border: OutlineInputBorder(),
                  ),
                  items: _tipos
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _tipoSeleccionado = val!;
                      // Limpiamos el texto si cambia de opción para evitar errores
                      if (val != 'Otro') _otroTipoController.clear();
                    });
                  },
                ),

                // CAMPO "OTRO TIPO" (Solo aparece si selecciona Otro)
                if (_tipoSeleccionado == 'Otro') ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _otroTipoController,
                    decoration: const InputDecoration(
                      labelText: "¿Qué tipo de documento es?",
                      hintText: "Ej: Vale Vista, Recibo Simple...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                    validator: (v) {
                      if (_tipoSeleccionado == 'Otro' &&
                          (v == null || v.trim().isEmpty)) {
                        return 'Debe especificar el nombre del documento';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 12),

                // 3. ÍTEM / CATEGORÍA (Dropdown)
                DropdownButtonFormField<String>(
                  value: _detalleSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Ítem / Categoría",
                    border: OutlineInputBorder(),
                  ),
                  items: _detalles
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _detalleSeleccionado = val!;
                      if (val != 'Otros') _otroDetalleController.clear();
                    });
                  },
                ),

                // CAMPO "OTRO DETALLE" (Solo aparece si selecciona Otros)
                if (_detalleSeleccionado == 'Otros') ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _otroDetalleController,
                    decoration: const InputDecoration(
                      labelText: "¿Cuál es el ítem?",
                      hintText: "Ej: Reparación Neumático...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                    validator: (v) {
                      if (_detalleSeleccionado == 'Otros' &&
                          (v == null || v.trim().isEmpty)) {
                        return 'Debe especificar el detalle';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 12),

                // 4. N° DOCUMENTO
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
