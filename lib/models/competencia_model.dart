class Competencia {
  final int? idUsuarioCurso;
  final String? titulo;
  final double? promedio;
  final double? avance;
  final String? descripcion;
  final int? idCurso;
  final int? idUsuarioFk;
  final int? areaTematica;
  final int? idMapaFuncionalFk;
  final String? esObligatoria;
  final String? idAreamfFk;
  final DateTime? fechaLimite;
  final int? calificacionMinima;
  final List<Map<String, dynamic>>? mapaFuncional;

  Competencia({
    this.avance,
    this.calificacionMinima,
    this.fechaLimite,
    this.idCurso,
    this.idUsuarioCurso,
    this.promedio,
    this.titulo,
    this.descripcion,
    this.idUsuarioFk,
    this.areaTematica,
    this.idMapaFuncionalFk,
    this.esObligatoria,
    this.idAreamfFk,
    this.mapaFuncional,
  });

  static DateTime? parseDate(String? date) {
    if (date == null || date.trim().isEmpty) return null;
    return DateTime.tryParse(date);
  }

  factory Competencia.fromJson(Map<String, dynamic> json) {
    return Competencia(
      idUsuarioCurso: json['id_usuario_curso'],
      titulo: json['titulo'],
      promedio: (json['promedio'] as num?)?.toDouble(),
      avance: (json['avance'] as num?)?.toDouble(),
      descripcion: json['descripcion'],
      idCurso: json['id_curso'],
      idUsuarioFk: json['id_usuario_fk'],
      areaTematica: json['area_tematica'],
      idMapaFuncionalFk: json['id_mapa_funcional_fk'],
      esObligatoria: json['es_obligatoria'],
      idAreamfFk: json['id_areamf_fk']?.toString(),
      fechaLimite: parseDate(json['fecha_limite']),
      calificacionMinima: json['calificacion_minima'] ?? 0,
      mapaFuncional:
          (json['mapa_funcional'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList(),
    );
  }

  Competencia copyWith({
    int? idUsuarioCurso,
    String? titulo,
    double? promedio,
    double? avance,
    String? descripcion,
    int? idCurso,
    int? idUsuarioFk,
    int? areaTematica,
    int? idMapaFuncionalFk,
    String? esObligatoria,
    String? idAreamfFk,
    DateTime? fechaLimite,
    int? calificacionMinima,
    List<Map<String, dynamic>>? mapaFuncional,
  }) {
    return Competencia(
      avance: avance ?? this.avance,
      calificacionMinima: calificacionMinima ?? this.calificacionMinima,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      idCurso: idCurso ?? this.idCurso,
      idUsuarioCurso: idUsuarioCurso ?? this.idUsuarioCurso,
      promedio: promedio ?? this.promedio,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      areaTematica: areaTematica ?? this.areaTematica,
      idMapaFuncionalFk: idMapaFuncionalFk ?? this.idMapaFuncionalFk,
      esObligatoria: esObligatoria ?? this.esObligatoria,
      idAreamfFk: idAreamfFk ?? this.idAreamfFk,
      mapaFuncional: mapaFuncional ?? this.mapaFuncional
    );
  }
}
