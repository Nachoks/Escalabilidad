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

class _ListaClientesContent extends StatefulWidget {
  const _ListaClientesContent();

  @override
  State<_ListaClientesContent> createState() => _ListaClientesContentState();
}

class _ListaClientesContentState extends State<_ListaClientesContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final allClientes = provider.clientes;

    final filteredClientes = _searchQuery.isEmpty
        ? allClientes
        : allClientes.where((cliente) {
            final nombre = cliente.nombreCliente.toLowerCase();
            final query = _searchQuery.toLowerCase();
            return nombre.contains(query) ||
                (cliente.codCliente?.toLowerCase().contains(query) ?? false);
          }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : AppColors.background,

          // --- APPBAR ADAPTATIVO ---
          appBar: isDesktop
              ? AppBar(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  toolbarHeight: 70,
                  title: Row(
                    children: [
                      const Image(
                        image: AssetImage('assets/images/isotipo.png'),
                        width: 45,
                        height: 45,
                      ),
                      const SizedBox(width: 16),
                      // En web, el buscador se ve como una barra de búsqueda moderna al centro, o el título si no busca
                      Expanded(
                        child: _isSearching
                            ? Container(
                                height: 40,
                                margin: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar cliente...',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _searchQuery = v),
                                ),
                              )
                            : const Text(
                                "Gestión de Clientes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    if (_isSearching)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _isSearching = false;
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Buscar',
                        onPressed: () => setState(() => _isSearching = true),
                      ),

                    if (!_isSearching)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Recargar',
                        onPressed: provider.cargarClientes,
                      ),
                    const SizedBox(width: 16),
                  ],
                )
              : AppBar(
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
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gestión de Clientes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
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
                    if (_isSearching)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _isSearching = false;
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Buscar cliente',
                        onPressed: () => setState(() => _isSearching = true),
                      ),
                    if (!_isSearching)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Recargar lista',
                        onPressed: provider.cargarClientes,
                      ),
                  ],
                ),

          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_business_rounded),
            label: isDesktop
                ? const Text(
                    "NUEVO CLIENTE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text("NUEVO"),
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
              ? _buildEmptyState(_searchQuery.isNotEmpty)
              : RefreshIndicator(
                  onRefresh: provider.cargarClientes,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : double.infinity,
                      ), // Centrado en PC
                      child: isDesktop
                          // --- GRILLA PARA ESCRITORIO ---
                          ? GridView.builder(
                              padding: const EdgeInsets.all(32),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // 3 columnas en PC
                                    childAspectRatio:
                                        2.5, // Tarjetas horizontales
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                  ),
                              itemCount: filteredClientes.length,
                              itemBuilder: (context, index) =>
                                  _buildClienteCard(
                                    filteredClientes[index],
                                    context,
                                    isDesktop,
                                  ),
                            )
                          // --- LISTA PARA MÓVIL ---
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredClientes.length,
                              separatorBuilder: (c, i) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) =>
                                  _buildClienteCard(
                                    filteredClientes[index],
                                    context,
                                    isDesktop,
                                  ),
                            ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  // --- TARJETA DE CLIENTE ADAPTATIVA ---
  Widget _buildClienteCard(
    dynamic cliente,
    BuildContext context,
    bool isDesktop,
  ) {
    return Card(
      elevation: isDesktop ? 0 : 2, // Más plana en PC, con sombra sutil
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDesktop
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide.none,
      ),
      child: InkWell(
        // Hacemos toda la tarjeta clickeable
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClienteDetailScreen(cliente: cliente),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(
            isDesktop ? 20.0 : 8.0,
          ), // Más espaciosa en web
          child: Row(
            children: [
              CircleAvatar(
                radius: isDesktop ? 28 : 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  cliente.codCliente ?? "XX",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cliente.nombreCliente,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (cliente.nombreRepresentante != null)
                      Text(
                        "Rep: ${cliente.nombreRepresentante}",
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (cliente.correoRepresentante != null)
                      Text(
                        cliente.correoRepresentante!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ), // Flecha indicando que se puede entrar
            ],
          ),
        ),
      ),
    );
  }

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
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
