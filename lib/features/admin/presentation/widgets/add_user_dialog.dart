import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/utils/roles_helper.dart';
import 'package:somnolence_app/features/admin/data/models/empresa_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/admin_users_provider.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  // Clave para validaciones
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _nombrePersonalCtrl = TextEditingController();
  final TextEditingController _apellidoPersonalCtrl = TextEditingController();
  final TextEditingController _rutCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  // Variables de Estado
  int? _selectedEmpresaId;
  List<Empresa> _empresasDisponibles = [];
  bool _isLoadingEmpresas = true;
  bool _obscurePassword = true;
  bool _isSaving = false; // Para bloquear el botón mientras guarda

  // --- ROLES ACTUALIZADOS ---
  final List<String> _rolesDisponibles = [
    'Administrador',
    'Conductor',
    'Validador',
    'Validador HT', // <--- NUEVO ROL
    'Usuario', // <--- RENDIDOR CAMBIADO A USUARIO
  ];
  final Set<String> _rolesSeleccionados = {};

  @override
  void initState() {
    super.initState();
    _cargarEmpresas();
  }

  Future<void> _cargarEmpresas() async {
    final provider = Provider.of<AdminUsersProvider>(context, listen: false);
    final listaTraida = await provider.getEmpresasDisponibles();
    if (!mounted) return;
    setState(() {
      _empresasDisponibles = listaTraida;
      _isLoadingEmpresas = false;
    });
  }

  @override
  void dispose() {
    _nombrePersonalCtrl.dispose();
    _apellidoPersonalCtrl.dispose();
    _rutCtrl.dispose();
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // --- VALIDACIONES ---
  String? _validarRequerido(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _guardarUsuario() async {
    // 1. Validaciones
    if (!_formKey.currentState!.validate()) return;

    if (_rolesSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione al menos un rol")),
      );
      return;
    }

    setState(() => _isSaving = true); // Bloqueo visual

    final datosFormulario = {
      'personal': {
        'nombre': _nombrePersonalCtrl.text.trim(),
        'apellido': _apellidoPersonalCtrl.text.trim(),
        'rut': _rutCtrl.text.trim(),
        'correo': _emailCtrl.text.trim(),
        'id_empresa': _selectedEmpresaId,
      },
      'usuario': {
        'username': _usuarioCtrl.text.trim(),
        'password': _passwordCtrl.text,
      },
      'roles': _rolesSeleccionados.toList(),
    };

    final provider = Provider.of<AdminUsersProvider>(context, listen: false);

    // 2. Llamada al Provider
    final exito = await provider.crearUsuario(datosFormulario);

    if (!mounted) return;

    setState(() => _isSaving = false); // Desbloqueo

    if (exito) {
      Navigator.of(context).pop(); // Cerramos solo si hubo éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Usuario creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // ❌ Error Específico: Mostramos lo que respondió el backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? "Error desconocido"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
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
              const Icon(Icons.person_add, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "Nuevo Usuario",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: isDesktop ? 22 : 18,
                ),
              ),
            ],
          ),
          content: SizedBox(
            // --- CONTROL DE ANCHO PARA WEB ---
            width: isDesktop ? 500 : double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- DATOS PERSONALES ---
                    _buildSectionTitle("Datos Personales"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _nombrePersonalCtrl,
                            'Nombre',
                            Icons.person,
                            validator: _validarRequerido,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            _apellidoPersonalCtrl,
                            'Apellido',
                            Icons.person_outline,
                            validator: _validarRequerido,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _rutCtrl,
                      'RUT',
                      Icons.badge,
                      validator: _validarRequerido,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _emailCtrl,
                      'Correo',
                      Icons.email_outlined,
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 12),

                    // --- DROPDOWN EMPRESA ---
                    _isLoadingEmpresas
                        ? const Center(child: LinearProgressIndicator())
                        : DropdownButtonFormField<int>(
                            value: _selectedEmpresaId,
                            decoration: InputDecoration(
                              labelText: 'Empresa',
                              prefixIcon: const Icon(Icons.business, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            items: _empresasDisponibles.map((empresa) {
                              return DropdownMenuItem<int>(
                                value: empresa.id,
                                child: Text(
                                  empresa.nombre,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedEmpresaId = newValue;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Seleccione una empresa' : null,
                          ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),

                    // --- CUENTA DE USUARIO ---
                    _buildSectionTitle("Cuenta de Usuario"),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _usuarioCtrl,
                      'Nombre de Usuario',
                      Icons.account_circle,
                      validator: _validarRequerido,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      validator: _validarPassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),

                    // --- ROLES ---
                    _buildSectionTitle("Asignar Roles"),
                    const SizedBox(height: 8),
                    if (_rolesSeleccionados.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "⚠️ Selecciona al menos un rol",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: _rolesDisponibles.map((rol) {
                          final isSelected = _rolesSeleccionados.contains(rol);
                          return CheckboxListTile(
                            title: Text(
                              rol,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            value: isSelected,
                            activeColor: AppColors.primary,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            secondary: Icon(
                              RoleHelper.getIconForRole(rol),
                              color: RoleHelper.getColorForRole(rol),
                              size: 20,
                            ),
                            onChanged: (bool? valor) {
                              setState(() {
                                if (valor == true) {
                                  _rolesSeleccionados.add(rol);
                                } else {
                                  _rolesSeleccionados.remove(rol);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
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
              onPressed: _isSaving ? null : _guardarUsuario,
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
                      "Guardar Usuario",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Bordes redondeados modernos
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ), // Más espacio para respirar
        isDense: true,
      ),
    );
  }
}
