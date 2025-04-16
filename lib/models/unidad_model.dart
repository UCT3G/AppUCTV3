import 'package:app_uct/models/tema_model.dart';

class Unidad {
  final int idUnidad;
  final String titulo;
  final int orden;
  final List<Tema> temas;
  final int idCurso;

  Unidad({
    required this.idUnidad,
    required this.titulo,
    required this.orden,
    required this.temas,
    required this.idCurso,
  });

  factory Unidad.fromJson(Map<String, dynamic> json) {
    return Unidad(
      idUnidad: json['id_unidad'],
      titulo: json['titulo'],
      orden: json['orden'],
      temas: List<Tema>.from(json['temas'].map((x) => Tema.fromJson(x))),
      idCurso: json['id_curso_fk'],
    );
  }
}
