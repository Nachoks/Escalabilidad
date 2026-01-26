import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';

class EditRendicionDialog extends StatefulWidget {
  final RendicionModel rendicion;

  const EditRendicionDialog({super.key, required this.rendicion});

  @override
  State<EditRendicionDialog> createState() => _EditRendicionDialogState();
}

class _EditRendicionDialogState extends State<EditRendicionDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _propositoController;
  late TextEditingController _montoController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. PRE-CARGAR DATOS EXISTENTES
    _propositoController = TextEditingController(
      text: widget.rendicion.proposito,
    );
    _montoController = TextEditingController(
      text: widget.rendicion.montoEntregado.toString(),
    );
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

    // 2. LLAMAR A LA FUNCIÓN DE EDITAR (PUT)
    // Usamos un try-catch local para manejar la UI aquí mismo
    try {
      await provider.editarRendicion(
        widget.rendicion.idRendicion!,
        _propositoController.text,
        int.tryParse(_montoController.text) ?? 0,
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo
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
    // Datos informativos (Solo lectura)
    final String nombreServicio =
        widget.rendicion.servicio?.nombreServicio ?? 'Sin Servicio';
    final String centroCosto = widget.rendicion.servicio?.centroCosto ?? 'S/CC';

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Editar Rendición"),
          Text(
            "ID #${widget.rendicion.idRendicion}",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. INFORMACIÓN DE CONTEXTO (NO EDITABLE)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SERVICIO ASOCIADO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nombreServicio,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "CC: $centroCosto",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. PROPÓSITO (EDITABLE)
                TextFormField(
                  controller: _propositoController,
                  decoration: const InputDecoration(
                    labelText: "Propósito del gasto",
                    hintText: "Ej: Viáticos Norte",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 16),

                // 3. MONTO ENTREGADO (EDITABLE)
                TextFormField(
                  controller: _montoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Monto Entregado (Fondo)",
                    helperText: "Modifica si el anticipo cambió",
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Ingresa un monto";
                    if (int.tryParse(v) == null) return "Solo números enteros";
                    return null;
                  },
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
          onPressed: _isLoading ? null : _guardarCambios,
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
              : const Text("Guardar Cambios"),
        ),
      ],
    );
  }
}
