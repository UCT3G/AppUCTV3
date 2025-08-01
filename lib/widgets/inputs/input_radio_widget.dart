import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:app_uct/services/api_service.dart';
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

    final bool deshabilitado = reactivo.incorrecto != null;

    final reactivoRespuesta = evaluacionProvider.getReactivoRespuesta(
      idReactivo,
    );
    final valorSeleccionado =
        reactivoRespuesta != null
            ? reactivoRespuesta['respuesta']['id_opcion']
            : null;

    return Column(
      children:
          reactivo.opciones.map((opcion) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile(
                  value: opcion.idOpcion,
                  groupValue: valorSeleccionado,
                  onChanged:
                      deshabilitado
                          ? null
                          : (value) {
                            final opcionSeleccionada = reactivo.opciones
                                .firstWhere((o) => o.idOpcion == value);

                            final respuesta = {
                              'type': 'radio',
                              'valor': opcionSeleccionada.descripcion,
                              'id_reactivo': opcionSeleccionada.idReactivo,
                              'id_opcion': opcionSeleccionada.idOpcion,
                              'correcta': opcionSeleccionada.correcta,
                              'ponderacion': opcionSeleccionada.poderacion,
                            };

                            final reactivoSeleccionado = reactivo.toJson(
                              respuesta: respuesta,
                            );

                            evaluacionProvider.setRespuesta(
                              reactivoSeleccionado,
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
                ),
              ],
            );
          }).toList(),
    );
  }

  String getImageUrl(String nombreArchivo) {
    return "${ApiService.baseURL}/media/${nombreArchivo.replaceFirst('data/', '')}";
  }
}
