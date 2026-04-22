import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/regla_escaneo_provider.dart';
import 'package:somnolence_app/features/inventario/data/models/regla_escaneo_model.dart';

class ConfiguracionEscanerScreen extends StatefulWidget {
  const ConfiguracionEscanerScreen({super.key});

  @override
  State<ConfiguracionEscanerScreen> createState() =>
      _ConfiguracionEscanerScreenState();
}

class _ConfiguracionEscanerScreenState
    extends State<ConfiguracionEscanerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReglaEscaneoProvider>().cargarReglas();
    });
  }

  void _mostrarDialogoNuevaRegla() {
    final formKey = GlobalKey<FormState>();
    final marcaCtrl = TextEditingController();
    final prefijoCodCtrl = TextEditingController();
    final prefijoSerCtrl = TextEditingController();
    final separadorCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text(
                    "Nueva Regla de Escaneo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Define cómo debe leer el escáner las etiquetas de esta marca en específico.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: marcaCtrl,
                          validator: (v) => v!.isEmpty ? "Requerido" : null,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la Marca (Ej: 3M, Bosch)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: prefijoCodCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Prefijo del Código (Ej: 240, 93, PN)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: prefijoSerCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Prefijo de Serie (Ej: 21, 91, SN)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pin),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: separadorCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Separador a ignorar (Opcional, Ej: 92)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.horizontal_rule),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setStateDialog(() => isSaving = true);
                            final provider = context
                                .read<ReglaEscaneoProvider>();

                            bool exito = await provider.crearRegla({
                              'nombre_marca': marcaCtrl.text.trim(),
                              'prefijo_codigo': prefijoCodCtrl.text.trim(),
                              'prefijo_serie': prefijoSerCtrl.text.trim(),
                              'separador_ignorar': separadorCtrl.text.trim(),
                            });

                            setStateDialog(() => isSaving = false);

                            if (exito && context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Regla guardada'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.errorMessage ?? 'Error',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Guardar Regla"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminacion(ReglaEscaneoModel regla) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Regla"),
        content: Text(
          "¿Estás seguro de eliminar la regla para la marca '${regla.nombreMarca}'? El escáner dejará de reconocerla de inmediato.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              bool exito = await context
                  .read<ReglaEscaneoProvider>()
                  .eliminarRegla(regla.idRegla);
              if (exito && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ Regla eliminada'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReglaEscaneoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Configuración del Escáner"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoNuevaRegla,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nueva Regla",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: provider.isLoading && provider.reglas.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : provider.reglas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.reglas.length,
              itemBuilder: (context, index) {
                final regla = provider.reglas[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.precision_manufacturing,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      regla.nombreMarca,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Código: ${regla.prefijoCodigo.isEmpty ? 'N/A' : regla.prefijoCodigo}",
                          ),
                          Text(
                            "Serie: ${regla.prefijoSerie.isEmpty ? 'N/A' : regla.prefijoSerie}",
                          ),
                          if (regla.separadorIgnorar.isNotEmpty)
                            Text(
                              "Ignora: ${regla.separadorIgnorar}",
                              style: const TextStyle(color: Colors.orange),
                            ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmarEliminacion(regla),
                      tooltip: 'Eliminar Regla',
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rule_folder, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay reglas configuradas.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una regla para que el escáner sepa cómo leer las cajas.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
