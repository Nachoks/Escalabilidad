import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart'; // Asegúrate de tener este import
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/data/models/rendicion_model.dart';
// Importa tu pantalla de detalle (la reutilizaremos o haremos una nueva luego)
import 'package:somnolence_app/features/rendiciones/presentation/screens/rendicion_detail_screen.dart';

class ValidatorDashboardScreen extends StatefulWidget {
  const ValidatorDashboardScreen({super.key});

  @override
  State<ValidatorDashboardScreen> createState() =>
      _ValidatorDashboardScreenState();
}

class _ValidatorDashboardScreenState extends State<ValidatorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RendicionesProvider>().cargarBandejaValidacion();
    });
  }

  // Lógica para subir comprobante de pago
  Future<void> _subirPago(int idRendicion) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Subiendo comprobante...")));

      final exito = await context.read<RendicionesProvider>().pagarRendicion(
        idRendicion,
        result.files.single.path!,
      );

      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pago registrado exitosamente"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error al registrar pago"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();
    // Filtramos localmente las listas
    final porRevisar = provider.rendicionesPorValidar
        .where((r) => r.estado == 'Pendiente de Validación')
        .toList();
    final porPagar = provider.rendicionesPorValidar
        .where((r) => r.estado == 'Aprobada')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bandeja de Validación"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.assignment_ind),
              text: "Por Revisar (${porRevisar.length})",
            ),
            Tab(
              icon: const Icon(Icons.payment),
              text: "Por Pagar (${porPagar.length})",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLista(porRevisar, esPago: false),
          _buildLista(porPagar, esPago: true),
        ],
      ),
    );
  }

  Widget _buildLista(List<RendicionModel> lista, {required bool esPago}) {
    if (lista.isEmpty) {
      return Center(
        child: Text(
          "No hay tareas pendientes aquí 🎉",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final rendicion = lista[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              rendicion.proposito,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  "Usuario: ${rendicion.idUsuario}",
                ), // Idealmente mostrar nombre si el modelo lo trae
                Text("Monto: \$${rendicion.totalGastado}"),
                Text("Fecha: ${rendicion.fecha}"),
              ],
            ),
            trailing: esPago
                ? ElevatedButton.icon(
                    onPressed: () => _subirPago(rendicion.idRendicion!),
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Pagar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Si es validación, vamos al detalle para aprobar/rechazar gastos
              // Aquí deberías navegar a una pantalla de detalle ESPECÍFICA para validadores
              // O usar la misma 'RendicionDetailScreen' con un modo 'readOnly' o 'validationMode'
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RendicionDetailScreen(
                    rendicion: rendicion,
                  ), // Ajustar esta pantalla después
                ),
              );
            },
          ),
        );
      },
    );
  }
}
