class Competencia {
  final int idUsuarioCurso;
  final int idUsuario;
  final int idCurso;
  final String estado;
  final int evaluacionUsuario;
  final double promedio;
  final double avance;
  final DateTime fechaInicio;
  final DateTime fechaTermino;
  final DateTime fechaAsignacion;
  final DateTime fechaLimite;
  final int registroUsuario;
  final DateTime registroFecha;
  final int modificacionUsuario;
  final DateTime modificacionFecha;
  final String tituloCurso;
  final String descripcionCurso;
  final int calificacionMinima;
  final int idMapaFuncional;
  final String obligatorio;
  final int idAsignacion;
  final String motivoModificacionFecha;

  Competencia({
    required this.avance,
    required this.calificacionMinima,
    required this.descripcionCurso,
    required this.estado,
    required this.evaluacionUsuario,
    required this.fechaAsignacion,
    required this.fechaInicio,
    required this.fechaLimite,
    required this.fechaTermino,
    required this.idAsignacion,
    required this.idCurso,
    required this.idMapaFuncional,
    required this.idUsuario,
    required this.idUsuarioCurso,
    required this.modificacionFecha,
    required this.modificacionUsuario,
    required this.motivoModificacionFecha,
    required this.obligatorio,
    required this.promedio,
    required this.registroFecha,
    required this.registroUsuario,
    required this.tituloCurso,
  });

  factory Competencia.fromJson(Map<String, dynamic> json) {
    return Competencia(
      avance: json['avance'],
      calificacionMinima: json['calificacion_minima'],
      descripcionCurso: json['descripcion_curso'],
      estado: json['estado'],
      evaluacionUsuario: json['evaluacion_usuario'],
      fechaAsignacion: json['fecha_asignacion'],
      fechaInicio: json['fecha_inicio'],
      fechaLimite: json['fecha_limite'],
      fechaTermino: json['fecha_termino'],
      idAsignacion: json['id_asignacion_fk'],
      idCurso: json['id_curso_fk'],
      idMapaFuncional: json['id_mapa_funcional_fk'],
      idUsuario: json['id_usuario_fk'],
      idUsuarioCurso: json['id_usuario_curso'],
      modificacionFecha: json['modificacion_fecha'],
      modificacionUsuario: json['modificacion_usuario'],
      motivoModificacionFecha: json['motivo_modificacion_fecha'],
      obligatorio: json['obligatorio'],
      promedio: json['promedio'],
      registroFecha: json['registro_fecha'],
      registroUsuario: json['registro_usuario'],
      tituloCurso: json['titulo_curso'],
    );
  }
}
