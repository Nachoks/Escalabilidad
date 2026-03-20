class ProveedorModel {
  final int idProveedor;
  final String nombreProveedor;
  final String? numeroContacto;
  final String? correoContacto;

  ProveedorModel({
    required this.idProveedor,
    required this.nombreProveedor,
    this.numeroContacto,
    this.correoContacto,
  });

  factory ProveedorModel.fromJson(Map<String, dynamic> json) {
    return ProveedorModel(
      idProveedor: json['id_proveedor'],
      nombreProveedor: json['nombre_proveedor'],
      numeroContacto: json['numero_contacto'],
      correoContacto: json['correo_contacto'],
    );
  }

  // Utilidad para enviar los datos a Laravel al crear o editar
  Map<String, dynamic> toJson() {
    return {
      'id_proveedor': idProveedor,
      'nombre_proveedor': nombreProveedor,
      'numero_contacto': numeroContacto,
      'correo_contacto': correoContacto,
    };
  }
}
