class ContactoProveedorModel {
  final int? idContacto;
  final String nombreContacto;
  final String? cargo;
  final String? numeroContacto;
  final String? correoContacto;

  ContactoProveedorModel({
    this.idContacto,
    this.cargo,
    required this.nombreContacto,
    this.numeroContacto,
    this.correoContacto,
  });

  factory ContactoProveedorModel.fromJson(Map<String, dynamic> json) {
    return ContactoProveedorModel(
      idContacto: json['id_contacto'],
      nombreContacto: json['nombre_contacto'] ?? 'Sin Nombre',
      cargo: json['cargo'],
      numeroContacto: json['numero_contacto'],
      correoContacto: json['correo_contacto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idContacto != null) 'id_contacto': idContacto,
      'nombre_contacto': nombreContacto,
      'cargo': cargo,
      'numero_contacto': numeroContacto,
      'correo_contacto': correoContacto,
    };
  }
}
