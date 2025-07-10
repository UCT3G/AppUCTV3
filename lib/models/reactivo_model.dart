import 'package:app_uct/models/opcion_model.dart';

class Reactivo {
  final int idReactivo;
  final int idFormulario;
  final int idInput;
  final String textoInput;
  final String campoTabla;
  final String tablaBd;
  final int tipoPregunta;
  final int longitudMinima;
  final int longitudMaxima;
  final List<Opcion> opciones;
  final String imagen;
  final int orden;
  final String etiqueta;
  final String valor;
  final int valorReactivo;
  final String obligatorio;
  final String estado;
  final int idTema;
  final String descripcionTema;
  final String reactivoJson;
  final List respuesta;
  final bool error;

  Reactivo({
    required this.idReactivo,
    required this.idFormulario,
    required this.idInput,
    required this.textoInput,
    required this.campoTabla,
    required this.tablaBd,
    required this.tipoPregunta,
    required this.longitudMinima,
    required this.longitudMaxima,
    required this.opciones,
    required this.imagen,
    required this.orden,
    required this.etiqueta,
    required this.valor,
    required this.valorReactivo,
    required this.obligatorio,
    required this.estado,
    required this.idTema,
    required this.descripcionTema,
    required this.reactivoJson,
    required this.respuesta,
    required this.error,
  });

  factory Reactivo.fromJson(Map<String, dynamic> json) {
    return Reactivo(
      idReactivo: json['id_reactivo'] ?? 0,
      idFormulario: json['id_formulario_fk'] ?? 0,
      idInput: json['id_input_fk'] ?? 0,
      textoInput: json['texto_input'] ?? '',
      campoTabla: json['campo_tabla'] ?? '',
      tablaBd: json['tabla_bd'] ?? '',
      tipoPregunta: json['tipo_pregunta'] ?? 0,
      longitudMinima: json['longitud_minima'] ?? 0,
      longitudMaxima: json['longitud_maxima'] ?? 0,
      opciones:
          (json['opciones'] as List<dynamic>? ?? [])
              .map((x) => Opcion.fromJson(x))
              .toList(),
      imagen: json['imagen'] ?? '',
      orden: json['orden'] ?? 0,
      etiqueta: json['etiqueta'] ?? '',
      valor: json['valor'] ?? '',
      valorReactivo: json['valor_reactivo'] ?? 0,
      obligatorio: json['obligatorio'] ?? '',
      estado: json['estado'] ?? '',
      idTema: json['id_tema'] ?? 0,
      descripcionTema: json['descripcion_tema'] ?? '',
      reactivoJson: json['reactivo_json'] ?? '',
      respuesta: json['respuesta'] ?? [],
      error: json['error'] ?? false,
    );
  }

  Reactivo copyWith({
    int? idReactivo,
    int? idFormulario,
    int? idInput,
    String? textoInput,
    String? campoTabla,
    String? tablaBd,
    int? tipoPregunta,
    int? longitudMinima,
    int? longitudMaxima,
    List<Opcion>? opciones,
    String? imagen,
    int? orden,
    String? etiqueta,
    String? valor,
    int? valorReactivo,
    String? obligatorio,
    String? estado,
    int? idTema,
    String? descripcionTema,
    String? reactivoJson,
    List? respuesta,
    bool? error,
  }) {
    return Reactivo(
      idReactivo: idReactivo ?? this.idReactivo,
      idFormulario: idFormulario ?? this.idFormulario,
      idInput: idInput ?? this.idInput,
      textoInput: textoInput ?? this.textoInput,
      campoTabla: campoTabla ?? this.campoTabla,
      tablaBd: tablaBd ?? this.tablaBd,
      tipoPregunta: tipoPregunta ?? this.tipoPregunta,
      longitudMinima: longitudMinima ?? this.longitudMinima,
      longitudMaxima: longitudMaxima ?? this.longitudMaxima,
      opciones: opciones ?? this.opciones,
      imagen: imagen ?? this.imagen,
      orden: orden ?? this.orden,
      etiqueta: etiqueta ?? this.etiqueta,
      valor: valor ?? this.valor,
      valorReactivo: valorReactivo ?? this.valorReactivo,
      obligatorio: obligatorio ?? this.obligatorio,
      estado: estado ?? this.estado,
      idTema: idTema ?? this.idTema,
      descripcionTema: descripcionTema ?? this.descripcionTema,
      reactivoJson: reactivoJson ?? this.reactivoJson,
      respuesta: respuesta ?? this.respuesta,
      error: error ?? this.error,
    );
  }
}
