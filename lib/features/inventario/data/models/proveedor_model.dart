import 'contacto_proveedor_model.dart'; // 👇 Importamos el nuevo modelo

class ProveedorModel {
  final int idProveedor;
  final String nombreProveedor;
  final List<ContactoProveedorModel> contactos;

  ProveedorModel({
    required this.idProveedor,
    required this.nombreProveedor,
    this.contactos = const [],
  });

  factory ProveedorModel.fromJson(Map<String, dynamic> json) {
    return ProveedorModel(
      idProveedor: json['id_proveedor'],
      nombreProveedor: json['nombre_proveedor'],
      contactos: json['contactos'] != null
          ? (json['contactos'] as List)
                .map((i) => ContactoProveedorModel.fromJson(i))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_proveedor': idProveedor,
      'nombre_proveedor': nombreProveedor,
      'contactos': contactos.map((c) => c.toJson()).toList(),
    };
  }
}
