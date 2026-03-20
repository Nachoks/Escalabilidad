import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/inventario_provider.dart';

class AddProductoDialog extends StatefulWidget {
  final String codigoEscaneado;

  const AddProductoDialog({Key? key, required this.codigoEscaneado})
    : super(key: key);

  @override
  State<AddProductoDialog> createState() => _AddProductoDialogState();
}

class _AddProductoDialogState extends State<AddProductoDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  int? _idProveedorSeleccionado;

  @override
  void initState() {
    super.initState();
    // Apenas se abre el modal, mandamos a pedir los proveedores a Laravel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventarioProvider>(
        context,
        listen: false,
      ).cargarProveedores();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    super.dispose();
  }

  void _guardarProducto() async {
    if (_formKey.currentState!.validate() && _idProveedorSeleccionado != null) {
      final provider = Provider.of<InventarioProvider>(context, listen: false);

      final exito = await provider.crearProductoRapido({
        'codigo_producto': widget.codigoEscaneado,
        'nombre_producto': _nombreController.text.trim(),
        'marca': _marcaController.text.trim(),
        'id_proveedor': _idProveedorSeleccionado,
      });

      if (exito && mounted) {
        Navigator.pop(context, true); // Devuelve "true" si se creó con éxito
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Error al crear'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_idProveedorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un proveedor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventarioProvider>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.new_releases, color: AppColors.primary),
          SizedBox(width: 10),
          Text(
            'Producto Nuevo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'El código escaneado no existe en el catálogo. Regístrelo rápidamente para continuar.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 15),

              // Código (Bloqueado porque ya lo escaneamos)
              TextFormField(
                initialValue: widget.codigoEscaneado,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Código de Artículo',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black12,
                ),
              ),
              const SizedBox(height: 15),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre / Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              // Marca
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              // Dropdown Proveedores
              provider.isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Proveedor',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.proveedores.map((prov) {
                        return DropdownMenuItem(
                          value: prov.idProveedor,
                          child: Text(prov.nombreProveedor),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _idProveedorSeleccionado = val),
                    ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, false), // Cierra sin hacer nada
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: provider.isLoading ? null : _guardarProducto,
          child: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Guardar y Continuar'),
        ),
      ],
    );
  }
}
