import 'dart:developer';

import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InputDraggableWidget extends StatefulWidget {
  final int idReactivo;

  const InputDraggableWidget({super.key, required this.idReactivo});

  @override
  State<InputDraggableWidget> createState() => _InputDraggableWidgetState();
}

class _InputDraggableWidgetState extends State<InputDraggableWidget> {
  late List<Map<String, dynamic>> _ordenUsuario;

  @override
  void initState() {
    super.initState();
    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );
    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);

    _ordenUsuario =
        reactivo!.opciones.asMap().entries.map((entry) {
          final index = entry.key;
          final o = entry.value;
          return {
            'id_opcion': o.idOpcion,
            'descripcion': o.descripcion,
            'correcta': o.correcta,
            'ponderacion': o.poderacion,
            'orden': index + 1,
          };
        }).toList();

    final respuesta = {
      'type': 'checkbox',
      'valor': _ordenUsuario.map((o) => o['descripcion']).toList(),
      'id_reactivo': reactivo.idReactivo,
      'opciones': _ordenUsuario,
    };

    final reactivoSeleccionado = reactivo.toJson(respuesta: respuesta);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      evaluacionProvider.setRespuesta(reactivoSeleccionado);
    });
  }

  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);

    if (reactivo == null) return const Text("Reactivo no encontrado");

    final bool deshabilitado = reactivo.incorrecto != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _ordenUsuario.length,
          itemBuilder: (context, index) {
            final item = _ordenUsuario[index];

            return Container(
              key: ValueKey(item['id_opcion']),
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: deshabilitado ? Colors.grey.shade200 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: deshabilitado ? Colors.grey : Color(0xFF84A9CA),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.drag_indicator_rounded,
                        color: deshabilitado ? Colors.grey : Color(0xFF84A9CA),
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Text(
                        item['descripcion'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 🔍 Busca la opción completa (para acceder a la imagen)
                  if (reactivo.opciones.any(
                    (op) =>
                        op.idOpcion == item['id_opcion'] &&
                        op.imagen.isNotEmpty,
                  ))
                    Image.network(
                      getImageUrl(
                        reactivo.opciones
                            .firstWhere(
                              (op) => op.idOpcion == item['id_opcion'],
                            )
                            .imagen,
                      ),
                      height: 100,
                    ),
                ],
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (deshabilitado) return;

            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _ordenUsuario.removeAt(oldIndex);
              _ordenUsuario.insert(newIndex, item);

              for (int i = 0; i < _ordenUsuario.length; i++) {
                _ordenUsuario[i]['orden'] = i + 1;
              }

              final respuesta = {
                'type': 'checkbox',
                'valor': _ordenUsuario.map((o) => o['descripcion']).toList(),
                'id_reactivo': reactivo.idReactivo,
                'opciones': _ordenUsuario,
              };

              final reactivoSeleccionado = reactivo.toJson(
                respuesta: respuesta,
              );

              log(reactivoSeleccionado.toString());
              evaluacionProvider.setRespuesta(reactivoSeleccionado);
            });
          },
        ),
      ],
    );
  }

  String getImageUrl(String nombreArchivo) {
    return "http://uct.tresguerras.com.mx:8007/media/${nombreArchivo.replaceFirst('data/', '')}";
  }
}
