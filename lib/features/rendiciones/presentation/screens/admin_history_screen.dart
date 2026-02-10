import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Importante para fechas
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/rendicion_detail_screen.dart';

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  // --- VARIABLES DE FILTRO ---
  String _filtroEstado = 'Todos';
  DateTimeRange? _rangoFechas; // Nuevo filtro de fecha

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recargarDatos();
    });
  }

  Future<void> _recargarDatos() async {
    await context.read<RendicionesProvider>().cargarHistorialGlobal();
  }

  // --- LÓGICA DE FILTROS DE FECHA ---
  void _filtrarHoy() {
    final now = DateTime.now();
    setState(() => _rangoFechas = DateTimeRange(start: now, end: now));
  }

  void _filtrarEsteMes() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    setState(() => _rangoFechas = DateTimeRange(start: start, end: end));
  }

  void _filtrarEsteAnio() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    setState(() => _rangoFechas = DateTimeRange(start: start, end: end));
  }

  void _limpiarFiltroFecha() {
    setState(() => _rangoFechas = null);
  }

  Future<void> _seleccionarRangoPersonalizado() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: null, // Limpio para evitar errores
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _rangoFechas = picked);
    }
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

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  String _formatearFecha(String fechaString) {
    if (fechaString.isEmpty) return "";
    try {
      final DateTime fecha = DateTime.parse(fechaString);
      return DateFormat('dd-MM-yyyy').format(fecha);
    } catch (e) {
      return fechaString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();
    final historial = provider.historialGlobal;

    // --- APLICAR TODOS LOS FILTROS (ESTADO + FECHA) ---
    final historialFiltrado = historial.where((rendicion) {
      // 1. Filtro por Estado
      if (_filtroEstado != 'Todos' && rendicion.estado != _filtroEstado) {
        return false;
      }

      // 2. Filtro por Fecha
      if (_rangoFechas != null) {
        if (rendicion.fecha.isEmpty) return false;
        try {
          final fechaRendicion = DateTime.parse(rendicion.fecha);
          final start = _rangoFechas!.start.copyWith(
            hour: 0,
            minute: 0,
            second: 0,
          );
          final end = _rangoFechas!.end.copyWith(
            hour: 23,
            minute: 59,
            second: 59,
          );

          if (fechaRendicion.isBefore(start) || fechaRendicion.isAfter(end)) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Historial de Rendiciones",
          style: TextStyle(fontWeight: FontWeight.bold),
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
        actions: [
          // BOTÓN DE FILTRO FECHA (NUEVO)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.calendar_month,
              color: _rangoFechas != null ? Colors.amberAccent : Colors.white,
            ),
            tooltip: "Filtrar por fecha",
            onSelected: (value) {
              if (value == 'hoy') _filtrarHoy();
              if (value == 'mes') _filtrarEsteMes();
              if (value == 'año') _filtrarEsteAnio();
              if (value == 'custom') _seleccionarRangoPersonalizado();
              if (value == 'limpiar') _limpiarFiltroFecha();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(value: 'hoy', child: Text('📅 Hoy')),
              const PopupMenuItem(value: 'mes', child: Text('📆 Este Mes')),
              const PopupMenuItem(value: 'año', child: Text('🗓️ Este Año')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'custom',
                child: Text('🛠️ Rango Personalizado'),
              ),
              if (_rangoFechas != null) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'limpiar',
                  child: Text(
                    '❌ Quitar Filtro',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Recargar historial",
            onPressed: provider.isLoading ? null : _recargarDatos,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- BARRA DE FILTROS DE ESTADO ---
          _buildFilterBar(),

          // --- INDICADOR FILTRO FECHA ACTIVO (NUEVO) ---
          if (_rangoFechas != null)
            Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Fecha: ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.end)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _limpiarFiltroFecha,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          // --- LISTA DE RENDICIONES ---
          Expanded(
            child: RefreshIndicator(
              onRefresh: _recargarDatos,
              color: AppColors.primary,
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : historial.isEmpty
                  ? _buildEmptyStateOriginal()
                  : historialFiltrado.isEmpty
                  ? _buildEmptyStateFiltros()
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RendicionDetailScreen(
                                    rendicion: item,
                                    soloLectura: true,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                                  "Estado: ${item.estado} • ${_formatearFecha(item.fecha)}",
                                  style: const TextStyle(
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
          ),
        ],
      ),
    );
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "No hay rendiciones registradas",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _recargarDatos,
                icon: const Icon(Icons.refresh),
                label: const Text("Recargar datos"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateFiltros() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_list_off, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "No hay resultados con estos filtros",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filtroEstado = 'Todos';
                    _rangoFechas = null;
                  });
                },
                child: const Text("Limpiar todos los filtros"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
