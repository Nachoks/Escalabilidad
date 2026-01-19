import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/rendicion_detail_screen.dart';

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RendicionesProvider>().cargarHistorialGlobal();
    });
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'Pagada':
        return Colors.green;
      case 'Aprobada':
        return Colors.purple;
      case 'Observada':
        return Colors.red;
      case 'Pendiente de Validación':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();
    final historial = provider.historialGlobal;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial Global"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda futura
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: historial.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = historial[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorEstado(
                      item.estado,
                    ).withOpacity(0.1),
                    child: Icon(
                      Icons.history,
                      color: _getColorEstado(item.estado),
                    ),
                  ),
                  title: Text(
                    item.proposito,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${item.fecha} • ${item.estado}"),
                  trailing: Text(
                    "\$${item.totalGastado}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () {
                    // Navegar al detalle en modo Solo Lectura
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RendicionDetailScreen(rendicion: item),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
