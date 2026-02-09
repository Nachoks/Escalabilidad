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
    String nombreEncontrado = 'Usuario ${json['id_usuario']}';

    if (json['usuario'] != null) {
      // CAMBIO: Prioridad absoluta al Nombre + Apellido
      if (json['usuario']['nombre'] != null) {
        nombreEncontrado = json['usuario']['nombre'];

        // Si hay apellido, lo concatenamos
        if (json['usuario']['apellido'] != null) {
          nombreEncontrado += ' ${json['usuario']['apellido']}';
        }
      }
      // Si no tiene nombre/apellido, probamos 'name' (común en Laravel)
      else if (json['usuario']['name'] != null) {
        nombreEncontrado = json['usuario']['name'];
      }
      // Última opción: nombre de usuario (nickname)
      else if (json['usuario']['nombre_usuario'] != null) {
        nombreEncontrado = json['usuario']['nombre_usuario'];
      }
    }

    return RendicionModel(
      idRendicion: json['id_rendicion'],
      fecha: json['fecha'] ?? '',
      proposito: json['proposito'] ?? 'Sin Propósito',
      montoEntregado:
          int.tryParse(json['monto_entregado']?.toString() ?? '0') ?? 0,
      estado: json['estado'] ?? 'Borrador',
      centroCosto: json['centro_costo'],
      idServicio: int.tryParse(json['id_servicio']?.toString() ?? '0') ?? 0,
      idUsuario: int.tryParse(json['id_usuario']?.toString() ?? '0'),
      nombreUsuario:
          nombreEncontrado, // <--- Aquí se asigna el nombre corregido
      totalGastado: int.tryParse(json['total_gastado']?.toString() ?? '0') ?? 0,
      saldo: int.tryParse(json['saldo']?.toString() ?? '0') ?? 0,
      rutaComprobante: json['ruta_comprobante'],
      servicio: json['servicio'] != null
          ? ServicioModel.fromJson(json['servicio'])
          : null,
    );
  }
}
