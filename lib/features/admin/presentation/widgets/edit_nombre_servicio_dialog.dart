import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/servicio_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';

class EditNombreServicioDialog extends StatefulWidget {
  final ServicioModel servicio;

  const EditNombreServicioDialog({super.key, required this.servicio});

  @override
  State<EditNombreServicioDialog> createState() =>
      _EditNombreServicioDialogState();
}

class _EditNombreServicioDialogState extends State<EditNombreServicioDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador con el nombre actual
    _nombreController = TextEditingController(
      text: widget.servicio.nombreServicio,
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Nombre del Servicio'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Servicio',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre no puede estar vacío';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _isSaving ? null : _guardarCambios,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text("Guardar"),
        ),
      ],
    );
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final nuevoNombre = _nombreController.text.trim();

      // Llamamos al provider (Debes implementar este método en tu Provider)
      final success = await context
          .read<ServicioProvider>()
          .actualizarNombreServicio(widget.servicio.idServicio!, nuevoNombre);

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (success) {
        Navigator.pop(context, true); // Retornamos true para indicar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar nombre'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
