import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Formateador para poner puntos de miles automáticamente (Ej: 10.000)
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 1. Limpiamos cualquier cosa que no sea número
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Si queda vacío, retornamos
    if (newText.isEmpty) return newValue;

    // 3. Formateamos con puntos
    final int value = int.parse(newText);
    final formatter = NumberFormat.decimalPattern('es_CL');
    String newString = formatter.format(value);

    // 4. Retornamos el valor formateado y mantenemos el cursor al final
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class _AddGastoDialogState extends State<AddGastoDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _numDocController = TextEditingController();
  final TextEditingController _otroTipoController = TextEditingController();
  final TextEditingController _otroDetalleController = TextEditingController();

  // Listas y valores seleccionados
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

    // 1. Definir qué guardar en TIPO
    String tipoFinalParaBD;
    if (_tipoSeleccionado == 'Otro') {
      tipoFinalParaBD = _otroTipoController.text.trim();
    } else {
      tipoFinalParaBD = _tipoSeleccionado;
    }

    // 2. Definir qué guardar en DETALLE
    String detalleFinalParaBD;
    if (_detalleSeleccionado == 'Otros') {
      detalleFinalParaBD = _otroDetalleController.text.trim();
    } else {
      detalleFinalParaBD = _detalleSeleccionado;
    }

    // ---------------------------------------------------------
    // CORRECCIÓN PRINCIPAL: Limpiar los puntos antes de enviar
    // Transforma "20.000" en "20000"
    // ---------------------------------------------------------
    String montoLimpio = _montoController.text.replaceAll('.', '');

    // Enviamos a la BD los valores limpios
    final success = await context.read<GastoProvider>().crearGasto(
      idRendicion: widget.idRendicion,
      fecha: _fechaController.text,
      monto: montoLimpio, // <--- Usamos la variable limpia aquí
      numDocumento: _numDocController.text,
      tipoDoc: tipoFinalParaBD,
      detalle: detalleFinalParaBD,
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
                  onChanged: (val) {
                    setState(() {
                      _tipoSeleccionado = val!;
                      if (val != 'Otro') _otroTipoController.clear();
                    });
                  },
                ),

                // CAMPO "OTRO TIPO"
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

                // 3. ÍTEM / CATEGORÍA
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

                // CAMPO "OTRO DETALLE"
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Monto Total",
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                    hintText: "Ej: 10.000",
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
