class ServicioModel {
  final int? idServicio;
  final String nombreServicio;
  final int idCliente;
  final int idArea; // 🔥 Este es el campo vital para tu nueva lógica
  final String?
  centroCosto; // Este lo recibimos generado del backend (XX-Y-ZZZ)
  final String? fechaInicio;
  final String? fechaTermino;

  ServicioModel({
    this.idServicio,
    required this.nombreServicio,
    required this.idCliente,
    required this.idArea,
    this.centroCosto,
    this.fechaInicio,
    this.fechaTermino,
  });

  // Para enviar al Backend (POST)
  Map<String, dynamic> toJson() {
    return {
      'nombre_servicio': nombreServicio,
      'id_cliente': idCliente,
      'id_area': idArea, // Enviamos el ID del área seleccionada (ej: 2)
      'fecha_inicio': fechaInicio,
      'fecha_termino': fechaTermino,
    };
  }

  // Para recibir del Backend (GET)
  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      // int.tryParse asegura que si viene "1" (String) lo pase a 1 (Int)
      idServicio: json['id_servicio'] is int
          ? json['id_servicio']
          : int.tryParse(json['id_servicio'].toString()),

      nombreServicio: json['nombre_servicio']?.toString() ?? "Sin Nombre",

      idCliente: json['id_cliente'] is int
          ? json['id_cliente']
          : int.tryParse(json['id_cliente'].toString()) ?? 0,

      idArea: json['id_area'] is int
          ? json['id_area']
          : int.tryParse(json['id_area'].toString()) ?? 0,

      centroCosto: json['centro_costo']?.toString(), // Puede ser null
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaTermino: json['fecha_termino']?.toString(),
    );
  }
}
