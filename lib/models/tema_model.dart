class Tema {
  final int idTema;
  final int idUnidad;
  final String titulo;
  final int orden;
  final int intentosConsumidos;
  final String rutaRecurso;
  final String recursoBasicoTipo;
  final int idCurso;
  final int ordenUnidad;
  final int intentosDisponibles;
  final double resultado;
  final String observaciones;
  final List slideImages;

  Tema({
    required this.idTema,
    required this.idUnidad,
    required this.titulo,
    required this.orden,
    required this.intentosConsumidos,
    required this.rutaRecurso,
    required this.recursoBasicoTipo,
    required this.idCurso,
    required this.ordenUnidad,
    required this.intentosDisponibles,
    required this.resultado,
    required this.observaciones,
    required this.slideImages,
  });

  factory Tema.fromJson(Map<String, dynamic> json) {
    return Tema(
      idTema: json['id_tema'],
      idUnidad: json['id_unidad_fk'],
      titulo: json['titulo'],
      orden: json['orden'],
      intentosConsumidos: json['intentos_consumidos'] ?? 0,
      rutaRecurso: json['ruta_recurso'] ?? '',
      recursoBasicoTipo: json['recurso_basico_tipo'],
      idCurso: json['id_curso_fk'],
      ordenUnidad: json['orden_unidad'],
      intentosDisponibles: json['intentos_disponibles'],
      resultado: json['resultado'],
      observaciones: json['observaciones'] ?? '',
      slideImages: json['slide_images'] ?? [],
    );
  }

  Tema copyWith({
    int? idTema,
    int? idUnidad,
    String? titulo,
    int? orden,
    int? intentosConsumidos,
    String? rutaRecurso,
    String? recursoBasicoTipo,
    int? idCurso,
    int? ordenUnidad,
    int? intentosDisponibles,
    double? resultado,
    String? observaciones,
    List? slideImages,
  }) {
    return Tema(
      idTema: idTema ?? this.idTema,
      idUnidad: idUnidad ?? this.idUnidad,
      titulo: titulo ?? this.titulo,
      orden: orden ?? this.orden,
      intentosConsumidos: intentosConsumidos ?? this.intentosConsumidos,
      rutaRecurso: rutaRecurso ?? this.rutaRecurso,
      recursoBasicoTipo: recursoBasicoTipo ?? this.recursoBasicoTipo,
      idCurso: idCurso ?? this.idCurso,
      ordenUnidad: ordenUnidad ?? this.ordenUnidad,
      intentosDisponibles: intentosDisponibles ?? this.intentosDisponibles,
      resultado: resultado ?? this.resultado,
      observaciones: observaciones ?? this.observaciones,
      slideImages: slideImages ?? this.slideImages,
    );
  }
}
