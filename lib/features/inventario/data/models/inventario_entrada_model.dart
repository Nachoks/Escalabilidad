import 'package:somnolence_app/features/auth/data/models/user_model.dart';

import 'producto_model.dart';

class InventarioEntradaModel {
  final int idEntrada;
  final int idProducto;
  final int idResponsable;
  final String? ocProveedor;
  final String serial;
  final String estadoSerial;

  final ProductoModel? producto;
  // 👇 NUEVOS CAMPOS AÑADIDOS 👇
  final User? responsable;
  final String? createdAt;

  InventarioEntradaModel({
    required this.idEntrada,
    required this.idProducto,
    required this.idResponsable,
    this.ocProveedor,
    required this.serial,
    required this.estadoSerial,
    this.producto,
    this.responsable,
    this.createdAt,
  });

  factory InventarioEntradaModel.fromJson(Map<String, dynamic> json) {
    return InventarioEntradaModel(
      idEntrada: json['id_entrada'],
      idProducto: json['id_producto'],
      idResponsable: json['id_responsable'],
      ocProveedor: json['oc_proveedor'],
      serial: json['serial'],
      estadoSerial: json['estado_serial'] ?? 'Disponible',
      producto: json['producto'] != null
          ? ProductoModel.fromJson(json['producto'])
          : null,
      // 👇 ATRAPAMOS LOS DATOS DEL BACKEND 👇
      responsable: json['responsable'] != null
          ? User.fromJson(json['responsable'])
          : null,
      createdAt: json['created_at']?.toString(),
    );
  }
}
