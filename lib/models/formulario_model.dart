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
  final int registroUsuario;
  final String registroFecha;
  final int modificacionUsuario;
  final String modificacionFecha;
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
    required this.registroUsuario,
    required this.registroFecha,
    required this.modificacionUsuario,
    required this.modificacionFecha,
    required this.reactivos,
  });

  factory Formulario.fromJson(Map<String, dynamic> json) {
    return Formulario(
      idFormulario: json['id_formu'] ?? 0,
      idCategoria: json['id_categoria_fk'] ?? 0,
      idAreaEncuesta: json['id_area_encuesta_fk'] ?? 0,
      nombre: json['nombre'] ?? '',
      tituloFormulario: json['titulo_formulario'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? '',
      idTema: json['id_tema_fk'] ?? 0,
      registroUsuario: json['registro_usuario'] ?? 0,
      registroFecha: json['registro_fecha'] ?? '',
      modificacionUsuario: json['modificacion_usuario'] ?? 0,
      modificacionFecha: json['modificacion_fecha'] ?? '',
      reactivos:
          (json['reactivos'] as List<dynamic>? ?? [])
              .map((x) => Reactivo.fromJson(x))
              .toList(),
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
    int? registroUsuario,
    String? registroFecha,
    int? modificacionUsuario,
    String? modificacionFecha,
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
      registroUsuario: registroUsuario ?? this.registroUsuario,
      registroFecha: registroFecha ?? this.registroFecha,
      modificacionUsuario: modificacionUsuario ?? this.modificacionUsuario,
      modificacionFecha: modificacionFecha ?? this.modificacionFecha,
      reactivos: reactivos ?? this.reactivos,
    );
  }
}
