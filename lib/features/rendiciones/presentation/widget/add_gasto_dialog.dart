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
    if (newValue.text.isEmpty) return newValue;

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
    _fechaController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // 1. Definir qué guardar en TIPO
    String tipoFinalParaBD = _tipoSeleccionado == 'Otro'
        ? _otroTipoController.text.trim()
        : _tipoSeleccionado;

    // 2. Definir qué guardar en DETALLE
    String detalleFinalParaBD = _detalleSeleccionado == 'Otros'
        ? _otroDetalleController.text.trim()
        : _detalleSeleccionado;

    // 3. CONVERSIÓN DE FECHA
    String fechaParaBD = _fechaController.text;
    try {
      final DateTime fechaObj = DateFormat(
        'dd-MM-yyyy',
      ).parse(_fechaController.text);
      fechaParaBD = DateFormat('yyyy-MM-dd').format(fechaObj);
    } catch (e) {
      print("Error al formatear fecha: $e");
    }

    // 4. Limpiar los puntos del monto
    String montoLimpio = _montoController.text.replaceAll('.', '');

    // Enviamos a la BD
    final success = await context.read<GastoProvider>().crearGasto(
      idRendicion: widget.idRendicion,
      fecha: fechaParaBD,
      monto: montoLimpio,
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
              const Icon(Icons.add_shopping_cart, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "Nuevo Gasto",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: isDesktop ? 22 : 18,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: isDesktop ? 500 : double.maxFinite, // Ancho controlado en PC
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. FECHA
                    TextFormField(
                      controller: _fechaController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Fecha del Gasto",
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                            'dd-MM-yyyy',
                          ).format(picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. TIPO DOCUMENTO
                    DropdownButtonFormField<String>(
                      value: _tipoSeleccionado,
                      decoration: InputDecoration(
                        labelText: "Tipo Documento",
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _tipos
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _otroTipoController,
                        decoration: InputDecoration(
                          labelText: "¿Qué tipo de documento es?",
                          hintText: "Ej: Vale Vista, Recibo Simple...",
                          prefixIcon: const Icon(Icons.edit),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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

                    const SizedBox(height: 16),

                    // 3. N° DOCUMENTO
                    TextFormField(
                      controller: _numDocController,
                      decoration: InputDecoration(
                        labelText: "N° Documento (Opcional)",
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1),
                    ),

                    // 4. ÍTEM / CATEGORÍA
                    DropdownButtonFormField<String>(
                      value: _detalleSeleccionado,
                      decoration: InputDecoration(
                        labelText: "Categoría del Gasto",
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _detalles
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _otroDetalleController,
                        decoration: InputDecoration(
                          labelText: "¿Cuál es el ítem?",
                          hintText: "Ej: Reparación Neumático...",
                          prefixIcon: const Icon(Icons.edit_note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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

                    const SizedBox(height: 16),

                    // 5. MONTO
                    TextFormField(
                      controller: _montoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: "Monto Total",
                        prefixStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        hintText: "Ej: 10.000",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? "El monto es obligatorio" : null,
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
              onPressed: _isSaving ? null : _guardar,
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
              icon: _isSaving
                  ? const SizedBox.shrink()
                  : const Icon(Icons.save, size: 18),
              label: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Guardar Gasto",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );
      },
    );
  }
}
