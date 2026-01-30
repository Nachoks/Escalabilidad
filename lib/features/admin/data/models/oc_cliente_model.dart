import 'has_guia_model.dart'; // Importamos el modelo hijo

class OcClienteModel {
  final int idOcCliente;
  final int idServicio;
  final String codOcCliente;
  final List<HasGuiaModel> guias; // Lista anidada de HAS

  OcClienteModel({
    required this.idOcCliente,
    required this.idServicio,
    required this.codOcCliente,
    this.guias = const [],
  });

  // Convertir de JSON (Backend) a Objeto (Flutter)
  factory OcClienteModel.fromJson(Map<String, dynamic> json) {
    return OcClienteModel(
      idOcCliente: json['id_oc_cliente'] is int
          ? json['id_oc_cliente']
          : int.tryParse(json['id_oc_cliente'].toString()) ?? 0,

      idServicio: json['id_servicio'] is int
          ? json['id_servicio']
          : int.tryParse(json['id_servicio'].toString()) ?? 0,

      codOcCliente: json['cod_oc_cliente']?.toString() ?? '',

      // Mapeo seguro de la lista de guías
      guias:
          (json['guias'] as List<dynamic>?)
              ?.map((e) => HasGuiaModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  // Convertir de Objeto a JSON (si necesitas enviarlo)
  Map<String, dynamic> toJson() {
    return {
      'id_oc_cliente': idOcCliente,
      'id_servicio': idServicio,
      'cod_oc_cliente': codOcCliente,
      'guias': guias.map((x) => x.toJson()).toList(),
    };
  }
}
