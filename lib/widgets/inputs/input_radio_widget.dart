// import 'dart:developer';

import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InputRadioWidget extends StatelessWidget {
  final int idReactivo;

  const InputRadioWidget({super.key, required this.idReactivo});

  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final reactivo = evaluacionProvider.getReactivoById(idReactivo);

    if (reactivo == null) return Text("Reactivo no encontrado");

    final valorSeleccionado = evaluacionProvider.getRespuestas(idReactivo);

    return Column(
      children:
          reactivo.opciones.map((opcion) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile(
                  value: opcion.descripcion,
                  groupValue: valorSeleccionado,
                  onChanged: (value) {
                    if (reactivo.idInput == 12) {}
                    evaluacionProvider.setRespuesta(idReactivo, value!);
                  },
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        opcion.descripcion,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                        ),
                      ),
                      if (opcion.imagen.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Image.network(
                            getImageUrl(opcion.imagen),
                            height: 100,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  String getImageUrl(String nombreArchivo) {
    return "http://uct.tresguerras.com.mx:8007/media/${nombreArchivo.replaceFirst('data/', '')}";
  }
}
