class InventarioSalidaModel {
  final int idSalida;
  final int idEntrada;
  final int idProducto;
  final int idCliente;
  final int idResponsable;
  final String? ocCliente;
  final String serial;

  InventarioSalidaModel({
    required this.idSalida,
    required this.idEntrada,
    required this.idProducto,
    required this.idCliente,
    required this.idResponsable,
    this.ocCliente,
    required this.serial,
  });

  factory InventarioSalidaModel.fromJson(Map<String, dynamic> json) {
    return InventarioSalidaModel(
      idSalida: json['id_salida'],
      idEntrada: json['id_entrada'],
      idProducto: json['id_producto'],
      idCliente: json['id_cliente'],
      idResponsable: json['id_responsable'],
      ocCliente: json['oc_cliente'],
      serial: json['serial'],
    );
  }
}
