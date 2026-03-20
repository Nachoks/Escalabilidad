class ProductoModel {
  final int idProducto;
  final int idProveedor;
  final String codigoProducto;
  final String nombreProducto;
  final String marca;

  ProductoModel({
    required this.idProducto,
    required this.idProveedor,
    required this.codigoProducto,
    required this.nombreProducto,
    required this.marca,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      idProducto: json['id_producto'],
      idProveedor: json['id_proveedor'],
      codigoProducto: json['codigo_producto'],
      nombreProducto: json['nombre_producto'],
      marca: json['marca'],
    );
  }

  // Utilidad por si luego necesitamos enviarlo a Laravel
  Map<String, dynamic> toJson() {
    return {
      'id_producto': idProducto,
      'id_proveedor': idProveedor,
      'codigo_producto': codigoProducto,
      'nombre_producto': nombreProducto,
      'marca': marca,
    };
  }
}
