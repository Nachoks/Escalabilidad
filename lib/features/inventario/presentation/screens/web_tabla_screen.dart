import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/widgets/logo_appbar.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/inventario_provider.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

// 👇 IMPORTACIÓN DEL PAQUETE EXCEL 👇
import 'package:excel/excel.dart' hide Border;

class WebTablasScreen extends StatefulWidget {
  const WebTablasScreen({Key? key}) : super(key: key);

  @override
  State<WebTablasScreen> createState() => _WebTablasScreenState();
}

class _WebTablasScreenState extends State<WebTablasScreen> {
  // --- VARIABLES FILTROS STOCK GLOBAL ---
  String _busquedaMarca = '';

  // 1. Filtro superior (Disponibilidad)
  String _filtroDisponibilidad = 'Todos';
  final List<String> _opcionesDisponibilidad = [
    'Todos',
    'Con Stock',
    'Sin Stock',
  ];

  // 2. Filtro en Columna (Estado de Stock)
  String _filtroEstado = 'Todos';
  final List<String> _opcionesEstado = [
    'Todos',
    'Hay suficientes',
    'Stock Mínimo',
    'Solicitar Equipos',
  ];

  // --- VARIABLES DE ORDENAMIENTO PERSONALIZADO (POPUP) ---
  String _stockSortCol = '';
  String _stockSortOrder = 'defecto'; // 'asc', 'desc', 'defecto'

  String _entradasSortCol = '';
  String _entradasSortOrder = 'defecto';

  String _salidasSortCol = '';
  String _salidasSortOrder = 'defecto';

  // --- VARIABLES FILTROS HISTORIAL ENTRADAS ---
  String _busquedaOcEntrada = '';
  String _filtroFechaEntrada = 'Todas';
  DateTime? _fechaInicioEntrada;
  DateTime? _fechaFinEntrada;

  // --- VARIABLES FILTROS HISTORIAL SALIDAS ---
  String _busquedaClienteSalida = '';
  String _filtroFechaSalida = 'Todas';
  DateTime? _fechaInicioSalida;
  DateTime? _fechaFinSalida;

