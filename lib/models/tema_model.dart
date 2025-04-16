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
    );
  }
}
