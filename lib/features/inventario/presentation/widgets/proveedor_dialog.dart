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
  late TextEditingController _contactoCtrl; // <--- NUEVO CONTROLADOR
  late TextEditingController _numeroCtrl;
  late TextEditingController _correoCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(
      text: widget.proveedor?.nombreProveedor ?? '',
    );
    _contactoCtrl = TextEditingController(
      // <--- INICIALIZAR
      text: widget.proveedor?.nombreContacto ?? '',
    );
    _numeroCtrl = TextEditingController(
      text: widget.proveedor?.numeroContacto ?? '',
    );
    _correoCtrl = TextEditingController(
      text: widget.proveedor?.correoContacto ?? '',
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _contactoCtrl.dispose(); // <--- LIMPIAR
    _numeroCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    return null;
  }

  String? _validarEmailOpcional(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Es opcional
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Como tu idProveedor no es anulable, le pasamos 0 si es nuevo
    final nuevoProv = ProveedorModel(
      idProveedor: widget.proveedor?.idProveedor ?? 0,
      nombreProveedor: _nombreCtrl.text.trim(),
      nombreContacto: _contactoCtrl.text.trim(), // <--- ASIGNAR NUEVO DATO
      numeroContacto: _numeroCtrl.text.trim(),
      correoContacto: _correoCtrl.text.trim(),
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
                ? '✅ Proveedor creado'
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
                isEditing ? "Editar Proveedor" : "Nuevo Proveedor",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: isDesktop ? 22 : 18,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: isDesktop ? 500 : double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Datos Comerciales",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _nombreCtrl,
                      'Razón Social / Nombre *',
                      Icons.business,
                      validator: _validarRequerido,
                    ),
                    const SizedBox(height: 12),

                    // 👇 NUEVO CAMPO EN LA INTERFAZ 👇
                    _buildTextField(
                      _contactoCtrl,
                      'Nombre del Contacto',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 12),

                    // 👆 FIN DEL NUEVO CAMPO 👆
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _numeroCtrl,
                            'Teléfono de Contacto',
                            Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }
}