  final List<String> _opcionesFecha = [
    'Todas',
    'Hoy',
    'Esta Semana',
    'Este Mes',
    'Este Año',
    'Tramo Personalizado',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventarioProvider>(context, listen: false).cargarTablasWeb();
    });
  }

  String _formatearFechaHora(String? fechaIso) {
    if (fechaIso == null || fechaIso.isEmpty) return 'S/I';
    try {
      final fecha = DateTime.parse(fechaIso).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
    } catch (e) {
      return fechaIso;
    }
  }

  // ==========================================
  // LÓGICA DE EDICIÓN DE NOMBRE
  // ==========================================
  void _mostrarDialogoEditarNombre(
    BuildContext context,
    int idProducto,
    String nombreActual,
    InventarioProvider provider,
  ) {
    final TextEditingController nombreCtrl = TextEditingController(
      text: nombreActual,
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    "Editar Equipo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Modifica el nombre del producto. Esto se actualizará en todo el inventario.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nombreCtrl,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "El nombre no puede estar vacío"
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Equipo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setStateDialog(() => isSaving = true);
                            bool exito = await provider.editarNombreProducto(
                              idProducto,
                              nombreCtrl.text.trim(),
                            );
                            setStateDialog(() => isSaving = false);

                            if (exito) {
                              if (context.mounted) Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '✅ Nombre actualizado correctamente',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.errorMessage ??
                                        'Error al actualizar',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // CALENDARIOS DE FILTROS
  // ==========================================
  Future<void> _seleccionarRangoFechasEntrada() async {
    final List<DateTime?>? resultados = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        selectedDayHighlightColor: AppColors.primary,
        selectedRangeHighlightColor: AppColors.primary.withOpacity(0.15),
        cancelButton: const Text(
          'CANCELAR',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        okButton: const Text(
          'APLICAR',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      dialogSize: const Size(400, 420),
      value: _fechaInicioEntrada != null
          ? [_fechaInicioEntrada, _fechaFinEntrada]
          : [],
    );

    if (resultados != null && resultados.isNotEmpty) {
      setState(() {
        _fechaInicioEntrada = resultados.first;
        _fechaFinEntrada = resultados.length > 1 && resultados[1] != null
            ? resultados[1]
            : resultados.first;
      });
    } else if (_fechaInicioEntrada == null) {
      setState(() => _filtroFechaEntrada = 'Todas');
    }
  }

  Future<void> _seleccionarRangoFechasSalida() async {
    final List<DateTime?>? resultados = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        selectedDayHighlightColor: AppColors.primary,
        selectedRangeHighlightColor: AppColors.primary.withOpacity(0.15),
        cancelButton: const Text(
          'CANCELAR',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        okButton: const Text(
          'APLICAR',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      dialogSize: const Size(400, 420),
      value: _fechaInicioSalida != null
          ? [_fechaInicioSalida, _fechaFinSalida]
          : [],
    );

    if (resultados != null && resultados.isNotEmpty) {
      setState(() {
        _fechaInicioSalida = resultados.first;
        _fechaFinSalida = resultados.length > 1 && resultados[1] != null
            ? resultados[1]
            : resultados.first;
      });
    } else if (_fechaInicioSalida == null) {
      setState(() => _filtroFechaSalida = 'Todas');
    }
  }

  // ==========================================
  // EXTRACCIÓN DE LISTAS FILTRADAS Y ORDENADAS
  // ==========================================
  List<dynamic> _obtenerStockFiltrado(InventarioProvider provider) {
    List<dynamic> lista = provider.listaStock.where((item) {
      final prod = item.producto;
      final marca = (prod?.marca ?? '').toLowerCase();

      // Filtro de Búsqueda
      if (_busquedaMarca.isNotEmpty &&
          !marca.contains(_busquedaMarca.toLowerCase())) {
        return false;
      }

      // Filtro 1: Disponibilidad (Top Bar)
      if (_filtroDisponibilidad == 'Con Stock' && item.stockActual < 1)
        return false;
      if (_filtroDisponibilidad == 'Sin Stock' && item.stockActual > 0)
        return false;

      // Filtro 2: Estado de Stock (Columna)
      String estadoItem = item.stockActual > item.stockMinimo
          ? 'Hay suficientes'
          : (item.stockActual == item.stockMinimo
                ? 'Stock Mínimo'
                : 'Solicitar Equipos');

      if (_filtroEstado != 'Todos' && estadoItem != _filtroEstado) return false;

      return true;
    }).toList();

    // Ordenamiento Dinámico
    if (_stockSortCol.isNotEmpty && _stockSortOrder != 'defecto') {
      lista.sort((a, b) {
        int comp = 0;
        if (_stockSortCol == 'codigo') {
          comp = (a.producto?.codigoProducto ?? '').compareTo(
            b.producto?.codigoProducto ?? '',
          );
        } else if (_stockSortCol == 'nombre') {
          comp = (a.producto?.nombreProducto ?? '').compareTo(
            b.producto?.nombreProducto ?? '',
          );
        } else if (_stockSortCol == 'marca') {
          comp = (a.producto?.marca ?? '').compareTo(b.producto?.marca ?? '');
        } else if (_stockSortCol == 'entradas') {
          comp = a.totalEntradas.compareTo(b.totalEntradas);
        } else if (_stockSortCol == 'salidas') {
          comp = a.totalSalidas.compareTo(b.totalSalidas);
        } else if (_stockSortCol == 'minimo') {
          comp = a.stockMinimo.compareTo(b.stockMinimo);
        } else if (_stockSortCol == 'actual') {
          comp = a.stockActual.compareTo(b.stockActual);
        }
        return _stockSortOrder == 'asc' ? comp : -comp;
      });
    }
    return lista;
  }

  List<dynamic> _obtenerEntradasFiltradas(InventarioProvider provider) {
    List<dynamic> lista = provider.listaEntradas.where((ent) {
      final oc = (ent.ocProveedor ?? '').toLowerCase();
      if (_busquedaOcEntrada.isNotEmpty &&
          !oc.contains(_busquedaOcEntrada.toLowerCase())) {
        return false;
      }

      if (_filtroFechaEntrada != 'Todas' && ent.createdAt != null) {
        try {
          final fechaEntrada = DateTime.parse(ent.createdAt!).toLocal();
          final ahora = DateTime.now();

          if (_filtroFechaEntrada == 'Hoy') {
            if (fechaEntrada.year != ahora.year ||
                fechaEntrada.month != ahora.month ||
                fechaEntrada.day != ahora.day)
              return false;
          } else if (_filtroFechaEntrada == 'Esta Semana') {
            if (fechaEntrada.isBefore(ahora.subtract(const Duration(days: 7))))
              return false;
          } else if (_filtroFechaEntrada == 'Este Mes') {
            if (fechaEntrada.year != ahora.year ||
                fechaEntrada.month != ahora.month)
              return false;
          } else if (_filtroFechaEntrada == 'Este Año') {
            if (fechaEntrada.year != ahora.year) return false;
          } else if (_filtroFechaEntrada == 'Tramo Personalizado' &&
              _fechaInicioEntrada != null &&
              _fechaFinEntrada != null) {
            final inicio = DateTime(
              _fechaInicioEntrada!.year,
              _fechaInicioEntrada!.month,
              _fechaInicioEntrada!.day,
            );
            final fin = DateTime(
              _fechaFinEntrada!.year,
              _fechaFinEntrada!.month,
              _fechaFinEntrada!.day,
              23,
              59,
              59,
            );
            if (fechaEntrada.isBefore(inicio) || fechaEntrada.isAfter(fin))
              return false;
          }
        } catch (e) {
          return false;
        }
      }
      return true;
    }).toList();

    // Ordenamiento Dinámico
    if (_entradasSortCol.isNotEmpty && _entradasSortOrder != 'defecto') {
      lista.sort((a, b) {
        int comp = 0;
        if (_entradasSortCol == 'oc') {
          comp = (a.ocProveedor ?? '').compareTo(b.ocProveedor ?? '');
        } else if (_entradasSortCol == 'fecha') {
          comp = (a.createdAt ?? '').compareTo(b.createdAt ?? '');
        } else if (_entradasSortCol == 'serial') {
          comp = a.serial.compareTo(b.serial);
        } else if (_entradasSortCol == 'codigo') {
          comp = (a.producto?.codigoProducto ?? '').compareTo(
            b.producto?.codigoProducto ?? '',
          );
        } else if (_entradasSortCol == 'nombre') {
          comp = (a.producto?.nombreProducto ?? '').compareTo(
            b.producto?.nombreProducto ?? '',
          );
        } else if (_entradasSortCol == 'responsable') {
          comp = (a.responsable?.nombreCompleto ?? '').compareTo(
            b.responsable?.nombreCompleto ?? '',
          );
        }
        return _entradasSortOrder == 'asc' ? comp : -comp;
      });
    }
    return lista;
  }

  List<dynamic> _obtenerSalidasFiltradas(InventarioProvider provider) {
    List<dynamic> lista = provider.listaSalidas.where((sal) {
      final clienteNombre =
          (sal.cliente?.nombreCliente ?? 'Cliente #${sal.idCliente}')
              .toLowerCase();
      if (_busquedaClienteSalida.isNotEmpty &&
          !clienteNombre.contains(_busquedaClienteSalida.toLowerCase())) {
        return false;
      }

      if (_filtroFechaSalida != 'Todas' && sal.createdAt != null) {
        try {
          final fechaSalida = DateTime.parse(sal.createdAt!).toLocal();
          final ahora = DateTime.now();

          if (_filtroFechaSalida == 'Hoy') {
            if (fechaSalida.year != ahora.year ||
                fechaSalida.month != ahora.month ||
                fechaSalida.day != ahora.day)
              return false;
          } else if (_filtroFechaSalida == 'Esta Semana') {
            if (fechaSalida.isBefore(ahora.subtract(const Duration(days: 7))))
              return false;
          } else if (_filtroFechaSalida == 'Este Mes') {
            if (fechaSalida.year != ahora.year ||
                fechaSalida.month != ahora.month)
              return false;
          } else if (_filtroFechaSalida == 'Este Año') {
            if (fechaSalida.year != ahora.year) return false;
          } else if (_filtroFechaSalida == 'Tramo Personalizado' &&
              _fechaInicioSalida != null &&
              _fechaFinSalida != null) {
            final inicio = DateTime(
              _fechaInicioSalida!.year,
              _fechaInicioSalida!.month,
              _fechaInicioSalida!.day,
            );
            final fin = DateTime(
              _fechaFinSalida!.year,
              _fechaFinSalida!.month,
              _fechaFinSalida!.day,
              23,
              59,
              59,
            );
            if (fechaSalida.isBefore(inicio) || fechaSalida.isAfter(fin))
              return false;
          }
        } catch (e) {
          return false;
        }
      }
      return true;
    }).toList();

    // Ordenamiento Dinámico
    if (_salidasSortCol.isNotEmpty && _salidasSortOrder != 'defecto') {
      lista.sort((a, b) {
        int comp = 0;
        if (_salidasSortCol == 'oc') {
          comp = (a.ocCliente ?? '').compareTo(b.ocCliente ?? '');
        } else if (_salidasSortCol == 'cliente') {
          comp = (a.cliente?.nombreCliente ?? '').compareTo(
            b.cliente?.nombreCliente ?? '',
          );
        } else if (_salidasSortCol == 'centro_costo') {
          // 👇 ORDENAMIENTO POR CENTRO DE COSTO (CORREGIDO A sal.centroCosto) 👇
          final ccA = a.centroCosto ?? '';
          final ccB = b.centroCosto ?? '';
          comp = ccA.compareTo(ccB);
        } else if (_salidasSortCol == 'fecha') {
          comp = (a.createdAt ?? '').compareTo(b.createdAt ?? '');
        } else if (_salidasSortCol == 'serial') {
          comp = a.serial.compareTo(b.serial);
        } else if (_salidasSortCol == 'codigo') {
          comp = (a.producto?.codigoProducto ?? '').compareTo(
            b.producto?.codigoProducto ?? '',
          );
        } else if (_salidasSortCol == 'nombre') {
          comp = (a.producto?.nombreProducto ?? '').compareTo(
            b.producto?.nombreProducto ?? '',
          );
        } else if (_salidasSortCol == 'responsable') {
          comp = (a.responsable?.nombreCompleto ?? '').compareTo(
            b.responsable?.nombreCompleto ?? '',
          );
        }
        return _salidasSortOrder == 'asc' ? comp : -comp;
      });
    }
    return lista;
  }

  // ==========================================
  // GENERACIÓN DEL ARCHIVO EXCEL
  // ==========================================
  void _confirmarYGenerarExcel(int tabIndex, InventarioProvider provider) {
    String nombreTabla = tabIndex == 0
        ? 'Stock Global'
        : (tabIndex == 1 ? 'Entradas' : 'Salidas');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.table_view, color: Colors.green),
            SizedBox(width: 10),
            Text('Exportar a Excel'),
          ],
        ),
        content: Text(
          '¿Deseas descargar un archivo Excel con la información actual de la pestaña "$nombreTabla"? (Se respetarán los filtros aplicados).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _generarExcel(tabIndex, provider, nombreTabla);
            },
            child: const Text('DESCARGAR'),
          ),
        ],
      ),
    );
  }

  Future<void> _generarExcel(
    int tabIndex,
    InventarioProvider provider,
    String nombreTabla,
  ) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];

      if (tabIndex == 0) {
        sheet.appendRow([
          TextCellValue('Código'),
          TextCellValue('Nombre del Equipo'),
          TextCellValue('Marca'),
          TextCellValue('Total Entradas'),
          TextCellValue('Total Salidas'),
          TextCellValue('Stock Mínimo'),
          TextCellValue('Stock Actual'),
          TextCellValue('Estado de Stock'),
        ]);

        for (var item in _obtenerStockFiltrado(provider)) {
          String estado = item.stockActual > item.stockMinimo
              ? 'Hay suficientes'
              : (item.stockActual == item.stockMinimo
                    ? 'Stock Mínimo'
                    : 'Solicitar Equipos');

          sheet.appendRow([
            TextCellValue(item.producto?.codigoProducto ?? 'N/A'),
            TextCellValue(item.producto?.nombreProducto ?? 'N/A'),
            TextCellValue(item.producto?.marca ?? 'N/A'),
            IntCellValue(item.totalEntradas),
            IntCellValue(item.totalSalidas),
            IntCellValue(item.stockMinimo),
            IntCellValue(item.stockActual),
            TextCellValue(estado),
          ]);
        }
      } else if (tabIndex == 1) {
        sheet.appendRow([
          TextCellValue('OC Proveedor'),
          TextCellValue('Fecha (hora)'),
          TextCellValue('Serial'),
          TextCellValue('Código Producto'),
          TextCellValue('Nombre del Equipo'),
          TextCellValue('Responsable'),
        ]);

        for (var ent in _obtenerEntradasFiltradas(provider)) {
          sheet.appendRow([
            TextCellValue(ent.ocProveedor ?? 'S/I'),
            TextCellValue(_formatearFechaHora(ent.createdAt)),
            TextCellValue(ent.serial),
            TextCellValue(ent.producto?.codigoProducto ?? 'N/A'),
            TextCellValue(ent.producto?.nombreProducto ?? 'N/A'),
            TextCellValue(
              ent.responsable?.nombreCompleto ?? 'Resp. #${ent.idResponsable}',
            ),
          ]);
        }
      } else if (tabIndex == 2) {
        sheet.appendRow([
          TextCellValue('OC Cliente'),
          TextCellValue('Cliente Destino'),
          TextCellValue('Centro de Costo'),
          TextCellValue('Fecha (hora)'),
          TextCellValue('Serial'),
          TextCellValue('Código Producto'),
          TextCellValue('Nombre del Equipo'),
          TextCellValue('Responsable'),
        ]);

        for (var sal in _obtenerSalidasFiltradas(provider)) {
          // 👇 EXTRACCIÓN DEL CENTRO DE COSTO (CORREGIDO A sal.centroCosto) 👇
          final centroCosto = sal.centroCosto ?? 'S/I';

          sheet.appendRow([
            TextCellValue(sal.ocCliente ?? 'S/I'),
            TextCellValue(
              sal.cliente?.nombreCliente ?? 'Cliente #${sal.idCliente}',
            ),
            TextCellValue(centroCosto),
            TextCellValue(_formatearFechaHora(sal.createdAt)),
            TextCellValue(sal.serial),
            TextCellValue(sal.producto?.codigoProducto ?? 'N/A'),
            TextCellValue(sal.producto?.nombreProducto ?? 'N/A'),
            TextCellValue(
              sal.responsable?.nombreCompleto ?? 'Resp. #${sal.idResponsable}',
            ),
          ]);
        }
      }

      excel.save(fileName: "Reporte_$nombreTabla.xlsx");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Archivo Excel generado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al generar Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventarioProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Row(
            children: [
              LogoAppbar(),
              SizedBox(width: 10),
              Text(
                'Monitor de Inventario Central',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 4,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: const Icon(Icons.refresh, size: 28),
                tooltip: 'Actualizar Tablas',
                onPressed: () => provider.cargarTablasWeb(),
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.textWhite,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.textWhite,
            indicatorWeight: 4,
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'STOCK GLOBAL'),
              Tab(icon: Icon(Icons.login), text: 'HISTORIAL ENTRADAS'),
              Tab(icon: Icon(Icons.logout), text: 'HISTORIAL SALIDAS'),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (contextScaffold) {
            return FloatingActionButton.extended(
              onPressed: () {
                final currentTab = DefaultTabController.of(
                  contextScaffold,
                ).index;
                _confirmarYGenerarExcel(currentTab, provider);
              },
              backgroundColor: Colors.green.shade700,
              icon: const Icon(Icons.table_view, color: Colors.white),
              label: const Text(
                'Exportar Excel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        body: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : TabBarView(
                children: [
                  _buildTablaStock(provider),
                  _buildTablaEntradas(provider),
                  _buildTablaSalidas(provider),
                ],
              ),
      ),
    );
  }

  // ==========================================
  // TABLA 1: STOCK GLOBAL
  // ==========================================
  Widget _buildTablaStock(InventarioProvider provider) {
    final listaFiltrada = _obtenerStockFiltrado(provider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar por Marca del Equipo...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() => _busquedaMarca = value),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _filtroDisponibilidad,
                  decoration: InputDecoration(
                    labelText: 'Disponibilidad de Stock',
                    prefixIcon: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _opcionesDisponibilidad
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null)
                      setState(() => _filtroDisponibilidad = val);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: listaFiltrada.isEmpty
              ? _buildEmptyState(
                  'No hay productos que coincidan con los filtros.',
                )
              : _buildContainerTabla(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.primary.withOpacity(0.15),
                    ),
                    dataRowMaxHeight: 65,
                    columns: [
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Código',
                          false,
                          'codigo',
                          _stockSortCol,
                          _stockSortOrder,
                          (c, o) => setState(() {
                            _stockSortCol = c;
                            _stockSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Nombre del Equipo',
                          false,
                          'nombre',
                          _stockSortCol,
                          _stockSortOrder,
                          (c, o) => setState(() {
                            _stockSortCol = c;
                            _stockSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Marca',
                          false,
                          'marca',
                          _stockSortCol,
                          _stockSortOrder,
                          (c, o) => setState(() {
                            _stockSortCol = c;
                            _stockSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Total Entradas',
                          true,
                          'entradas',
                          _stockSortCol,
                          _stockSortOrder,
                          (c, o) => setState(() {
                            _stockSortCol = c;
                            _stockSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Total Salidas',
                          true,
                          'salidas',
                          _stockSortCol,
                          _stockSortOrder,
                          (c, o) => setState(() {
                            _stockSortCol = c;
                            _stockSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Stock Mínimo',
                          true,
                          'minimo',
                          _stockSortCol,
                          _stockSortOrder,
                          (c, o) => setState(() {
                            _stockSortCol = c;
                            _stockSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Stock Actual',
                          true,
                          'actual',
                          _stockSortCol,
                          _stockSortOrder,
                          (c, o) => setState(() {
                            _stockSortCol = c;
                            _stockSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: Row(
                          children: [
                            const Text(
                              'Estado de Stock',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.filter_alt,
                                size: 18,
                                color: _filtroEstado == 'Todos'
                                    ? Colors.grey
                                    : AppColors.primary,
                              ),
                              tooltip: 'Filtrar por Estado',
                              onSelected: (val) =>
                                  setState(() => _filtroEstado = val),
                              itemBuilder: (context) => _opcionesEstado
                                  .map(
                                    (e) => PopupMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          fontWeight: _filtroEstado == e
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                    rows: listaFiltrada.map((item) {
                      final prod = item.producto;
                      String textoEstado;
                      Color colorFondoEstado;

                      if (item.stockActual > item.stockMinimo) {
                        textoEstado = 'Hay suficientes';
                        colorFondoEstado = Colors.green;
                      } else if (item.stockActual == item.stockMinimo) {
                        textoEstado = 'Stock Mínimo';
                        colorFondoEstado = Colors.orange.shade700;
                      } else {
                        textoEstado = 'Solicitar Equipos';
                        colorFondoEstado = Colors.red;
                      }

                      final colorNumeroStock =
                          item.stockActual < item.stockMinimo
                          ? Colors.red
                          : AppColors.primary;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              prod?.codigoProducto ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(prod?.nombreProducto ?? 'N/A'),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  splashRadius: 20,
                                  onPressed: () {
                                    if (prod != null) {
                                      _mostrarDialogoEditarNombre(
                                        context,
                                        prod.idProducto,
                                        prod.nombreProducto,
                                        provider,
                                      );
                                    }
                                  },
                                  tooltip: 'Editar nombre del equipo',
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(prod?.marca ?? 'N/A')),
                          DataCell(Text(item.totalEntradas.toString())),
                          DataCell(Text(item.totalSalidas.toString())),
                          DataCell(
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: item.stockMinimo.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onFieldSubmitted: (value) async {
                                  int? nuevoValor = int.tryParse(value);
                                  if (nuevoValor != null &&
                                      nuevoValor != item.stockMinimo) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Guardando nuevo stock mínimo: $nuevoValor...',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                    bool exito = await provider
                                        .actualizarStockMinimo(
                                          item.idProducto,
                                          nuevoValor,
                                        );
                                    if (exito && mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '✅ Stock mínimo actualizado',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.errorMessage ??
                                                'Error al guardar',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorNumeroStock.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorNumeroStock.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                item.stockActual.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorNumeroStock,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorFondoEstado,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                textoEstado,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TABLA 2: HISTORIAL DE ENTRADAS
  // ==========================================
  Widget _buildTablaEntradas(InventarioProvider provider) {
    final listaFiltrada = _obtenerEntradasFiltradas(provider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar por Orden de Compra (OC)',
                    prefixIcon: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) =>
                      setState(() => _busquedaOcEntrada = value),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _filtroFechaEntrada,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por Fecha',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _opcionesFecha
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) async {
                    if (val != null) {
                      if (val == 'Tramo Personalizado') {
                        setState(() => _filtroFechaEntrada = val);
                        await _seleccionarRangoFechasEntrada();
                      } else {
                        setState(() {
                          _filtroFechaEntrada = val;
                          _fechaInicioEntrada = null;
                          _fechaFinEntrada = null;
                        });
                      }
                    }
                  },
                ),
              ),
              if (_filtroFechaEntrada == 'Tramo Personalizado' &&
                  _fechaInicioEntrada != null &&
                  _fechaFinEntrada != null) ...[
                const SizedBox(width: 15),
                ActionChip(
                  elevation: 2,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  side: const BorderSide(color: AppColors.primary),
                  avatar: const Icon(
                    Icons.edit_calendar,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: Text(
                    '${DateFormat('dd/MM/yyyy').format(_fechaInicioEntrada!)} - ${DateFormat('dd/MM/yyyy').format(_fechaFinEntrada!)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _seleccionarRangoFechasEntrada,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: listaFiltrada.isEmpty
              ? _buildEmptyState(
                  'No se encontraron entradas con estos filtros.',
                )
              : _buildContainerTabla(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.primary.withOpacity(0.1),
                    ),
                    columns: [
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'OC',
                          false,
                          'oc',
                          _entradasSortCol,
                          _entradasSortOrder,
                          (c, o) => setState(() {
                            _entradasSortCol = c;
                            _entradasSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Fecha (hora)',
                          false,
                          'fecha',
                          _entradasSortCol,
                          _entradasSortOrder,
                          (c, o) => setState(() {
                            _entradasSortCol = c;
                            _entradasSortOrder = o;
                          }),
                          isDate: true,
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Serial',
                          false,
                          'serial',
                          _entradasSortCol,
                          _entradasSortOrder,
                          (c, o) => setState(() {
                            _entradasSortCol = c;
                            _entradasSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Código',
                          false,
                          'codigo',
                          _entradasSortCol,
                          _entradasSortOrder,
                          (c, o) => setState(() {
                            _entradasSortCol = c;
                            _entradasSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Nombre del Equipo',
                          false,
                          'nombre',
                          _entradasSortCol,
                          _entradasSortOrder,
                          (c, o) => setState(() {
                            _entradasSortCol = c;
                            _entradasSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Responsable',
                          false,
                          'responsable',
                          _entradasSortCol,
                          _entradasSortOrder,
                          (c, o) => setState(() {
                            _entradasSortCol = c;
                            _entradasSortOrder = o;
                          }),
                        ),
                      ),
                    ],
                    rows: listaFiltrada.map((ent) {
                      final String oc = ent.ocProveedor ?? 'S/I';
                      final String fecha = _formatearFechaHora(ent.createdAt);
                      final String serial = ent.serial;
                      final String codigo =
                          ent.producto?.codigoProducto ?? 'N/A';
                      final String equipo =
                          ent.producto?.nombreProducto ?? 'N/A';
                      final String responsable =
                          ent.responsable?.nombreCompleto ??
                          'Resp. #${ent.idResponsable}';

                      return DataRow(
                        cells: [
                          DataCell(Text(oc)),
                          DataCell(Text(fecha)),
                          DataCell(
                            Text(
                              serial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(codigo)),
                          DataCell(Text(equipo)),
                          DataCell(Text(responsable)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TABLA 3: HISTORIAL DE SALIDAS
  // ==========================================
  Widget _buildTablaSalidas(InventarioProvider provider) {
    final listaFiltrada = _obtenerSalidasFiltradas(provider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar por Nombre de Cliente',
                    prefixIcon: const Icon(
                      Icons.business,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) =>
                      setState(() => _busquedaClienteSalida = value),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _filtroFechaSalida,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por Fecha',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _opcionesFecha
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) async {
                    if (val != null) {
                      if (val == 'Tramo Personalizado') {
                        setState(() => _filtroFechaSalida = val);
                        await _seleccionarRangoFechasSalida();
                      } else {
                        setState(() {
                          _filtroFechaSalida = val;
                          _fechaInicioSalida = null;
                          _fechaFinSalida = null;
                        });
                      }
                    }
                  },
                ),
              ),
              if (_filtroFechaSalida == 'Tramo Personalizado' &&
                  _fechaInicioSalida != null &&
                  _fechaFinSalida != null) ...[
                const SizedBox(width: 15),
                ActionChip(
                  elevation: 2,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  side: const BorderSide(color: AppColors.primary),
                  avatar: const Icon(
                    Icons.edit_calendar,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: Text(
                    '${DateFormat('dd/MM/yyyy').format(_fechaInicioSalida!)} - ${DateFormat('dd/MM/yyyy').format(_fechaFinSalida!)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _seleccionarRangoFechasSalida,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: listaFiltrada.isEmpty
              ? _buildEmptyState('No se encontraron salidas con estos filtros.')
              : _buildContainerTabla(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.primary.withOpacity(0.1),
                    ),
                    columns: [
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'OC',
                          false,
                          'oc',
                          _salidasSortCol,
                          _salidasSortOrder,
                          (c, o) => setState(() {
                            _salidasSortCol = c;
                            _salidasSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Cliente',
                          false,
                          'cliente',
                          _salidasSortCol,
                          _salidasSortOrder,
                          (c, o) => setState(() {
                            _salidasSortCol = c;
                            _salidasSortOrder = o;
                          }),
                        ),
                      ),

                      // 👇 NUEVA COLUMNA DE CENTRO DE COSTO EN EL MEDIO 👇
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Centro de Costo',
                          false,
                          'centro_costo',
                          _salidasSortCol,
                          _salidasSortOrder,
                          (c, o) => setState(() {
                            _salidasSortCol = c;
                            _salidasSortOrder = o;
                          }),
                        ),
                      ),

                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Fecha (hora)',
                          false,
                          'fecha',
                          _salidasSortCol,
                          _salidasSortOrder,
                          (c, o) => setState(() {
                            _salidasSortCol = c;
                            _salidasSortOrder = o;
                          }),
                          isDate: true,
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Serial',
                          false,
                          'serial',
                          _salidasSortCol,
                          _salidasSortOrder,
                          (c, o) => setState(() {
                            _salidasSortCol = c;
                            _salidasSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Código',
                          false,
                          'codigo',
                          _salidasSortCol,
                          _salidasSortOrder,
                          (c, o) => setState(() {
                            _salidasSortCol = c;
                            _salidasSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Nombre del Equipo',
                          false,
                          'nombre',
                          _salidasSortCol,
                          _salidasSortOrder,
                          (c, o) => setState(() {
                            _salidasSortCol = c;
                            _salidasSortOrder = o;
                          }),
                        ),
                      ),
                      DataColumn(
                        label: _buildHeaderWithSort(
                          'Responsable',
                          false,
                          'responsable',
                          _salidasSortCol,
                          _salidasSortOrder,
                          (c, o) => setState(() {
                            _salidasSortCol = c;
                            _salidasSortOrder = o;
                          }),
                        ),
                      ),
                    ],
                    rows: listaFiltrada.map((sal) {
                      final String oc = sal.ocCliente ?? 'S/I';
                      final String cliente =
                          sal.cliente?.nombreCliente ??
                          'Cliente #${sal.idCliente}';

                      // 👇 ASIGNACIÓN DEL DATO DEL CENTRO DE COSTO (CORREGIDA) 👇
                      final String centroCosto = sal.centroCosto ?? 'S/I';

                      final String fecha = _formatearFechaHora(sal.createdAt);
                      final String serial = sal.serial;
                      final String codigo =
                          sal.producto?.codigoProducto ?? 'N/A';
                      final String equipo =
                          sal.producto?.nombreProducto ?? 'N/A';
                      final String responsable =
                          sal.responsable?.nombreCompleto ??
                          'Resp. #${sal.idResponsable}';

                      return DataRow(
                        cells: [
                          DataCell(Text(oc)),
                          DataCell(Text(cliente)),
                          DataCell(
                            Text(
                              centroCosto,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ), // 👈 Celda de CC
                          DataCell(Text(fecha)),
                          DataCell(
                            Text(
                              serial,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(codigo)),
                          DataCell(Text(equipo)),
                          DataCell(Text(responsable)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGETS REUTILIZABLES DE DISEÑO
  // ==========================================

  Widget _buildHeaderWithSort(
    String title,
    bool isNumeric,
    String colKey,
    String currentSortCol,
    String currentSortOrder,
    Function(String, String) onSortChanged, {
    bool isDate = false,
  }) {
    List<String> options = ['Por defecto'];
    if (isDate) {
      options.addAll(['Más recientes primero', 'Más antiguos primero']);
    } else if (isNumeric) {
      options.addAll(['Menor a Mayor', 'Mayor a Menor']);
    } else {
      options.addAll(['A - Z', 'Z - A']);
    }

    bool isActive = currentSortCol == colKey && currentSortOrder != 'defecto';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: Icon(
            isActive
                ? (currentSortOrder == 'asc'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward)
                : Icons.sort,
            size: 18,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
          tooltip: 'Ordenar',
          onSelected: (val) {
            if (val == 'Por defecto') {
              onSortChanged('', 'defecto');
            } else if (val == 'Menor a Mayor' ||
                val == 'A - Z' ||
                val == 'Más antiguos primero') {
              onSortChanged(colKey, 'asc');
            } else {
              onSortChanged(colKey, 'desc');
            }
          },
          itemBuilder: (context) => options.map((e) {
            bool isBold = false;
            if (currentSortCol == colKey) {
              if (e == 'Por defecto' && currentSortOrder == 'defecto')
                isBold = true;
              if ((e == 'Menor a Mayor' ||
                      e == 'A - Z' ||
                      e == 'Más antiguos primero') &&
                  currentSortOrder == 'asc')
                isBold = true;
              if ((e == 'Mayor a Menor' ||
                      e == 'Z - A' ||
                      e == 'Más recientes primero') &&
                  currentSortOrder == 'desc')
                isBold = true;
            }
            return PopupMenuItem(
              value: e,
              child: Text(
                e,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContainerTabla({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth > 40
                      ? constraints.maxWidth - 40
                      : 0,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
