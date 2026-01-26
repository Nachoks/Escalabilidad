// 1. CREAMOS ESTA CLASE PEQUEÑA PARA MANEJAR EL ARCHIVO
class GastoArchivo {
  final String rutaRelativa;
  final String extension;
  final String nombreOriginal;

  GastoArchivo({
    required this.rutaRelativa,
    required this.extension,
    required this.nombreOriginal,
  });

  factory GastoArchivo.fromJson(Map<String, dynamic> json) {
    return GastoArchivo(
      rutaRelativa: json['ruta_relativa'] ?? '',
      extension: json['extension'] ?? 'jpg',
      nombreOriginal: json['nombre_original'] ?? 'Archivo Adjunto',
    );
  }
}

class GastoModel {
  final int? idGasto;
  final int idRendicion;
  final String fecha;
  final int monto;
  final String? numDocumento;
  final String tipoDocumento;
  final String detalle;
  final String estado;
  final String? comentario;
  final List<GastoArchivo> fotos;

  GastoModel({
    this.idGasto,
    required this.idRendicion,
    required this.fecha,
    required this.monto,
    this.numDocumento,
    required this.tipoDocumento,
    required this.detalle,
    this.estado = 'Pendiente',
    this.comentario,
    this.fotos = const [],
  });

  factory GastoModel.fromJson(Map<String, dynamic> json) {
    // 1. Procesar la lista de archivos usando la nueva clase
    List<GastoArchivo> listaFotos = [];

    if (json['archivos'] != null) {
      listaFotos = (json['archivos'] as List)
          .map((archivoJson) => GastoArchivo.fromJson(archivoJson))
          .toList();
    }

    return GastoModel(
      idGasto: json['id_gasto'],
      idRendicion: int.parse(json['id_rendicion'].toString()),
      fecha: json['fecha'] ?? '',
      monto: int.tryParse(json['monto'].toString()) ?? 0,
      numDocumento: json['num_documento'],
      tipoDocumento: json['tipo_documento'] ?? 'Otro',
      detalle: json['detalle'] ?? 'Sin detalle',
      estado: json['estado_gasto'] ?? 'Pendiente',
      comentario: json['comentario_validador'],
      fotos: listaFotos, // Asignamos la lista de objetos
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_gasto': idGasto,
      'id_rendicion': idRendicion,
      'fecha': fecha,
      'monto': monto,
      'num_documento': numDocumento,
      'tipo_documento': tipoDocumento,
      'detalle': detalle,
      'estado_gasto': estado,
    };
  }
}
