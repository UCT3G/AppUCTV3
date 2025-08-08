import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InputTexareaWidget extends StatefulWidget {
  final int idReactivo;
  const InputTexareaWidget({super.key, required this.idReactivo});

  @override
  State<InputTexareaWidget> createState() => _InputTexareaWidgetState();
}

class _InputTexareaWidgetState extends State<InputTexareaWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context, listen: false);

    final reactivoRespuesta = evaluacionProvider.getReactivoRespuesta(
      widget.idReactivo,
    );
    final String textoInicial =
        reactivoRespuesta != null
            ? reactivoRespuesta['respuesta']['valor'] ?? ''
            : '';
    _controller = TextEditingController(text: textoInicial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);

    if (reactivo == null) return Text("Reactivo no encontrado");

    final bool deshabilitado = reactivo.incorrecto != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: !deshabilitado,
          maxLines: 4,
          minLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Escribe tu respuesta aquí...",
          ),
          onChanged: (value) {
            final respuesta = {"type": "textarea", "valor": value};

            final reactivoSeleccionado = reactivo.toJson(respuesta: respuesta);

            evaluacionProvider.setRespuesta(reactivoSeleccionado);
          },
        ),
      ],
    );
  }
}
