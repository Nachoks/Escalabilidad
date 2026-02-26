import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';

class EditRendicionDialog extends StatefulWidget {
  final RendicionModel rendicion;

  const EditRendicionDialog({super.key, required this.rendicion});

  @override
  State<EditRendicionDialog> createState() => _EditRendicionDialogState();
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

class _EditRendicionDialogState extends State<EditRendicionDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _propositoController;
  late TextEditingController _montoController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _propositoController = TextEditingController(
      text: widget.rendicion.proposito,
    );

    final formatter = NumberFormat.decimalPattern('es_CL');
    String montoFormateado = formatter.format(widget.rendicion.montoEntregado);
    _montoController = TextEditingController(text: montoFormateado);
  }

  @override
  void dispose() {
    _propositoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<RendicionesProvider>();
    String montoLimpio = _montoController.text.replaceAll('.', '');
    int montoFinal = int.tryParse(montoLimpio) ?? 0;

    try {
      await provider.editarRendicion(
        widget.rendicion.idRendicion!,
        _propositoController.text,
        montoFinal,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rendición actualizada correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombreServicio =
        widget.rendicion.servicio?.nombreServicio ?? 'Sin Servicio';
    final String centroCosto = widget.rendicion.servicio?.centroCosto ?? 'S/CC';

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
              const Icon(Icons.edit_document, color: AppColors.primary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Editar Rendición",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: isDesktop ? 22 : 18,
                    ),
                  ),
                  Text(
                    "ID #${widget.rendicion.idRendicion}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: isDesktop
                ? 500
                : double.maxFinite, // Limitamos el ancho en PC
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. INFORMACIÓN DE CONTEXTO (NO EDITABLE)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: Colors.grey.shade500,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "SERVICIO ASOCIADO",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nombreServicio,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "CC: $centroCosto",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. PROPÓSITO (EDITABLE)
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
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
                    ),
                    const SizedBox(height: 16),

                    // 3. MONTO ENTREGADO (EDITABLE)
                    TextFormField(
                      controller: _montoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: "Monto Entregado (Fondo)",
                        helperText: "Modifica si el anticipo cambió",
                        prefixStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Ingresa un monto";
                        if (int.tryParse(v.replaceAll('.', '')) == null)
                          return "Solo números enteros";
                        return null;
                      },
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
              onPressed: _isLoading ? null : _guardarCambios,
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
                      "Guardar Cambios",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );
      },
    );
  }
}
