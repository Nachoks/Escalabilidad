class AreaModel {
  final int idArea;
  final String nombreArea;
  final int codigoArea;

  AreaModel({
    required this.idArea,
    required this.nombreArea,
    required this.codigoArea,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      idArea: json['id_area'],
      nombreArea: json['nombre_area'],
      codigoArea: json['codigo_area'],
    );
  }
}
