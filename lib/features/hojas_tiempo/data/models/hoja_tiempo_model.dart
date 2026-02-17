class HojaTiempoSemana {
  final String? nombreCliente;
  final int? idHojaSemana;
  final int idUsuario;
  final int idServicio;
  final int idOcCliente;
  final int numeroHct;
  final String? nombreComprobante;
  final String? centroCosto;
  final int? numeroSemana;
  final String fechaInicio;
  final String fechaFin;
  final String estado;
  final String? nombreServicio;

  // Relaciones
  final Map<String, dynamic>? servicio;
  final Map<String, dynamic>? ocCliente;
  final List<HojaTiempoDiaria>? dias;

  HojaTiempoSemana({
    this.idHojaSemana,
    required this.idUsuario,
    required this.idServicio,
    required this.idOcCliente,
    required this.numeroHct,
    this.nombreComprobante,
    this.centroCosto,
    this.numeroSemana,
    this.nombreServicio,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    this.servicio,
    this.ocCliente,
    this.dias,
    this.nombreCliente,
  });

  factory HojaTiempoSemana.fromJson(Map<String, dynamic> json) {
    return HojaTiempoSemana(
      idHojaSemana: json['id_hoja_semana'],
      idUsuario: json['id_usuario'],
      idServicio: json['id_servicio'],
      idOcCliente: json['id_oc_cliente'],
      numeroHct: json['numero_hct'] ?? 0,
      nombreComprobante: json['nombre_comprobante'],
      centroCosto: json['centro_costo'],
      numeroSemana: json['numero_semana'],
      fechaInicio: json['fecha_inicio'],
      fechaFin: json['fecha_fin'],
      estado: json['estado'] ?? 'Borrador',
      servicio: json['servicio'],
      nombreCliente: json['nombre_cliente'] ?? 'Cliente Desconocido',
      nombreServicio: json['nombre_servicio'],
      ocCliente:
          json['oc_cliente'], // Ojo: en Laravel la relación se llama ocCliente, pero a veces Eloquent lo pasa a snake_case en JSON.
      dias: json['dias'] != null
          ? (json['dias'] as List)
                .map((i) => HojaTiempoDiaria.fromJson(i))
                .toList()
          : null,
    );
  }
}

class HojaTiempoDiaria {
  final int idHojaDiaria;
  final int idHojaSemana;
  final DateTime fecha;
  final String lugar;
  final String tipoDia;
  final String? horarioInicio;
  final String? horarioFin;
  final double viajeHoras;
  final List<HojaTiempoActividad>? actividades;

  HojaTiempoDiaria({
    required this.idHojaDiaria,
    required this.idHojaSemana,
    required this.fecha,
    required this.lugar,
    required this.tipoDia,
    this.horarioInicio,
    this.horarioFin,
    required this.viajeHoras,
    this.actividades,
  });

  factory HojaTiempoDiaria.fromJson(Map<String, dynamic> json) {
    return HojaTiempoDiaria(
      idHojaDiaria: json['id_hoja_diaria'],
      idHojaSemana: json['id_hoja_semana'],
      fecha: DateTime.parse(json['fecha']),
      lugar: json['lugar'] ?? 'OFICINA',
      tipoDia: json['tipo_dia'] ?? 'HABIL',
      horarioInicio: json['horario_inicio'],
      horarioFin: json['horario_fin'],
      viajeHoras: double.tryParse(json['viaje_horas'].toString()) ?? 0.0,
      actividades: json['actividades'] != null
          ? (json['actividades'] as List)
                .map((i) => HojaTiempoActividad.fromJson(i))
                .toList()
          : null,
    );
  }
}

class HojaTiempoActividad {
  final int idActividad;
  final String horaInicio;
  final String horaFin;
  final String descripcion;

  HojaTiempoActividad({
    required this.idActividad,
    required this.horaInicio,
    required this.horaFin,
    required this.descripcion,
  });

  factory HojaTiempoActividad.fromJson(Map<String, dynamic> json) {
    return HojaTiempoActividad(
      idActividad: json['id_actividad'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      descripcion: json['descripcion'],
    );
  }
}
