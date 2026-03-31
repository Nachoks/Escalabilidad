import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import '../../data/models/proveedor_model.dart';
import '../../data/models/contacto_proveedor_model.dart';
import '../providers/proveedor_provider.dart';

class ContactoProveedorDialog extends StatefulWidget {
  final ProveedorModel proveedorOriginal;
  final ContactoProveedorModel? contactoAEditar; // Null = Nuevo Contacto
  final int?
  indexContacto; // Para saber qué posición de la lista reemplazar al editar

  const ContactoProveedorDialog({
    super.key,
    required this.proveedorOriginal,
    this.contactoAEditar,
    this.indexContacto,
  });

  @override
  State<ContactoProveedorDialog> createState() =>
      _ContactoProveedorDialogState();
}

class _ContactoProveedorDialogState extends State<ContactoProveedorDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _numeroCtrl;
  late TextEditingController _correoCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, llenamos los campos con los datos del contacto
    _nombreCtrl = TextEditingController(
      text: widget.contactoAEditar?.nombreContacto ?? '',
    );
    _numeroCtrl = TextEditingController(
      text: widget.contactoAEditar?.numeroContacto ?? '',
    );
    _correoCtrl = TextEditingController(
      text: widget.contactoAEditar?.correoContacto ?? '',
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _numeroCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    return null;
  }

  String? _validarEmailOpcional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // 1. Creamos el objeto del contacto con los datos del formulario
    final nuevoContacto = ContactoProveedorModel(
      idContacto: widget
          .contactoAEditar
          ?.idContacto, // Mantenemos el ID si estamos editando
      nombreContacto: _nombreCtrl.text.trim(),
      numeroContacto: _numeroCtrl.text.trim().isEmpty
          ? null
          : _numeroCtrl.text.trim(),
      correoContacto: _correoCtrl.text.trim().isEmpty
          ? null
          : _correoCtrl.text.trim(),
    );

    // 2. Clonamos la lista actual de contactos del proveedor
    List<ContactoProveedorModel> listaActualizada = List.from(
      widget.proveedorOriginal.contactos,
    );

    // 3. Agregamos o reemplazamos el contacto en la lista
    if (widget.contactoAEditar != null && widget.indexContacto != null) {
      // Estamos editando
      listaActualizada[widget.indexContacto!] = nuevoContacto;
    } else {
      // Es un contacto nuevo
      listaActualizada.add(nuevoContacto);
    }

    // 4. Creamos una copia del proveedor con la nueva lista de contactos
    final proveedorActualizado = ProveedorModel(
      idProveedor: widget.proveedorOriginal.idProveedor,
      nombreProveedor: widget.proveedorOriginal.nombreProveedor,
      contactos: listaActualizada,
    );

    // 5. Enviamos todo al backend usando la función que ya existía
    final provider = context.read<ProveedorProvider>();
    final exito = await provider.guardarProveedor(proveedorActualizado);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (exito) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.contactoAEditar == null
                ? '✅ Contacto agregado con éxito'
                : '✅ Contacto actualizado',
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
    final isEditing = widget.contactoAEditar != null;

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
                isEditing ? Icons.edit_outlined : Icons.person_add_alt_1,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isEditing ? "Editar Contacto" : "Nuevo Contacto",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: isDesktop ? 22 : 18,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: isDesktop ? 450 : double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contacto para: ${widget.proveedorOriginal.nombreProveedor}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _nombreCtrl,
                    'Nombre del Contacto *',
                    Icons.person_outline,
                    validator: _validarRequerido,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _numeroCtrl,
                    'Teléfono / Celular',
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _correoCtrl,
                    'Correo Electrónico',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validarEmailOpcional,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        isDense: true,
      ),
    );
  }
}
