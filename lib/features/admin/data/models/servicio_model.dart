import 'oc_cliente_model.dart'; // Asegúrate de importar el modelo de OC

class ServicioModel {
  final int? idServicio;
  final String nombreServicio;
  final int idCliente;
  final int idArea;
  final String? centroCosto;
  final String? fechaInicio;
  final String? fechaTermino;
  final String? facturacion;
  final String estadoServicio;

  // ✅ CAMBIO 1: Usamos una lista tipada de OcClienteModel
  final List<OcClienteModel> ocs;

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
    this.ocs = const [], // Valor por defecto
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_servicio': nombreServicio,
      'id_cliente': idCliente,
      'id_area': idArea,
      'fecha_inicio': fechaInicio,
      'fecha_termino': fechaTermino,
      'estado_servicio': estadoServicio,
      'facturacion': facturacion,
      'centro_costo': centroCosto,
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
      facturacion: json['facturacion']?.toString(),
      estadoServicio: json['estado_servicio']?.toString() ?? 'Activo',

      // ✅ CAMBIO CRÍTICO: Leemos 'ocs' (como lo manda Laravel) y convertimos a Modelos
      ocs:
          (json['ocs'] as List<dynamic>?)
              ?.map((e) => OcClienteModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
