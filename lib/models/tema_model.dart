class Tema {
  final int idTema;
  final String? titulo;
  final String descripcion;
  final int duracion;
  final int orden;
  final String? estado;
  final int duracionMinutos;
  final int reactivosMostrar;
  final int idUnidad;
  final int intentosConsumidos;
  final String rutaRecurso;
  final String recursoBasicoTipo;
  final int? idTemaTipo;
  final String registroFecha;
  final int? registroUsuario;
  final String? modificacionFecha;
  final int? modificacionUsuario;
  final int idCurso;
  final int ordenUnidad;
  final int intentosDisponibles;
  final double resultado;
  final String observaciones;
  final List slideImages;
  final String recursoUrl;

  Tema({
    required this.idTema,
    required this.titulo,
    required this.descripcion,
    required this.duracion,
    required this.orden,
    required this.estado,
    required this.duracionMinutos,
    required this.reactivosMostrar,
    required this.idUnidad,
    required this.intentosConsumidos,
    required this.rutaRecurso,
    required this.recursoBasicoTipo,
    required this.idTemaTipo,
    required this.registroFecha,
    required this.registroUsuario,
    required this.modificacionFecha,
    required this.modificacionUsuario,
    required this.idCurso,
    required this.ordenUnidad,
    required this.intentosDisponibles,
    required this.resultado,
    required this.observaciones,
    required this.slideImages,
    required this.recursoUrl,
  });

  factory Tema.fromJson(Map<String, dynamic> json) {
    return Tema(
      idTema: json['id_tema'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      duracion: json['duracion'] ?? 0,
      orden: json['orden'] ?? 0,
      estado: json['estado'] ?? 'A',
      duracionMinutos: json['duracion_minutos'] ?? 0,
      reactivosMostrar: json['reactivos_mostrar'] ?? 5,
      idUnidad: json['id_unidad_fk'] ?? 0,
      intentosConsumidos: json['intentos_consumidos'] ?? 0,
      rutaRecurso: json['ruta_recurso'] ?? '',
      recursoBasicoTipo: json['recurso_basico_tipo'] ?? '',
      idTemaTipo: json['id_tema_tipo_fk'] ?? 0,
      registroFecha: json['registro_fecha'] ?? '',
      registroUsuario: json['registro_usuario'] ?? 0,
      modificacionFecha: json['modificacion_fecha'] ?? '',
      modificacionUsuario: json['modificacion_usuario'] ?? 0,
      idCurso: json['id_curso_fk'] ?? 0,
      ordenUnidad: json['orden_unidad'] ?? 0,
      intentosDisponibles: json['intentos_disponibles'] ?? 0,
      resultado: (json['resultado'] as num?)?.toDouble() ?? 0.0,
      observaciones: json['observaciones'] ?? '',
      slideImages: json['slide_images'] ?? [],
      recursoUrl: json['recurso_url'] ?? '',
    );
  }

  Tema copyWith({
    int? idTema,
    String? titulo,
    String? descripcion,
    int? duracion,
    int? orden,
    String? estado,
    int? duracionMinutos,
    int? reactivosMostrar,
    int? idUnidad,
    int? intentosConsumidos,
    String? rutaRecurso,
    String? recursoBasicoTipo,
    int? idTemaTipo,
    String? registroFecha,
    int? registroUsuario,
    String? modificacionFecha,
    int? modificacionUsuario,
    int? idCurso,
    int? ordenUnidad,
    int? intentosDisponibles,
    double? resultado,
    String? observaciones,
    List? slideImages,
    String? recursoUrl,
  }) {
    return Tema(
      idTema: idTema ?? this.idTema,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      duracion: duracion ?? this.duracion,
      orden: orden ?? this.orden,
      estado: estado ?? this.estado,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      reactivosMostrar: reactivosMostrar ?? this.reactivosMostrar,
      idUnidad: idUnidad ?? this.idUnidad,
      intentosConsumidos: intentosConsumidos ?? this.intentosConsumidos,
      rutaRecurso: rutaRecurso ?? this.rutaRecurso,
      recursoBasicoTipo: recursoBasicoTipo ?? this.recursoBasicoTipo,
      idTemaTipo: idTemaTipo ?? this.idTemaTipo,
      registroFecha: registroFecha ?? this.registroFecha,
      registroUsuario: registroUsuario ?? this.registroUsuario,
      modificacionFecha: modificacionFecha ?? this.modificacionFecha,
      modificacionUsuario: modificacionUsuario ?? this.modificacionUsuario,
      idCurso: idCurso ?? this.idCurso,
      ordenUnidad: ordenUnidad ?? this.ordenUnidad,
      intentosDisponibles: intentosDisponibles ?? this.intentosDisponibles,
      resultado: resultado ?? this.resultado,
      observaciones: observaciones ?? this.observaciones,
      slideImages: slideImages ?? this.slideImages,
      recursoUrl: recursoUrl ?? this.recursoUrl,
    );
  }
}
