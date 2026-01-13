import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/admin/presentation/providers/cliente_provider.dart';
import 'package:somnolence_app/features/admin/presentation/screens/cliente_details_screen.dart';
import 'package:somnolence_app/features/admin/presentation/widgets/add_cliente_dialog.dart';

class GestionClientesScreen extends StatelessWidget {
  const GestionClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el provider y cargamos los datos al inicio
    return ChangeNotifierProvider(
      create: (_) => ClienteProvider()..cargarClientes(),
      child: const _ListaClientesContent(),
    );
  }
}

class _ListaClientesContent extends StatelessWidget {
  const _ListaClientesContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final clientes = provider.clientes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Clientes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${clientes.length} registrados',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // Botón Flotante para Agregar
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_business_rounded),
        onPressed: () {
          final providerActual = context.read<ClienteProvider>();
          showDialog(
            context: context,
            // Pasamos el provider existente al diálogo
            builder: (_) => ChangeNotifierProvider.value(
              value: providerActual,
              child: const AddClienteDialog(),
            ),
          );
        },
      ),

      body: provider.isLoading && clientes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : clientes.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: provider.cargarClientes,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: clientes.length,
                separatorBuilder: (c, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final cliente = clientes[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          cliente.codCliente ?? "XX",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      title: Text(
                        cliente.nombreCliente,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cliente.nombreRepresentante != null)
                            Text(
                              "Rep: ${cliente.nombreRepresentante}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          if (cliente.correoRepresentante != null)
                            Text(
                              cliente.correoRepresentante!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.edit,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ClienteDetailScreen(cliente: cliente),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay clientes registrados",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
