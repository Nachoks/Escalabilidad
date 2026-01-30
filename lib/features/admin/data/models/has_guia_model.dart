class HasGuiaModel {
  final int idHasGuia;
  final int idOcCliente;
  final String codHasGuia;
  final List<HasGuiaArchivoModel> archivos; // Lista de archivos (fotos)

  HasGuiaModel({
    required this.idHasGuia,
    required this.idOcCliente,
    required this.codHasGuia,
    this.archivos = const [],
  });

  factory HasGuiaModel.fromJson(Map<String, dynamic> json) {
    return HasGuiaModel(
      idHasGuia: json['id_has_guia'] is int
          ? json['id_has_guia']
          : int.tryParse(json['id_has_guia'].toString()) ?? 0,

      idOcCliente: json['id_oc_cliente'] is int
          ? json['id_oc_cliente']
          : int.tryParse(json['id_oc_cliente'].toString()) ?? 0,

      codHasGuia: json['cod_has_guia']?.toString() ?? '',

      // Mapeo de archivos
      archivos:
          (json['archivos'] as List<dynamic>?)
              ?.map((e) => HasGuiaArchivoModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_has_guia': idHasGuia,
      'id_oc_cliente': idOcCliente,
      'cod_has_guia': codHasGuia,
      'archivos': archivos.map((x) => x.toJson()).toList(),
    };
  }
}

// --- SUB-MODELO PARA EL ARCHIVO ---
class HasGuiaArchivoModel {
  final int idArchivo;
  final String nombreOriginal;
  final String rutaRelativa;

  HasGuiaArchivoModel({
    required this.idArchivo,
    required this.nombreOriginal,
    required this.rutaRelativa,
  });

  factory HasGuiaArchivoModel.fromJson(Map<String, dynamic> json) {
    return HasGuiaArchivoModel(
      idArchivo: json['id_archivo'] is int
          ? json['id_archivo']
          : int.tryParse(json['id_archivo'].toString()) ?? 0,

      nombreOriginal: json['nombre_original']?.toString() ?? '',
      rutaRelativa: json['ruta_relativa']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_archivo': idArchivo,
      'nombre_original': nombreOriginal,
      'ruta_relativa': rutaRelativa,
    };
  }
}
