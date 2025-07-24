import 'package:app_uct/models/reactivo_model.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:app_uct/widgets/inputs/input_agrupar_widget.dart';
import 'package:app_uct/widgets/inputs/input_checkbox_widget.dart';
import 'package:app_uct/widgets/inputs/input_draggable_widget.dart';
import 'package:app_uct/widgets/inputs/input_radio_widget.dart';
import 'package:app_uct/widgets/inputs/input_undefined_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionCard extends StatefulWidget {
  final int idReactivo;
  final int index;

  const QuestionCard({
    super.key,
    required this.idReactivo,
    required this.index,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);

    if (reactivo == null) {
      return Center(child: Text('Reactivo no encontrado'));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: getBordeColor(reactivo), width: 2.0),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(25),
                        color: Color.fromRGBO(87, 84, 153, 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.index + 1}. ${getTextoInstruccion(reactivo.idInput)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 5),
                            if (reactivo.textoInput.isNotEmpty)
                              Text(
                                reactivo.textoInput,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (reactivo.temaIncorrecto != null &&
                        reactivo.temaIncorrecto!.isNotEmpty)
                      Text(
                        'Tema incorrecto: ${reactivo.temaIncorrecto}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    if (reactivo.imagen.isNotEmpty)
                      Center(
                        child: Image.network(
                          getImageUrl(reactivo),
                          height: 100,
                        ),
                      ),
                    SizedBox(height: 10),
                    buildInputWidget(reactivo),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String getTextoInstruccion(int? tipo) {
    switch (tipo) {
      case 5:
        return 'Selecciona la respuesta correcta: ';
      case 6:
        return 'Selecciona todas las respuestas correctas: ';
      case 11:
        return 'Ordena las respuestas correctamente: ';
      case 12:
        return 'Selecciona verdadero o falso: ';
      case 13:
        return 'Relaciona las tarjetas correctamente: ';
      default:
        return 'Responde la siguiente pregunta: ';
    }
  }

  Widget buildInputWidget(Reactivo reactivo) {
    final valor = reactivo.valor.toLowerCase();
    final etiqueta = reactivo.etiqueta;

    switch (etiqueta) {
      case 'input':
        if (valor.contains('type=radio')) {
          return InputRadioWidget(idReactivo: reactivo.idReactivo);
        } else if (valor.contains('type=checkbox')) {
          if (reactivo.idInput == 11) {
            return InputDraggableWidget(idReactivo: reactivo.idReactivo);
          } else {
            return InputCheckboxWidget(idReactivo: reactivo.idReactivo);
          }
        }
        break;
      case 'div-rela':
        return InputAgruparWidget(idReactivo: reactivo.idReactivo);
      default:
        return InputUndefinedWidget();
    }
    return SizedBox();
  }

  String getImageUrl(Reactivo reactivo) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final formulario = evaluacionProvider.formulario;
    final tema = competenciaProvider.getTemaById(formulario!.idTema);

    return "http://uct.tresguerras.com.mx:8007/imagenEvaluacion/${tema!.idCurso}/${tema.idUnidad}/${tema.idTema}/${reactivo.idReactivo}/${reactivo.imagen}";
  }

  Color getBordeColor(Reactivo reactivo) {
    if (reactivo.incorrecto == true ||
        reactivo.temaIncorrecto != null ||
        reactivo.error) {
      return Colors.red;
    } else if (reactivo.incorrecto == false &&
        reactivo.temaIncorrecto == null) {
      return Colors.green;
    } else {
      return Colors.grey.shade300;
    }
  }
}
