import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';

class AddClienteDialog extends StatefulWidget {
  const AddClienteDialog({super.key});

  @override
  State<AddClienteDialog> createState() => _AddClienteDialogState();
}

class _AddClienteDialogState extends State<AddClienteDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _representanteCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _representanteCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Cliente'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre del Cliente
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre Empresa/Cliente',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              // Representante (Opcional)
              TextFormField(
                controller: _representanteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre Representante',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // Correo (Opcional pero validado si se ingresa)
              TextFormField(
                controller: _correoCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Contacto',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(v)) return 'Correo inválido';
                  }
                  return null;
                },
              ),
            ],
          ),
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
          onPressed: _isSaving ? null : _guardarCliente,
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

  Future<void> _guardarCliente() async {
    // Estado de carga visual inmediato
    setState(() => _isSaving = true);

    try {
      // 1. AHORA LA VALIDACIÓN ESTÁ PROTEGIDA
      if (!_formKey.currentState!.validate()) {
        setState(() => _isSaving = false);
        return;
      }

      // --- LÓGICA DE "NO DEFINIDO" ---
      // Obtenemos los textos limpios
      String nombreRep = _representanteCtrl.text.trim();
      String correoRep = _correoCtrl.text.trim();

      // Si están vacíos, asignamos "No definido"
      if (nombreRep.isEmpty) {
        nombreRep = 'No definido';
      }
      if (correoRep.isEmpty) {
        correoRep = 'nodefinido@no.cl';
      }
      // -------------------------------

      final nuevoCliente = ClienteModel(
        nombreCliente: _nombreCtrl.text.trim(),
        codCliente: _codigoCtrl.text
            .trim(), // Esto el backend lo ignorará/sobrescribirá con el autoincremental
        nombreRepresentante:
            nombreRep, // Usamos la variable con la lógica aplicada
        correoRepresentante:
            correoRep, // Usamos la variable con la lógica aplicada
      );

      final provider = context.read<ClienteProvider>();
      final exito = await provider.crearCliente(nuevoCliente);

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cliente creado'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(provider.error ?? "Error del servidor");
      }
    } catch (e) {
      print("ERROR CAPTURADO: $e");

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
