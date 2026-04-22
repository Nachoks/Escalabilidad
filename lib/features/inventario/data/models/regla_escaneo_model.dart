class ReglaEscaneoModel {
  final int idRegla;
  final String nombreMarca;
  final String prefijoCodigo;
  final String prefijoSerie;
  final String separadorIgnorar;

  ReglaEscaneoModel({
    required this.idRegla,
    required this.nombreMarca,
    required this.prefijoCodigo,
    required this.prefijoSerie,
    required this.separadorIgnorar,
  });

  factory ReglaEscaneoModel.fromJson(Map<String, dynamic> json) {
    return ReglaEscaneoModel(
      idRegla: json['id_regla'] ?? 0,
      nombreMarca: json['nombre_marca'] ?? '',
      prefijoCodigo: json['prefijo_codigo'] ?? '',
      prefijoSerie: json['prefijo_serie'] ?? '',
      separadorIgnorar: json['separador_ignorar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_marca': nombreMarca,
      'prefijo_codigo': prefijoCodigo,
      'prefijo_serie': prefijoSerie,
      'separador_ignorar': separadorIgnorar,
    };
  }
}
