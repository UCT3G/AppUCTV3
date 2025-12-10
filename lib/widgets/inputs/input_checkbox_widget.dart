import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:app_uct/services/api_service.dart';
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

    final reactivoRespuesta = evaluacionProvider.getReactivoRespuesta(
      idReactivo,
    );
    final valoresSeleccionados =
        reactivoRespuesta != null
            ? reactivoRespuesta['respuesta']['opciones']
            : null;
    final bool deshabilitado = reactivo.incorrecto != null;

    return Column(
      children:
          reactivo.opciones.map((opcion) {
            final bool isChecked =
                valoresSeleccionados != null &&
                valoresSeleccionados.any(
                  (o) => o['id_opcion'] == opcion.idOpcion,
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: isChecked,
                  onChanged:
                      deshabilitado
                          ? null
                          : (bool? value) {
                            List<Map<String, dynamic>> nuevasOpciones =
                                valoresSeleccionados != null
                                    ? List<Map<String, dynamic>>.from(
                                      valoresSeleccionados,
                                    )
                                    : [];

                            final opcionSeleccionada = {
                              'id_opcion': opcion.idOpcion,
                              'descripcion': opcion.descripcion,
                              'correcta': opcion.correcta,
                              'ponderacion': opcion.poderacion,
                              'orden': opcion.orden,
                            };

                            if (value == true) {
                              nuevasOpciones.add(opcionSeleccionada);
                            } else {
                              nuevasOpciones.removeWhere(
                                (o) => o['id_opcion'] == opcion.idOpcion,
                              );
                            }

                            final respuesta = {
                              'type': 'checkbox',
                              'valor':
                                  nuevasOpciones
                                      .map((o) => o['descripcion'])
                                      .toList(),
                              'id_reactivo': opcion.idReactivo,
                              'opciones': nuevasOpciones,
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
                  controlAffinity: ListTileControlAffinity.leading,
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
