import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
// 1. IMPORTANTE: Importamos la pantalla de detalle
import 'package:somnolence_app/features/rendiciones/presentation/screens/rendicion_detail_screen.dart';

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  // --- VARIABLES DE FILTRO ---
  String _filtroEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RendicionesProvider>().cargarHistorialGlobal();
    });
  }

  // --- LÓGICA DE COLORES SEMÁFORO ---
  Color _getColorByEstado(String estado) {
    switch (estado) {
      case 'Pagada':
        return Colors.green.shade100;
      case 'Aprobada':
        return Colors.purple.shade100;
      case 'Observada':
        return Colors.red.shade100;
      case 'Pendiente de Validación':
        return Colors.blue.shade100;
      case 'Borrador':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();
    final historial = provider.historialGlobal;

    // --- APLICAR FILTROS ---
    final historialFiltrado = historial.where((rendicion) {
      if (_filtroEstado != 'Todos' && rendicion.estado != _filtroEstado) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Historial de Rendiciones"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- BARRA DE FILTROS ---
          _buildFilterBar(),

          // --- LISTA DE RENDICIONES ---
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : historial.isEmpty
                ? _buildEmptyStateOriginal()
                : historialFiltrado.isEmpty
                ? _buildEmptyStateFiltros()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: historialFiltrado.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = historialFiltrado[index];

                      final String idVisual =
                          "#${(item.idRendicion ?? 0).toString().padLeft(3, '0')}";
                      final String nombreUsuario = item.nombreUsuario;
                      final colorFondo = _getColorByEstado(item.estado);

                      return Card(
                        elevation: 2,
                        color: colorFondo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          // 2. AQUÍ ESTÁ LA MAGIA: Navegación "Solo Lectura"
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RendicionDetailScreen(
                                  rendicion: item,
                                  soloLectura:
                                      true, // <--- ESTO BLOQUEA LA EDICIÓN
                                ),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.6),
                            child: Text(
                              idVisual,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            item.proposito,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      nombreUsuario,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Estado: ${item.estado} • ${item.fecha}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            _formatMoney(item.totalGastado),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Helpers y Widgets Auxiliares ---

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filtrar por Estado:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChoiceChip(
                  label: 'Todos',
                  selected: _filtroEstado == 'Todos',
                  onSelected: (val) => setState(() => _filtroEstado = 'Todos'),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Borrador',
                  selected: _filtroEstado == 'Borrador',
                  color: Colors.orange.shade200,
                  onSelected: (val) => setState(
                    () => _filtroEstado = val ? 'Borrador' : 'Todos',
                  ),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Pendiente',
                  selected: _filtroEstado == 'Pendiente de Validación',
                  color: Colors.blue.shade200,
                  onSelected: (val) => setState(
                    () => _filtroEstado = val
                        ? 'Pendiente de Validación'
                        : 'Todos',
                  ),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Observada',
                  selected: _filtroEstado == 'Observada',
                  color: Colors.red.shade200,
                  onSelected: (val) => setState(
                    () => _filtroEstado = val ? 'Observada' : 'Todos',
                  ),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Aprobada',
                  selected: _filtroEstado == 'Aprobada',
                  color: Colors.purple.shade200,
                  onSelected: (val) => setState(
                    () => _filtroEstado = val ? 'Aprobada' : 'Todos',
                  ),
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: 'Pagada',
                  selected: _filtroEstado == 'Pagada',
                  color: Colors.green.shade200,
                  onSelected: (val) =>
                      setState(() => _filtroEstado = val ? 'Pagada' : 'Todos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black87 : Colors.black54,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: color?.withOpacity(0.3) ?? Colors.grey[100],
      selectedColor: color ?? AppColors.primary.withOpacity(0.2),
      checkmarkColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? (color ?? AppColors.primary) : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildEmptyStateOriginal() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay rendiciones registradas",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateFiltros() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay rendiciones con este estado",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          TextButton(
            onPressed: () => setState(() => _filtroEstado = 'Todos'),
            child: const Text("Limpiar filtros"),
          ),
        ],
      ),
    );
  }
}
