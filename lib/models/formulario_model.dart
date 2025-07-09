import 'package:app_uct/models/reactivo_model.dart';

class Formulario {
  final int idFormulario;
  final int idCategoria;
  final int idAreaEncuesta;
  final String nombre;
  final String tituloFormulario;
  final String descripcion;
  final String estado;
  final int idTema;
  final List<Reactivo> reactivos;

  Formulario({
    required this.idFormulario,
    required this.idCategoria,
    required this.idAreaEncuesta,
    required this.nombre,
    required this.tituloFormulario,
    required this.descripcion,
    required this.estado,
    required this.idTema,
    required this.reactivos,
  });

  factory Formulario.fromJson(Map<String, dynamic> json) {
    return Formulario(
      idFormulario: json['id_formu'],
      idCategoria: json['id_categoria_fk'],
      idAreaEncuesta: json['id_area_encuesta_fk'],
      nombre: json['nombre'],
      tituloFormulario: json['titulo_formulario'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      idTema: json['id_tema_fk'],
      reactivos: List<Reactivo>.from(
        json['reactivos'].map((x) => Reactivo.fromJson(x)),
      ),
    );
  }

  Formulario copyWith({
    int? idFormulario,
    int? idCategoria,
    int? idAreaEncuesta,
    String? nombre,
    String? tituloFormulario,
    String? descripcion,
    String? estado,
    int? idTema,
    List<Reactivo>? reactivos,
  }) {
    return Formulario(
      idFormulario: idFormulario ?? this.idFormulario,
      idCategoria: idCategoria ?? this.idCategoria,
      idAreaEncuesta: idAreaEncuesta ?? this.idAreaEncuesta,
      nombre: nombre ?? this.nombre,
      tituloFormulario: tituloFormulario ?? this.tituloFormulario,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      idTema: idTema ?? this.idTema,
      reactivos: reactivos ?? this.reactivos,
    );
  }
}
