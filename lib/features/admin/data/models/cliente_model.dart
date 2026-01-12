class ClienteModel {
  final int? idCliente;
  final String nombreCliente;
  final String? codCliente;
  final String? nombreRepresentante;
  final String? correoRepresentante;

  ClienteModel({
    this.idCliente,
    required this.nombreCliente,
    this.codCliente,
    this.nombreRepresentante,
    this.correoRepresentante,
  });

  // Convertir a JSON para enviar al Backend
  Map<String, dynamic> toJson() {
    return {
      'nombre_cliente': nombreCliente,
      'cod_cliente': codCliente,
      'nombre_representante': nombreRepresentante,
      'correo_representante': correoRepresentante,
    };
  }

  // Recibir del Backend (Factory)
  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      idCliente: json['id_cliente'],
      nombreCliente: json['nombre_cliente'],
      codCliente: json['cod_cliente'],
      nombreRepresentante: json['nombre_representante'],
      correoRepresentante: json['correo_representante'],
    );
  }
}
