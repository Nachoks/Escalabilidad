class ServicioModel {
  final int? idServicio;
  final String nombreServicio;
  final int idCliente;
  final int idArea;
  final String? centroCosto;
  final String? fechaInicio;
  final String? fechaTermino;

  // --- NUEVOS CAMPOS ---
  final String? facturacion;
  final String estadoServicio;
  final List<dynamic> ordenesCompra; // Lista de OCs
  final List<dynamic> guias; // Lista de HAS

  ServicioModel({
    this.idServicio,
    required this.nombreServicio,
    required this.idCliente,
    required this.idArea,
    this.centroCosto,
    this.fechaInicio,
    this.fechaTermino,
    this.facturacion,
    this.estadoServicio = 'Activo',
    this.ordenesCompra = const [],
    this.guias = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_servicio': nombreServicio,
      'id_cliente': idCliente,
      'id_area': idArea,
      'fecha_inicio': fechaInicio,
      'fecha_termino': fechaTermino,
      // No enviamos OC ni guias aquí porque se agregan por separado
    };
  }

  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
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

      centroCosto: json['centro_costo']?.toString(),
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaTermino: json['fecha_termino']?.toString(),

      // --- MAPPING NUEVOS CAMPOS ---
      facturacion: json['facturacion']?.toString(),
      estadoServicio: json['estado_servicio']?.toString() ?? 'Activo',

      // Laravel suele devolver las relaciones como 'ordenes_compra' (snake_case)
      ordenesCompra: json['ordenes_compra'] ?? [],
      guias: json['guias'] ?? [],
    );
  }
}
