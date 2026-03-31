class ContactoProveedorModel {
  final int? idContacto;
  final String nombreContacto;
  final String? numeroContacto;
  final String? correoContacto;

  ContactoProveedorModel({
    this.idContacto,
    required this.nombreContacto,
    this.numeroContacto,
    this.correoContacto,
  });

  factory ContactoProveedorModel.fromJson(Map<String, dynamic> json) {
    return ContactoProveedorModel(
      idContacto: json['id_contacto'],
      nombreContacto: json['nombre_contacto'] ?? 'Sin Nombre',
      numeroContacto: json['numero_contacto'],
      correoContacto: json['correo_contacto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idContacto != null) 'id_contacto': idContacto,
      'nombre_contacto': nombreContacto,
      'numero_contacto': numeroContacto,
      'correo_contacto': correoContacto,
    };
  }
}
