import 'package:somnolence_app/features/admin/data/models/cliente_model.dart';
import 'package:somnolence_app/features/auth/data/models/user_model.dart';
import 'producto_model.dart';

class InventarioSalidaModel {
  final int idSalida;
  final int idEntrada;
  final int idProducto;
  final int idCliente;
  final int idResponsable;
  final String? ocCliente;
  final String serial;

  // 👇 NUEVOS CAMPOS AÑADIDOS 👇
  final User? responsable;
  final ClienteModel? cliente;
  final ProductoModel? producto;
  final String? createdAt;

  InventarioSalidaModel({
    required this.idSalida,
    required this.idEntrada,
    required this.idProducto,
    required this.idCliente,
    required this.idResponsable,
    this.ocCliente,
    required this.serial,
    this.responsable,
    this.cliente,
    this.producto,
    this.createdAt,
  });

  factory InventarioSalidaModel.fromJson(Map<String, dynamic> json) {
    return InventarioSalidaModel(
      idSalida: json['id_salida'],
      idEntrada: json['id_entrada'],
      idProducto: json['id_producto'],
      idCliente: json['id_cliente'],
      idResponsable: json['id_responsable'],
      ocCliente: json['oc_cliente'],
      serial: json['serial'],
      // 👇 ATRAPAMOS LOS DATOS DEL BACKEND 👇
      responsable: json['responsable'] != null
          ? User.fromJson(json['responsable'])
          : null,
      cliente: json['cliente'] != null
          ? ClienteModel.fromJson(json['cliente'])
          : null,
      producto: json['producto'] != null
          ? ProductoModel.fromJson(json['producto'])
          : null,
      createdAt: json['created_at']?.toString(),
    );
  }
}
