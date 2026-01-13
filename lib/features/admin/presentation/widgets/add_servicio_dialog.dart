import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/admin/data/models/servicio_model.dart';
import 'package:somnolence_app/features/admin/data/models/area_model.dart'; // Asegúrate de crear este modelo
import 'package:somnolence_app/features/admin/presentation/providers/servicio_provider.dart';

class AddServicioDialog extends StatefulWidget {
  final ClienteModel cliente;

  const AddServicioDialog({super.key, required this.cliente});

  @override
  State<AddServicioDialog> createState() => _AddServicioDialogState();
}

class _AddServicioDialogState extends State<AddServicioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();

  // Variables para Dropdown de Área
  AreaModel? _areaSeleccionada;

  // Variables para Fechas (Opcional por ahora)
  // DateTime? _fechaInicio;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Cargar las áreas disponibles al abrir el diálogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicioProvider>().cargarAreas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicioProvider>();

    return AlertDialog(
      title: const Text('Nuevo Servicio'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Nombre del Servicio
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Servicio',
                  hintText: 'Ej: Mantención Cámaras',
                  prefixIcon: Icon(Icons.build_circle_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // 2. Dropdown de Áreas (Dinámico desde BD)
              DropdownButtonFormField<AreaModel>(
                decoration: const InputDecoration(
                  labelText: 'Área de la Empresa',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                value: _areaSeleccionada,
                items: provider.areas.map((area) {
                  return DropdownMenuItem(
                    value: area,
                    child: Text("${area.nombreArea} (Cód: ${area.codigoArea})"),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _areaSeleccionada = val);
                },
                validator: (v) => v == null ? 'Seleccione un área' : null,
              ),

              const SizedBox(height: 10),
              const Text(
                "El Centro de Costo se generará automáticamente: XX-Y-ZZZ",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _isSaving ? null : _guardar,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text("Guardar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final nuevoServicio = ServicioModel(
        nombreServicio: _nombreCtrl.text.trim(),
        idCliente: widget.cliente.idCliente!, // ID del cliente actual
        idArea: _areaSeleccionada!.idArea, // ID del área seleccionada
        // fechaInicio: ... si implementas fechas
      );

      final exito = await context.read<ServicioProvider>().crearServicio(
        nuevoServicio,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (exito) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Servicio creado y Centro de Costo generado'),
          ),
        );
      } else {
        final errorMsg = context.read<ServicioProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg ?? 'Error al guardar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() => _isSaving = false);
    }
  }
}
