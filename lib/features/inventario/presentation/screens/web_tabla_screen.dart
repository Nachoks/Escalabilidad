import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:somnolence_app/core/constants/app_colors.dart';
import 'package:somnolence_app/core/widgets/logo_appbar.dart';
import 'package:somnolence_app/features/inventario/presentation/providers/inventario_provider.dart';

class WebTablasScreen extends StatefulWidget {
  const WebTablasScreen({Key? key}) : super(key: key);

  @override
  State<WebTablasScreen> createState() => _WebTablasScreenState();
}

class _WebTablasScreenState extends State<WebTablasScreen> {
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
    if (provider.listaStock.isEmpty) {
      return _buildEmptyState('No hay productos en stock.');
    }
    return _buildContainerTabla(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppColors.primary.withOpacity(0.15),
        ),
        dataRowMaxHeight: 65,
        columns: const [
          DataColumn(
            label: Text(
              'Código',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Nombre del Equipo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Marca', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Total Entradas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Total Salidas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Stock Mínimo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Stock Actual',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: provider.listaStock.map((item) {
          final prod = item.producto;
          final colorStock = item.stockActual <= item.stockMinimo
              ? Colors.red
              : AppColors.primary;

          return DataRow(
            cells: [
              DataCell(
                Text(
                  prod?.codigoProducto ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(Text(prod?.nombreProducto ?? 'N/A')),
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
                          ),
                        );
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
                    color: colorStock.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorStock.withOpacity(0.5)),
                  ),
                  child: Text(
                    item.stockActual.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorStock,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // TABLA 2: HISTORIAL DE ENTRADAS
  // ==========================================
  Widget _buildTablaEntradas(InventarioProvider provider) {
    if (provider.listaEntradas.isEmpty) {
      return _buildEmptyState('No hay registro de entradas.');
    }
    return _buildContainerTabla(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppColors.primary.withOpacity(0.1),
        ),
        columns: const [
          DataColumn(
            label: Text('OC', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Fecha (hora)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Serial',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Código',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Nombre del Equipo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Responsable',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: provider.listaEntradas.map((ent) {
          final String oc = ent.ocProveedor ?? 'S/I';
          final String fecha = 'S/I';
          final String serial = ent.serial;
          final String codigo = ent.producto?.codigoProducto ?? 'N/A';
          final String equipo = ent.producto?.nombreProducto ?? 'N/A';
          final String responsable = 'Resp. #${ent.idResponsable}';

          return DataRow(
            cells: [
              DataCell(Text(oc)),
              DataCell(Text(fecha)),
              DataCell(
                Text(
                  serial,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text(codigo)),
              DataCell(Text(equipo)),
              DataCell(Text(responsable)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // TABLA 3: HISTORIAL DE SALIDAS
  // ==========================================
  Widget _buildTablaSalidas(InventarioProvider provider) {
    if (provider.listaSalidas.isEmpty) {
      return _buildEmptyState('No hay registro de salidas.');
    }
    return _buildContainerTabla(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppColors.primary.withOpacity(0.1),
        ),
        columns: const [
          DataColumn(
            label: Text('OC', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Cliente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Fecha (hora)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Serial',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Código',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Nombre del Equipo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Responsable',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: provider.listaSalidas.map((sal) {
          final String oc = sal.ocCliente ?? 'S/I';
          final String cliente = 'Cliente #${sal.idCliente}';
          final String fecha = 'S/I';
          final String serial = sal.serial;
          final String codigo = 'N/A';
          final String equipo = 'N/A';
          final String responsable = 'Resp. #${sal.idResponsable}';

          return DataRow(
            cells: [
              DataCell(Text(oc)),
              DataCell(Text(cliente)),
              DataCell(Text(fecha)),
              DataCell(
                Text(
                  serial,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text(codigo)),
              DataCell(Text(equipo)),
              DataCell(Text(responsable)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // WIDGETS REUTILIZABLES DE DISEÑO
  // ==========================================

  // 👇 AQUÍ ESTÁ LA MAGIA QUE HACE QUE LA TABLA OCUPE EL 100% 👇
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
              // ConstrainedBox fuerza a la tabla a tomar TODO el ancho disponible (menos el padding)
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
