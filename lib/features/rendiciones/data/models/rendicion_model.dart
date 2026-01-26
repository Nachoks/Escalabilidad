import 'package:somnolence_app/features/admin/data/models/servicio_model.dart'; // <--- 1. NO OLVIDES ESTE IMPORT

class RendicionModel {
  final int? idRendicion;
  final String fecha;
  final String proposito;
  final int montoEntregado;
  final String estado;
  final String? centroCosto;
  final int idServicio;
  final int? idUsuario;
  final String? rutaComprobante;
  final String nombreUsuario;
  final int totalGastado;
  final int saldo;

  // La propiedad que necesitas para el Dialog
  final ServicioModel? servicio;

  RendicionModel({
    this.idRendicion,
    required this.fecha,
    required this.proposito,
    this.montoEntregado = 0,
    this.estado = 'Borrador',
    this.centroCosto,
    required this.idServicio,
    this.idUsuario,
    this.nombreUsuario = 'Usuario Desconocido',
    this.totalGastado = 0,
    this.saldo = 0,
    this.rutaComprobante,
    this.servicio,
  });

  factory RendicionModel.fromJson(Map<String, dynamic> json) {
    // Lógica para encontrar el nombre
    String nombreEncontrado = 'Usuario ${json['id_usuario']}';

    if (json['usuario'] != null) {
      if (json['usuario']['nombre_usuario'] != null) {
        nombreEncontrado = json['usuario']['nombre_usuario'];
      } else if (json['usuario']['name'] != null) {
        nombreEncontrado = json['usuario']['name'];
      } else if (json['usuario']['nombre'] != null) {
        nombreEncontrado = json['usuario']['nombre'];
      }
    }

    return RendicionModel(
      idRendicion: json['id_rendicion'],
      fecha: json['fecha'] ?? '',
      proposito: json['proposito'] ?? 'Sin Propósito',
      montoEntregado:
          int.tryParse(json['monto_entregado']?.toString() ?? '0') ?? 0,
      estado: json['estado'] ?? 'Borrador',
      centroCosto:
          json['centro_costo'], // A veces viene directo, a veces dentro de servicio
      idServicio: int.tryParse(json['id_servicio']?.toString() ?? '0') ?? 0,
      idUsuario: int.tryParse(json['id_usuario']?.toString() ?? '0'),
      nombreUsuario: nombreEncontrado,
      totalGastado: int.tryParse(json['total_gastado']?.toString() ?? '0') ?? 0,
      saldo: int.tryParse(json['saldo']?.toString() ?? '0') ?? 0,
      rutaComprobante: json['ruta_comprobante'],

      // 2. ¡ESTA ES LA LÍNEA QUE FALTABA!
      // Convierte el JSON anidado en un objeto ServicioModel real
      servicio: json['servicio'] != null
          ? ServicioModel.fromJson(json['servicio'])
          : null,
    );
  }
}
