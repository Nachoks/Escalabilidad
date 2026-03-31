import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import '../../data/models/proveedor_model.dart';
import '../providers/proveedor_provider.dart';

class ProveedorDialog extends StatefulWidget {
  final ProveedorModel? proveedor; // Null = Crear, Datos = Editar

  const ProveedorDialog({super.key, this.proveedor});

  @override
  State<ProveedorDialog> createState() => _ProveedorDialogState();
}

class _ProveedorDialogState extends State<ProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos solo el controlador del nombre de la empresa
    _nombreCtrl = TextEditingController(
      text: widget.proveedor?.nombreProveedor ?? '',
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Creamos el modelo para enviar a Laravel
    final nuevoProv = ProveedorModel(
      idProveedor: widget.proveedor?.idProveedor ?? 0,
      nombreProveedor: _nombreCtrl.text.trim(),
      // Si estamos editando el nombre de un proveedor, le volvemos a pasar
      // sus contactos actuales para que Laravel no los borre.
      // Si es nuevo, simplemente mandamos una lista vacía [].
      contactos: widget.proveedor?.contactos ?? [],
    );

    final provider = context.read<ProveedorProvider>();
    final exito = await provider.guardarProveedor(nuevoProv);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (exito) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.proveedor == null
                ? '✅ Proveedor creado con éxito'
                : '✅ Proveedor actualizado',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Error desconocido"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.proveedor != null;

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
              Icon(
                isEditing ? Icons.edit : Icons.domain_add,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isEditing ? "Editar Empresa" : "Nuevo Proveedor",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: isDesktop ? 22 : 18,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: isDesktop ? 400 : double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ingresa el nombre comercial o razón social de la empresa proveedora.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nombreCtrl,
                    validator: _validarRequerido,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Razón Social / Nombre *',
                      prefixIcon: const Icon(Icons.business, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical:
                            16, // Un poco más alto para que se vea elegante
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
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
              onPressed: _isSaving ? null : _guardar,
              icon: _isSaving
                  ? const SizedBox.shrink()
                  : const Icon(Icons.save, size: 18),
              label: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Guardar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );
      },
    );
  }
}
