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
    return const _ListaClientesContent();
  }
}

// 1. Convertimos a StatefulWidget para manejar el texto del buscador
class _ListaClientesContent extends StatefulWidget {
  const _ListaClientesContent();

  @override
  State<_ListaClientesContent> createState() => _ListaClientesContentState();
}

class _ListaClientesContentState extends State<_ListaClientesContent> {
  // Controlador y variable para el buscador
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false; // Para alternar entre título y buscador

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final allClientes = provider.clientes;

    // 2. Lógica de filtrado: Si hay texto, filtramos; si no, mostramos todos
    final filteredClientes = _searchQuery.isEmpty
        ? allClientes
        : allClientes.where((cliente) {
            final nombre = cliente.nombreCliente.toLowerCase();
            final query = _searchQuery.toLowerCase();
            // Puedes agregar más condiciones aquí (ej: buscar por código también)
            return nombre.contains(query) ||
                (cliente.codCliente?.toLowerCase().contains(query) ?? false);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        // 3. Título dinámico: Texto o Campo de búsqueda
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Clientes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    // Mostramos la cantidad filtrada vs total
                    _searchQuery.isEmpty
                        ? '${allClientes.length} registrados'
                        : '${filteredClientes.length} encontrados',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
        actions: [
          // 4. Botón de Lupa / Cerrar búsqueda
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Buscar cliente',
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),

          // Botón de refrescar (solo si no estamos buscando para no saturar)
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar lista',
              onPressed: () {
                context.read<ClienteProvider>().cargarClientes();
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_business_rounded),
        onPressed: () {
          final providerActual = context.read<ClienteProvider>();
          showDialog(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: providerActual,
              child: const AddClienteDialog(),
            ),
          );
        },
      ),
      body: provider.isLoading && allClientes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : filteredClientes.isEmpty
          ? _buildEmptyState(
              _searchQuery.isNotEmpty,
            ) // Pasamos si es búsqueda vacía
          : RefreshIndicator(
              onRefresh: provider.cargarClientes,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredClientes.length, // Usamos la lista filtrada
                separatorBuilder: (c, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final cliente =
                      filteredClientes[index]; // Usamos la lista filtrada
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

  // Modifiqué un poco el Empty State para diferenciar si no hay datos o si no hay resultados de búsqueda
  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.business_outlined,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? "No se encontraron clientes con ese nombre"
                : "No hay clientes registrados",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
