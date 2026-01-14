class RendicionModel {
  final int? idRendicion;
  final String fecha;
  final String proposito;
  final int montoEntregado;
  final String estado;
  final String? centroCosto;
  final int idServicio;
  final int? idUsuario;

  // Campos calculados por el Backend
  final int totalGastado;
  final int saldo;

  RendicionModel({
    this.idRendicion,
    required this.fecha,
    required this.proposito,
    this.montoEntregado = 0,
    this.estado = 'Borrador',
    this.centroCosto,
    required this.idServicio,
    this.idUsuario,
    this.totalGastado = 0,
    this.saldo = 0,
  });

  factory RendicionModel.fromJson(Map<String, dynamic> json) {
    return RendicionModel(
      idRendicion: json['id_rendicion'],
      fecha: json['fecha'] ?? '',
      proposito: json['proposito'] ?? '',
      // Manejo seguro de tipos (int vs String)
      montoEntregado:
          int.tryParse(json['monto_entregado']?.toString() ?? '0') ?? 0,
      estado: json['estado'] ?? 'Borrador',
      centroCosto: json['centro_costo'],
      idServicio: int.tryParse(json['id_servicio']?.toString() ?? '0') ?? 0,
      idUsuario: int.tryParse(json['id_usuario']?.toString() ?? '0'),

      // Datos financieros
      totalGastado: int.tryParse(json['total_gastado']?.toString() ?? '0') ?? 0,
      saldo: int.tryParse(json['saldo']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_servicio': idServicio,
      'fecha': fecha,
      'proposito': proposito,
      'monto_entregado': montoEntregado,
    };
  }
}
