import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart'; // Necesario para formatear fechas en el filtro
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
    setState(() {
      _rangoFechas = DateTimeRange(start: now, end: now);
    });
  }

  void _filtrarEsteMes() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0); // Último día del mes
    setState(() {
      _rangoFechas = DateTimeRange(start: start, end: end);
    });
  }

  void _filtrarEsteAnio() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    setState(() {
      _rangoFechas = DateTimeRange(start: start, end: end);
    });
  }

  Future<void> _seleccionarRangoPersonalizado() async {
    final DateTime now = DateTime.now();

    // Al pasar 'null' aquí, el calendario se abre "limpio"
    // Esto evita el error de validación con fechas futuras (como Fin de Año)
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now, // Ahora sí podemos limitar hasta 'hoy' sin miedo
      initialDateRange:
          null, // <--- CAMBIO CLAVE: Iniciamos sin selección previa
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
      setState(() {
        _rangoFechas = picked;
      });
    }
  }

  void _limpiarFiltro() {
    setState(() {
      _rangoFechas = null;
    });
  }

  String _formatMoney(int amount) {
    return "\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  // --- WIDGET SALDO ---
  Widget _buildSaldoWidget(int montoEntregado, int totalGastado) {
    final int saldoMatematico = montoEntregado - totalGastado;
    final bool esReembolso = saldoMatematico < 0;
    final int valorMostrar = saldoMatematico.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          esReembolso ? "REEMBOLSO" : "DEVOLUCIÓN",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Text(
          _formatMoney(valorMostrar),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: esReembolso ? Colors.redAccent : Colors.green[700],
          ),
        ),
      ],
    );
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

    bool hayRechazados = gastos.any((g) => g.estado == 'Rechazado');

    if (hayRechazados) {
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
            "Esta rendición contiene gastos que fueron RECHAZADOS anteriormente.\n\n"
            "Por normativa, debes ELIMINAR los gastos rechazados antes de volver a enviar la rendición a revisión.",
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
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Procesado")));
    }
  }

  Future<void> _confirmarBorrar(int idRendicion) async {
    await context.read<RendicionesProvider>().borrarRendicion(idRendicion);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RendicionesProvider>();
    final todasLasRendiciones = provider.rendiciones;

    // --- FILTRADO EN MEMORIA ---
    final rendicionesFiltradas = _rangoFechas == null
        ? todasLasRendiciones
        : todasLasRendiciones.where((r) {
            if (r.fecha.isEmpty) return false;
            try {
              final fechaRendicion = DateTime.parse(r.fecha);
              // Normalizamos para comparar fechas completas
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

              return fechaRendicion.isAfter(
                    start.subtract(const Duration(seconds: 1)),
                  ) &&
                  fechaRendicion.isBefore(end.add(const Duration(seconds: 1)));
            } catch (e) {
              return false;
            }
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
          // MENÚ DE FILTRO (Más limpio que un botón gigante)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.calendar_month,
              color: _rangoFechas != null ? Colors.amberAccent : Colors.white,
            ),
            tooltip: "Filtrar por fecha",
            onSelected: (value) {
              if (value == 'hoy') _filtrarHoy();
              if (value == 'mes') _filtrarEsteMes();
              if (value == 'anio') _filtrarEsteAnio();
              if (value == 'custom') _seleccionarRangoPersonalizado();
              if (value == 'limpiar') _limpiarFiltro();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(value: 'hoy', child: Text('📅 Hoy')),
              const PopupMenuItem(value: 'mes', child: Text('📆 Este Mes')),
              const PopupMenuItem(value: 'anio', child: Text('🗓️ Este Año')),
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
            tooltip: "Recargar",
            onPressed: provider.isLoading ? null : _recargarDatos,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AddRendicionDialog(),
          );
        },
        label: const Text("Nueva Rendición"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // INDICADOR VISUAL DEL FILTRO (Pequeño y con opción de borrar)
          if (_rangoFechas != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Ocupa solo lo necesario
                children: [
                  Icon(Icons.filter_list, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    "${DateFormat('dd/MM/yyyy').format(_rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.end)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _limpiarFiltro,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          // LISTA
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : rendicionesFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.date_range_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _rangoFechas != null
                              ? "No hay rendiciones en esta fecha"
                              : "No tienes rendiciones",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: rendicionesFiltradas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rendicion = rendicionesFiltradas[index];
                      final String idFormateado = (rendicion.idRendicion ?? 0)
                          .toString()
                          .padLeft(3, '0');

                      // --- TU ESTRUCTURA SOLICITADA PARA EL TÍTULO ---
                      String tituloID = "#$idFormateado";
                      if (rendicion.estado != 'Borrador' &&
                          rendicion.fecha.isNotEmpty) {
                        tituloID = "#$idFormateado ";
                      }
                      // -----------------------------------------------

                      final bool esEditable = [
                        'Borrador',
                        'Observada',
                      ].contains(rendicion.estado);

                      // Configuración de Badges
                      Color badgeColor;
                      Color badgeTextColor;
                      String badgeText = rendicion.estado;

                      switch (rendicion.estado) {
                        case 'Borrador':
                          badgeColor = Colors.amber.shade100;
                          badgeTextColor = Colors.amber.shade900;
                          break;
                        case 'Pendiente de Validación':
                          badgeColor = Colors.blue.shade100;
                          badgeTextColor = Colors.blue.shade900;
                          break;
                        case 'Aprobada':
                          badgeColor = Colors.purple.shade100;
                          badgeTextColor = Colors.purple.shade900;
                          badgeText = "POR PAGAR";
                          break;
                        case 'Pagada':
                          badgeColor = Colors.green.shade100;
                          badgeTextColor = Colors.green.shade800;
                          break;
                        case 'Observada':
                          badgeColor = Colors.red.shade100;
                          badgeTextColor = Colors.red.shade900;
                          break;
                        default:
                          badgeColor = Colors.grey.shade200;
                          badgeTextColor = Colors.black54;
                      }

                      return Slidable(
                        key: ValueKey(rendicion.idRendicion),
                        enabled: esEditable,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.7,
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) =>
                                      EditRendicionDialog(rendicion: rendicion),
                                );
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Editar',
                            ),
                            SlidableAction(
                              onPressed: (_) =>
                                  _confirmarBorrar(rendicion.idRendicion!),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Borrar',
                            ),
                            SlidableAction(
                              onPressed: (_) => _prepararEnvio(
                                rendicion.idRendicion!,
                                rendicion.totalGastado,
                              ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RendicionDetailScreen(
                                    rendicion: rendicion,
                                  ),
                                ),
                              );
                              if (mounted) {
                                context
                                    .read<RendicionesProvider>()
                                    .cargarMisRendiciones();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Cabecera (Fecha original y Badge) - TU DISEÑO ORIGINAL
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rendicion
                                            .fecha, // Fecha original pequeña a la izquierda
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: badgeColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          badgeText.toUpperCase(),
                                          style: TextStyle(
                                            color: badgeTextColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // 2. Título (ID + Fecha si corresponde y Propósito)
                                  Row(
                                    children: [
                                      Text(
                                        tituloID, // Variable con la lógica solicitada
                                        style: TextStyle(
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
                                            color: Colors.black87,
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

                                  // 3. Resumen Financiero
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Gastado",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _formatMoney(
                                              rendicion.totalGastado,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildSaldoWidget(
                                        rendicion.montoEntregado,
                                        rendicion.totalGastado,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
}
