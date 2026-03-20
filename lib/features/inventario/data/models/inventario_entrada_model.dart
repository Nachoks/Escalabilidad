import 'producto_model.dart';

class InventarioEntradaModel {
  final int idEntrada;
  final int idProducto;
  final int idResponsable;
  final String? ocProveedor;
  final String serial;
  final String estadoSerial;

  // Agregamos el objeto Producto opcional.
  // Laravel nos lo enviará cuando llamemos a consultarSerial() gracias al "with('producto')"
  final ProductoModel? producto;

  InventarioEntradaModel({
    required this.idEntrada,
    required this.idProducto,
    required this.idResponsable,
    this.ocProveedor,
    required this.serial,
    required this.estadoSerial,
    this.producto,
  });

  factory InventarioEntradaModel.fromJson(Map<String, dynamic> json) {
    return InventarioEntradaModel(
      idEntrada: json['id_entrada'],
      idProducto: json['id_producto'],
      idResponsable: json['id_responsable'],
      ocProveedor: json['oc_proveedor'],
      serial: json['serial'],
      estadoSerial: json['estado_serial'] ?? 'Disponible',
      producto: json['producto'] != null
          ? ProductoModel.fromJson(json['producto'])
          : null,
    );
  }
}
