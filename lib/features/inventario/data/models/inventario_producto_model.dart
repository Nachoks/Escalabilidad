import 'producto_model.dart';

class InventarioProductoModel {
  final int idInventario;
  final int idProducto;
  final int stockActual;
  final int stockMinimo;

  //campos para la web
  final int totalEntradas;
  final int totalSalidas;
  final ProductoModel? producto;

  InventarioProductoModel({
    required this.idInventario,
    required this.idProducto,
    required this.stockActual,
    required this.stockMinimo,
    this.totalEntradas = 0,
    this.totalSalidas = 0,
    this.producto,
  });

  factory InventarioProductoModel.fromJson(Map<String, dynamic> json) {
    return InventarioProductoModel(
      idInventario: json['id_inventario'],
      idProducto: json['id_producto'],
      stockActual: json['stock_actual'] ?? 0,
      stockMinimo: json['stock_minimo'] ?? 0,
      totalEntradas: json['total_entradas'] ?? 0,
      totalSalidas: json['total_salidas'] ?? 0,
      producto: json['producto'] != null
          ? ProductoModel.fromJson(json['producto'])
          : null,
    );
  }
}
