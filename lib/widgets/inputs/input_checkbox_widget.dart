import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InputCheckboxWidget extends StatelessWidget {
  final int idReactivo;

  const InputCheckboxWidget({super.key, required this.idReactivo});

  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final reactivo = evaluacionProvider.getReactivoById(idReactivo);

    if (reactivo == null) return Text("Reactivo no encontrado");

    final List<String> valoresSeleccionados =
        (evaluacionProvider.getRespuestas(idReactivo) as List<String>?) ?? [];

    return Column(
      children:
          reactivo.opciones.map((opcion) {
            final bool isChecked = valoresSeleccionados.contains(
              opcion.descripcion,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: isChecked,
                  onChanged: (bool? value) {
                    final nuevasRespuestas = [...valoresSeleccionados];

                    if (value == true) {
                      nuevasRespuestas.add(opcion.descripcion);
                    } else {
                      nuevasRespuestas.remove(opcion.descripcion);
                    }

                    evaluacionProvider.setRespuesta(
                      idReactivo,
                      nuevasRespuestas,
                    );
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
                  controlAffinity: ListTileControlAffinity.leading,
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
