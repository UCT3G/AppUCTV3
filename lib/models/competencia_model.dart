class Competencia {
  final int? idUsuarioCurso;
  final int? idUsuario;
  final int? idCurso;
  final String? estado;
  final int? evaluacionUsuario;
  final double? promedio;
  final double? avance;
  final DateTime? fechaInicio;
  final DateTime? fechaTermino;
  final DateTime? fechaAsignacion;
  final DateTime? fechaLimite;
  final int? registroUsuario;
  final DateTime? registroFecha;
  final int? modificacionUsuario;
  final DateTime? modificacionFecha;
  final String? tituloCurso;
  final String? descripcionCurso;
  final int? calificacionMinima;
  final int? idMapaFuncional;
  final String? obligatorio;
  final int? idAsignacion;
  final String? motivoModificacionFecha;

  Competencia({
    this.avance,
    this.calificacionMinima,
    this.descripcionCurso,
    this.estado,
    this.evaluacionUsuario,
    this.fechaAsignacion,
    this.fechaInicio,
    this.fechaLimite,
    this.fechaTermino,
    this.idAsignacion,
    this.idCurso,
    this.idMapaFuncional,
    this.idUsuario,
    this.idUsuarioCurso,
    this.modificacionFecha,
    this.modificacionUsuario,
    this.motivoModificacionFecha,
    this.obligatorio,
    this.promedio,
    this.registroFecha,
    this.registroUsuario,
    this.tituloCurso,
  });

  static DateTime? parseDate(String? date) {
    if (date == null || date.trim().isEmpty) return null;
    return DateTime.tryParse(date);
  }

  factory Competencia.fromJson(Map<String, dynamic> json) {
    return Competencia(
      avance: (json['avance'] as num?)?.toDouble(),
      calificacionMinima: json['calificacion_minima'] ?? 0,
      descripcionCurso: json['descripcion_curso'] ?? '',
      estado: json['estado'] ?? '',
      evaluacionUsuario: json['evaluacion_usuario'] ?? 0,
      fechaAsignacion: parseDate(json['fecha_asignacion']),
      fechaInicio: parseDate(json['fecha_inicio']),
      fechaLimite: parseDate(json['fecha_limite']),
      fechaTermino: parseDate(json['fecha_termino']),
      idAsignacion: json['id_asignacion_fk'] ?? 0,
      idCurso: json['id_curso_fk'] ?? 0,
      idMapaFuncional: json['id_mapa_funcional_fk'] ?? 0,
      idUsuario: json['id_usuario_fk'] ?? 0,
      idUsuarioCurso: json['id_usuario_curso'] ?? 0,
      modificacionFecha: parseDate(json['modificacion_fecha']),
      modificacionUsuario: json['modificacion_usuario'] ?? 0,
      motivoModificacionFecha: json['motivo_modificacion_fecha'] ?? '',
      obligatorio: json['obligatorio'] ?? '',
      promedio: (json['promedio'] as num?)?.toDouble(),
      registroFecha: parseDate(json['registro_fecha']),
      registroUsuario: json['registro_usuario'] ?? 0,
      tituloCurso: json['titulo_curso'] ?? '',
    );
  }
}
