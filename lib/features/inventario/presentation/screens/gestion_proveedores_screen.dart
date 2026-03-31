import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/inventario/presentation/screens/proveedores_details_screen.dart';
import '../../data/models/proveedor_model.dart';
import '../providers/proveedor_provider.dart';
import '../widgets/proveedor_dialog.dart';

class GestionProveedoresScreen extends StatefulWidget {
  const GestionProveedoresScreen({super.key});

  @override
  State<GestionProveedoresScreen> createState() =>
      _GestionProveedoresScreenState();
}

class _GestionProveedoresScreenState extends State<GestionProveedoresScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorProvider>().cargarProveedores();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProveedorProvider>();
    final proveedoresFiltrados = provider.proveedores;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: isDesktop
              ? const Color(0xFFF4F6F8)
              : const Color(0xFFF8F9FA),

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Gestión de Proveedores',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '${proveedoresFiltrados.length} proveedores registrados',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Recargar lista',
                      onPressed: provider.cargarProveedores,
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión de Proveedores',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${proveedoresFiltrados.length} encontrados',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
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
                ),

          // --- BOTÓN FLOTANTE ---
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.domain_add),
            label: isDesktop
                ? const Text(
                    "NUEVO PROVEEDOR",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text("NUEVO"),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const ProveedorDialog(),
              );
            },
          ),

          // --- CUERPO ---
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ),
              child: Column(
                children: [
                  // --- BARRA DE BÚSQUEDA ---
                  _buildSearchBar(isDesktop),

                  // --- LISTA DE PROVEEDORES ---
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : proveedoresFiltrados.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: provider.cargarProveedores,
                            child: isDesktop
                                // --- GRILLA PARA ESCRITORIO (3 POR FILA, MÁS GRANDES) ---
                                ? GridView.builder(
                                    padding: const EdgeInsets.all(32),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio:
                                              3.5, // Ajustado para ser más alargado
                                          crossAxisSpacing: 24,
                                          mainAxisSpacing: 24,
                                        ),
                                    itemCount: proveedoresFiltrados.length,
                                    itemBuilder: (context, index) =>
                                        _buildProveedorCard(
                                          proveedoresFiltrados[index],
                                          isDesktop: true,
                                        ),
                                  )
                                // --- LISTA PARA MÓVIL ---
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      80,
                                    ),
                                    itemCount: proveedoresFiltrados.length,
                                    separatorBuilder: (c, i) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) =>
                                        _buildProveedorCard(
                                          proveedoresFiltrados[index],
                                          isDesktop: false,
                                        ),
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(bool isDesktop) {
    return Container(
      width: double.infinity,
      margin: isDesktop
          ? const EdgeInsets.only(bottom: 16)
          : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDesktop
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : BorderRadius.circular(16),
        border: isDesktop
            ? Border(bottom: BorderSide(color: Colors.grey.shade300))
            : Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: isDesktop
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 16 : 8,
        horizontal: isDesktop ? 32 : 16,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: "Buscar por nombre de empresa o contacto...",
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (val) =>
                  context.read<ProveedorProvider>().buscarProveedor(val),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
              onPressed: () {
                _searchCtrl.clear();
                context.read<ProveedorProvider>().buscarProveedor('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProveedorCard(
    ProveedorModel proveedor, {
    required bool isDesktop,
  }) {
    return Card(
      color: Colors.white,
      elevation: isDesktop ? 2 : 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProveedorDetailsScreen(proveedor: proveedor),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 28 : 20,
            vertical: isDesktop
                ? 20
                : 16, // Padding vertical un poco más ajustado
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: isDesktop
                    ? 28
                    : 24, // Avatar un pelín más pequeño en desktop
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  proveedor.nombreProveedor.isNotEmpty
                      ? proveedor.nombreProveedor[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 22 : 20,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      proveedor.nombreProveedor,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 18 : 17,
                        color: Colors.black87,
                      ),
                      maxLines: isDesktop ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 👇 Aquí quitamos los textos de contacto viejos, queda 100% limpio
                  ],
                ),
              ),
              // ÍCONO DE FLECHA PARA INDICAR QUE ES TOCABLE Y LLEVA AL DETALLE
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No se encontraron proveedores",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
