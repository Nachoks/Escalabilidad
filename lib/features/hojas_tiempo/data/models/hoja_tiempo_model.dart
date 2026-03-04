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
  final String? observacion;
  final String? nombrePersonal;

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
    this.observacion,
    this.servicio,
    this.ocCliente,
    this.dias,
    this.nombreCliente,
    this.nombrePersonal,
  });

  factory HojaTiempoSemana.fromJson(Map<String, dynamic> json) {
    // Armamos el nombre completo usando los datos de la tabla 'personal'
    String nombre = json['usuario_nombre']?.toString() ?? '';
    String apellido = json['usuario_apellido']?.toString() ?? '';
    String nombreComp = "$nombre $apellido".trim();

    // Fallback: Si el usuario no tiene personal asignado en la BD, mostramos el ID
    if (nombreComp.isEmpty) {
      nombreComp = "Usuario ID: ${json['id_usuario']}";
    }

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
      observacion: json['observacion'],
      servicio: json['servicio'],
      nombreCliente: json['nombre_cliente'] ?? 'Cliente Desconocido',
      nombreServicio: json['nombre_servicio'],
      ocCliente: json['oc_cliente'],
      nombrePersonal: nombreComp,
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
  final String? area;
  final String tipoDia;
  final String? horarioInicio;
  final String? horarioFin;
  final double viajeHoras;
  final List<HojaTiempoActividad>? actividades;

  // --- NUEVOS CAMPOS AÑADIDOS PARA VALIDACIÓN DIARIA ---
  final String estado;
  final String? observacion;

  // --- CAMPOS OPCIONALES PARA LA VISTA DEL ADMIN (Pendientes Diarias) ---
  final int? numeroHct;
  final int? numeroSemana;
  final String? nombreCliente;
  final String? nombreServicio;
  final String? nombrePersonal;
  final int? idUsuario;

  HojaTiempoDiaria({
    required this.idHojaDiaria,
    required this.idHojaSemana,
    required this.fecha,
    required this.lugar,
    this.area,
    required this.tipoDia,
    this.horarioInicio,
    this.horarioFin,
    required this.viajeHoras,
    this.actividades,
    this.estado = 'Borrador', // Por defecto será Borrador
    this.observacion,
    this.numeroHct,
    this.numeroSemana,
    this.nombreCliente,
    this.nombreServicio,
    this.nombrePersonal,
    this.idUsuario,
  });

  factory HojaTiempoDiaria.fromJson(Map<String, dynamic> json) {
    // Si viene la info del personal (como en la ruta del Admin), la mapeamos
    String nombre = json['usuario_nombre']?.toString() ?? '';
    String apellido = json['usuario_apellido']?.toString() ?? '';
    String nombreComp = "$nombre $apellido".trim();
    if (nombreComp.isEmpty && json['id_usuario'] != null) {
      nombreComp = "Usuario ID: ${json['id_usuario']}";
    }

    return HojaTiempoDiaria(
      idHojaDiaria: json['id_hoja_diaria'],
      idHojaSemana: json['id_hoja_semana'],
      fecha: DateTime.parse(json['fecha']),
      lugar: json['lugar'] ?? 'OFICINA',
      area: json['area'],
      tipoDia: json['tipo_dia'] ?? 'HABIL',
      horarioInicio: json['horario_inicio'],
      horarioFin: json['horario_fin'],
      viajeHoras: double.tryParse(json['viaje_horas'].toString()) ?? 0.0,

      // Capturamos el estado y la observación (NUEVO)
      estado: json['estado'] ?? 'Borrador',
      observacion: json['observacion'],

      // Capturamos los datos extras si vienen desde la consulta del Admin (NUEVO)
      numeroHct: json['numero_hct'],
      numeroSemana: json['numero_semana'],
      nombreCliente: json['nombre_cliente'],
      nombreServicio: json['nombre_servicio'],
      nombrePersonal: nombreComp.isNotEmpty ? nombreComp : null,
      idUsuario: json['id_usuario'],

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
  final double horasHabiles;
  final double horasNoHabiles;
  final double horasFestivas;

  HojaTiempoActividad({
    required this.idActividad,
    required this.horaInicio,
    required this.horaFin,
    required this.descripcion,
    this.horasHabiles = 0.0,
    this.horasNoHabiles = 0.0,
    this.horasFestivas = 0.0,
  });

  factory HojaTiempoActividad.fromJson(Map<String, dynamic> json) {
    return HojaTiempoActividad(
      idActividad: json['id_actividad'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      descripcion: json['descripcion'],
      horasHabiles:
          double.tryParse(json['horas_habiles']?.toString() ?? '0') ?? 0.0,
      horasNoHabiles:
          double.tryParse(json['horas_no_habiles']?.toString() ?? '0') ?? 0.0,
      horasFestivas:
          double.tryParse(json['horas_festivas']?.toString() ?? '0') ?? 0.0,
    );
  }
}
