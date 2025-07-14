import 'package:app_uct/models/reactivo_model.dart';
import 'package:app_uct/provider/evaluacion_provider.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.grey.shade300,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.index + 1}. ${getTextoInstruccion(reactivo.idInput)}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 5),
                    if (reactivo.textoInput.isNotEmpty)
                      Text(
                        reactivo.textoInput,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.justify,
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
      default:
        return InputUndefinedWidget();
    }
    return SizedBox();
  }
}
