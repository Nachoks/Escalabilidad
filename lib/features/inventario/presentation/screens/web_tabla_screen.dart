import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Apenas se abre la pantalla, mandamos a cargar las 3 tablas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventarioProvider>(context, listen: false).cargarTablasWeb();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventarioProvider>(context);

    return DefaultTabController(
      length: 3, // 3 Pestañas
      child: Scaffold(
        backgroundColor: AppColors.background, // Fondo estándar de la app
        appBar: AppBar(
          // Integramos tu LogoAppbar y el título
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
          backgroundColor: AppColors.primary, // Naranja corporativo
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
            indicatorWeight: 4, // Indicador un poco más grueso para que resalte
            tabs: [
              Tab(icon: Icon(Icons.inventory), text: 'STOCK GLOBAL'),
              Tab(icon: Icon(Icons.login), text: 'HISTORIAL ENTRADAS'),
              Tab(icon: Icon(Icons.logout), text: 'HISTORIAL SALIDAS'),
            ],
          ),
        ),
        body: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary, // Spinner corporativo
                ),
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
        // Cabecera teñida con el color corporativo suave
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
              'Nombre/Descripción',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Marca', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Tot. Entradas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Tot. Salidas',
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
              'STOCK ACTUAL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: provider.listaStock.map((item) {
          final prod = item.producto;
          // Lógica de color: Rojo si falta stock, Naranja corporativo si hay stock normal
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
              DataCell(Text(item.stockMinimo.toString())),
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
            label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Código Prod.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Nombre',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Número Serie (SN)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'OC Proveedor',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Estado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: provider.listaEntradas.map((ent) {
          return DataRow(
            cells: [
              DataCell(Text('#${ent.idEntrada}')),
              DataCell(Text(ent.producto?.codigoProducto ?? 'N/A')),
              DataCell(Text(ent.producto?.nombreProducto ?? 'N/A')),
              DataCell(
                Text(
                  ent.serial,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text(ent.ocProveedor ?? '-')),
              DataCell(
                Chip(
                  label: Text(
                    ent.estadoSerial,
                    style: TextStyle(
                      fontSize: 12,
                      color: ent.estadoSerial == 'Disponible'
                          ? Colors.green[800]
                          : Colors.grey[800],
                    ),
                  ),
                  backgroundColor: ent.estadoSerial == 'Disponible'
                      ? Colors.greenAccent[100]
                      : Colors.grey[300],
                  side: BorderSide.none,
                ),
              ),
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
            label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Código Prod.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Número Serie (SN)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'OC Cliente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'ID Cliente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: provider.listaSalidas.map((sal) {
          return DataRow(
            cells: [
              DataCell(Text('#${sal.idSalida}')),
              DataCell(Text(sal.idProducto.toString())),
              DataCell(
                Text(
                  sal.serial,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text(sal.ocCliente ?? '-')),
              DataCell(Text('Cliente #${sal.idCliente}')),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // WIDGETS REUTILIZABLES DE DISEÑO
  // ==========================================

  // Envoltorio blanco con sombra para las tablas
  Widget _buildContainerTabla({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
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
        // Scroll horizontal por si la pantalla es chica
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }

  // Vista cuando no hay datos
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
