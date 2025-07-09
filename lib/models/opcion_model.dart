class Opcion {
  final int idOpcion;
  final int idReactivo;
  final int orden;
  final String correcta;
  final String descripcion;
  final int grupo;
  final String estado;
  final double poderacion;
  final String imagen;

  Opcion({
    required this.idOpcion,
    required this.idReactivo,
    required this.orden,
    required this.correcta,
    required this.descripcion,
    required this.grupo,
    required this.estado,
    required this.poderacion,
    required this.imagen,
  });

  factory Opcion.fromJson(Map<String, dynamic> json) {
    return Opcion(
      idOpcion: json['id_opcion'] ?? 0,
      idReactivo: json['id_reactivo_fk'] ?? 0,
      orden: json['orden'] ?? 0,
      correcta: json['correcta'] ?? '',
      descripcion: json['descripcion'] ?? '',
      grupo: json['grupo'] ?? 0,
      estado: json['estado'] ?? '',
      poderacion: json['poderacion'] ?? 0.0,
      imagen: json['imagen'] ?? '',
    );
  }

  Opcion copyWith({
    int? idOpcion,
    int? idReactivo,
    int? orden,
    String? correcta,
    String? descripcion,
    int? grupo,
    String? estado,
    double? poderacion,
    String? imagen,
  }) {
    return Opcion(
      idOpcion: idOpcion ?? this.idOpcion,
      idReactivo: idReactivo ?? this.idReactivo,
      orden: orden ?? this.orden,
      correcta: correcta ?? this.correcta,
      descripcion: descripcion ?? this.correcta,
      grupo: grupo ?? this.grupo,
      estado: estado ?? this.estado,
      poderacion: poderacion ?? this.poderacion,
      imagen: imagen ?? this.imagen,
    );
  }
}
