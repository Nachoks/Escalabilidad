import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';

class EditClienteDialog extends StatefulWidget {
  final ClienteModel cliente;

  const EditClienteDialog({super.key, required this.cliente});

  @override
  State<EditClienteDialog> createState() => _EditClienteDialogState();
}

class _EditClienteDialogState extends State<EditClienteDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codClienteController;
  late TextEditingController _nombreClienteController;
  late TextEditingController _nombreRepController;
  late TextEditingController _correoRepController;

  @override
  void initState() {
    super.initState();
    _codClienteController = TextEditingController(
      text: widget.cliente.codCliente,
    );
    _nombreClienteController = TextEditingController(
      text: widget.cliente.nombreCliente,
    );
    _nombreRepController = TextEditingController(
      text: widget.cliente.nombreRepresentante,
    );
    _correoRepController = TextEditingController(
      text: widget.cliente.correoRepresentante,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar Cliente"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. CÓDIGO CLIENTE (BLOQUEADO)
              TextFormField(
                controller: _codClienteController,
                enabled: false, // <--- ESTO LO HACE NO EDITABLE (Gris)
                decoration: const InputDecoration(
                  labelText: "Código Cliente (No editable)",
                  icon: Icon(
                    Icons.lock_outline,
                  ), // Icono de candado para reforzar
                  filled: true,
                  fillColor: Colors.black12, // Fondo gris suave
                ),
              ),
              const SizedBox(height: 15),

              // 2. Nombre Cliente
              TextFormField(
                controller: _nombreClienteController,
                decoration: const InputDecoration(
                  labelText: "Nombre Cliente",
                  icon: Icon(Icons.business),
                ),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 10),

              // 3. Representante
              TextFormField(
                controller: _nombreRepController,
                decoration: const InputDecoration(
                  labelText: "Nombre Representante",
                  icon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),

              // 4. Correo
              TextFormField(
                controller: _correoRepController,
                decoration: const InputDecoration(
                  labelText: "Correo Representante",
                  icon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Preparamos datos (SIN CODIGO)
              final data = {
                'nombre_cliente': _nombreClienteController.text,
                'nombre_representante': _nombreRepController.text,
                'correo_representante': _correoRepController.text,
              };

              // Llamamos al provider
              final success = await context
                  .read<ClienteProvider>()
                  .actualizarCliente(widget.cliente.idCliente!, data);

              if (success && mounted) {
                Navigator.pop(context); // Cierra popup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cliente actualizado"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error al actualizar"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text("Guardar Cambios"),
        ),
      ],
    );
  }
}
