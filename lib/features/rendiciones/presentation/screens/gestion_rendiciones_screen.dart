import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/rendiciones_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/providers/gasto_provider.dart';
import 'package:somnolence_app/features/rendiciones/presentation/widget/add_rendicion_dialog.dart';
import 'package:somnolence_app/features/rendiciones/presentation/screens/rendicion_detail_screen.dart';
import 'package:somnolence_app/features/rendiciones/presentation/widget/edit_rendicion_dialog.dart';

class GestionRendicionesScreen extends StatefulWidget {
  const GestionRendicionesScreen({super.key});

  @override
  State<GestionRendicionesScreen> createState() =>
      _GestionRendicionesScreenState();
}

class _GestionRendicionesScreenState extends State<GestionRendicionesScreen> {
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RendicionesProvider>().cargarMisRendiciones();
    });
  }

  Future<void> _recargarDatos() async {
    await context.read<RendicionesProvider>().cargarMisRendiciones();
  }

  // --- LÓGICA DE FILTROS RÁPIDOS ---
  void _filtrarHoy() {
    final now = DateTime.now();
    setState(() => _rangoFechas = DateTimeRange(start: now, end: now));
  }

  void _filtrarEsteMes() {
    final now = DateTime.now();
    setState(
      () => _rangoFechas = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      ),
    );
  }

  void _filtrarEsteAnio() {
    final now = DateTime.now();
    setState(
      () => _rangoFechas = DateTimeRange(
        start: DateTime(now.year, 1, 1),
        end: DateTime(now.year, 12, 31),
      ),
    );
  }

  Future<void> _seleccionarRangoPersonalizado() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: null,
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
    if (picked != null) setState(() => _rangoFechas = picked);
  }

  void _limpiarFiltro() => setState(() => _rangoFechas = null);

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  String _formatearFecha(String fechaString) {
    if (fechaString.isEmpty) return "";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(fechaString));
    } catch (e) {
      return fechaString;
    }
  }

  // --- LÓGICA DE ENVÍO ---
  Future<void> _prepararEnvio(int idRendicion, int totalMonto) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final gastoProvider = context.read<GastoProvider>();
    await gastoProvider.cargarGastos(idRendicion);
    final gastos = gastoProvider.gastos;

    if (mounted) Navigator.pop(context);

    if (gastos.any((g) => g.estado == 'Rechazado')) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 10),
              Text("Envío Bloqueado"),
            ],
          ),
          content: const Text(
            "Esta rendición contiene gastos RECHAZADOS.\nPor normativa, debes ELIMINARLOS antes de volver a enviar.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Entendido",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    int cantidadGastos = gastos.length;
    int sinFoto = gastos.where((g) => g.fotos.isEmpty).length;

    if (cantidadGastos == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No puedes enviar una rendición sin gastos."),
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enviar a Revisión"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Estás a punto de enviar esta rendición."),
            const SizedBox(height: 15),
            Text("Total Gastos: $cantidadGastos"),
            Text("Monto Total: ${_formatMoney(totalMonto)}"),
            const SizedBox(height: 15),
            if (sinFoto > 0)
              Text(
                "⚠️ Advertencia: Hay $sinFoto gastos sin foto.",
                style: TextStyle(color: Colors.orange[800]),
              )
            else
              Text(
                "✅ Evidencia completa",
                style: TextStyle(color: Colors.green[700]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _enviarDefinitivo(idRendicion);
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarDefinitivo(int idRendicion) async {
    await context.read<RendicionesProvider>().enviarRendicion(idRendicion);
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Procesado")));
  }

  Future<void> _confirmarBorrar(int idRendicion) async {
    await context.read<RendicionesProvider>().borrarRendicion(idRendicion);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();
    final todasLasRendiciones = provider.rendiciones;

    final rendicionesFiltradas = _rangoFechas == null
        ? todasLasRendiciones
        : todasLasRendiciones.where((r) {
            if (r.fecha.isEmpty) return false;
            try {
              final f = DateTime.parse(r.fecha);
              final s = _rangoFechas!.start.copyWith(
                hour: 0,
                minute: 0,
                second: 0,
              );
              final e = _rangoFechas!.end.copyWith(
                hour: 23,
                minute: 59,
                second: 59,
              );
              return f.isAfter(s.subtract(const Duration(seconds: 1))) &&
                  f.isBefore(e.add(const Duration(seconds: 1)));
            } catch (_) {
              return false;
            }
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
                      const Text(
                        "Mis Rendiciones",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    // Filtros Rápidos Visibles en Web
                    TextButton.icon(
                      onPressed: _filtrarHoy,
                      icon: const Icon(
                        Icons.today,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Hoy",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _filtrarEsteMes,
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Este Mes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _filtrarEsteAnio,
                      icon: const Icon(
                        Icons.event,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Este Año",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 30, color: Colors.white30),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      tooltip: "Rango personalizado",
                      onPressed: _seleccionarRangoPersonalizado,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: "Recargar",
                      onPressed: provider.isLoading ? null : _recargarDatos,
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : AppBar(
                  title: const Text(
                    "Mis Rendiciones",
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
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.calendar_month,
                        color: _rangoFechas != null
                            ? Colors.amberAccent
                            : Colors.white,
                      ),
                      onSelected: (v) {
                        if (v == 'hoy') _filtrarHoy();
                        if (v == 'mes') _filtrarEsteMes();
                        if (v == 'anio') _filtrarEsteAnio();
                        if (v == 'custom') _seleccionarRangoPersonalizado();
                        if (v == 'limpiar') _limpiarFiltro();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'hoy',
                          child: Text('📅 Hoy'),
                        ),
                        const PopupMenuItem(
                          value: 'mes',
                          child: Text('📆 Este Mes'),
                        ),
                        const PopupMenuItem(
                          value: 'anio',
                          child: Text('🗓️ Este Año'),
                        ),
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
                      onPressed: provider.isLoading ? null : _recargarDatos,
                    ),
                  ],
                ),

          // --- BOTÓN FLOTANTE ---
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const AddRendicionDialog(),
            ),
            label: isDesktop
                ? const Text(
                    "NUEVA RENDICIÓN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text("Nueva Rendición"),
            icon: const Icon(Icons.add),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),

          // --- CUERPO ---
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
              ), // Centrado en PC
              child: Column(
                children: [
                  if (_rangoFechas != null)
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 16,
                        vertical: 12,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.filter_list,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${DateFormat('dd-MM-yyyy').format(_rangoFechas!.start)}  al  ${DateFormat('dd-MM-yyyy').format(_rangoFechas!.end)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: _limpiarFiltro,
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : rendicionesFiltradas.isEmpty
                        ? _buildEmptyState()
                        : isDesktop
                        // --- GRILLA PARA ESCRITORIO ---
                        ? GridView.builder(
                            padding: const EdgeInsets.all(32),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 Columnas anchas
                                  childAspectRatio:
                                      2.2, // Tarjetas rectangulares
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                ),
                            itemCount: rendicionesFiltradas.length,
                            itemBuilder: (context, index) =>
                                _buildRendicionCardDesktop(
                                  rendicionesFiltradas[index],
                                ),
                          )
                        // --- LISTA PARA MÓVIL ---
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: rendicionesFiltradas.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) =>
                                _buildRendicionCardMobile(
                                  rendicionesFiltradas[index],
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

  // ==========================================================
  // 💻 TARJETA ESCRITORIO (Sin Slidable, con Botones Visibles)
  // ==========================================================
  Widget _buildRendicionCardDesktop(dynamic rendicion) {
    final Map<String, dynamic> conf = _getBadgeConfig(rendicion.estado);
    final String idStr = (rendicion.idRendicion ?? 0).toString().padLeft(
      3,
      '0',
    );
    final String titulo =
        rendicion.estado != 'Borrador' && rendicion.fecha.isNotEmpty
        ? "#$idStr"
        : "#$idStr";
    final bool esEditable = [
      'Borrador',
      'Observada',
    ].contains(rendicion.estado);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navegarDetalle(rendicion),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: Fecha y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatearFecha(rendicion.fecha),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: conf['bgColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      conf['text'],
                      style: TextStyle(
                        color: conf['textColor'],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cuerpo: ID, Propósito y Saldo
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                titulo,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rendicion.proposito,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (rendicion.centroCosto != null)
                            Text(
                              rendicion.centroCosto,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildSaldoWidget(
                      rendicion.montoEntregado,
                      rendicion.totalGastado,
                      isDesktop: true,
                    ),
                  ],
                ),
              ),

              // Pie: Botones de Acción (Si es editable)
              if (esEditable) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _confirmarBorrar(rendicion.idRendicion!),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 18,
                      ),
                      label: const Text(
                        "Borrar",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            EditRendicionDialog(rendicion: rendicion),
                      ),
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 18,
                      ),
                      label: const Text(
                        "Editar",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _prepararEnvio(
                        rendicion.idRendicion!,
                        rendicion.totalGastado,
                      ),
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text("Enviar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 📱 TARJETA MÓVIL (Con Slidable original)
  // ==========================================================
  Widget _buildRendicionCardMobile(dynamic rendicion) {
    final Map<String, dynamic> conf = _getBadgeConfig(rendicion.estado);
    final String idStr = (rendicion.idRendicion ?? 0).toString().padLeft(
      3,
      '0',
    );
    final String titulo =
        rendicion.estado != 'Borrador' && rendicion.fecha.isNotEmpty
        ? "#$idStr"
        : "#$idStr";
    final bool esEditable = [
      'Borrador',
      'Observada',
    ].contains(rendicion.estado);

    return Slidable(
      key: ValueKey(rendicion.idRendicion),
      enabled: esEditable,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.7,
        children: [
          SlidableAction(
            onPressed: (_) => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => EditRendicionDialog(rendicion: rendicion),
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
          ),
          SlidableAction(
            onPressed: (_) => _confirmarBorrar(rendicion.idRendicion!),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Borrar',
          ),
          SlidableAction(
            onPressed: (_) =>
                _prepararEnvio(rendicion.idRendicion!, rendicion.totalGastado),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.send,
            label: 'Enviar',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _navegarDetalle(rendicion),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatearFecha(rendicion.fecha),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: conf['bgColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        conf['text'],
                        style: TextStyle(
                          color: conf['textColor'],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rendicion.proposito,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (rendicion.centroCosto != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${rendicion.centroCosto}",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gastado",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          _formatMoney(rendicion.totalGastado),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    _buildSaldoWidget(
                      rendicion.montoEntregado,
                      rendicion.totalGastado,
                      isDesktop: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- COMPONENTES REUTILIZABLES ---

  Map<String, dynamic> _getBadgeConfig(String estado) {
    switch (estado) {
      case 'Borrador':
        return {
          'bgColor': Colors.amber.shade100,
          'textColor': Colors.amber.shade900,
          'text': 'BORRADOR',
        };
      case 'Pendiente de Validación':
        return {
          'bgColor': Colors.blue.shade100,
          'textColor': Colors.blue.shade900,
          'text': 'PENDIENTE DE VALIDACIÓN',
        };
      case 'Aprobada':
        return {
          'bgColor': Colors.purple.shade100,
          'textColor': Colors.purple.shade900,
          'text': 'POR PAGAR',
        };
      case 'Pagada':
        return {
          'bgColor': Colors.green.shade100,
          'textColor': Colors.green.shade800,
          'text': 'PAGADA',
        };
      case 'Observada':
        return {
          'bgColor': Colors.red.shade100,
          'textColor': Colors.red.shade900,
          'text': 'OBSERVADA',
        };
      default:
        return {
          'bgColor': Colors.grey.shade200,
          'textColor': Colors.black54,
          'text': estado.toUpperCase(),
        };
    }
  }

  Widget _buildSaldoWidget(
    int montoEntregado,
    int totalGastado, {
    required bool isDesktop,
  }) {
    final int saldoMatematico = montoEntregado - totalGastado;
    final bool esReembolso = saldoMatematico < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          esReembolso ? "REEMBOLSO" : "DEVOLUCIÓN",
          style: TextStyle(
            fontSize: isDesktop ? 12 : 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Text(
          _formatMoney(saldoMatematico.abs()),
          style: TextStyle(
            fontSize: isDesktop ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: esReembolso ? Colors.redAccent : Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.date_range_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _rangoFechas != null
                ? "No hay rendiciones en esta fecha"
                : "No tienes rendiciones",
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _navegarDetalle(dynamic rendicion) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RendicionDetailScreen(rendicion: rendicion),
      ),
    );
    if (mounted) context.read<RendicionesProvider>().cargarMisRendiciones();
  }
}
