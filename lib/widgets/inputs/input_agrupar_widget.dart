import 'dart:developer';

import 'package:app_uct/provider/evaluacion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InputAgruparWidget extends StatefulWidget {
  final int idReactivo;

  const InputAgruparWidget({super.key, required this.idReactivo});

  @override
  State<InputAgruparWidget> createState() => _InputAgruparWidgetState();
}

class _InputAgruparWidgetState extends State<InputAgruparWidget> {
  List<Map<String, dynamic>> _opciones = [];
  List<List<Map<String, dynamic>>> _grupoRespuesta = [];
  final List<int> _seleccionActual = [];
  int _colorIndex = 0;

  final List<Color> _colores = [
    Color(0xFFADD9F2),
    Color(0xFFF9F871),
    Color(0xFF5AF0CB),
    Color(0xFFC1FA8A),
    Color(0xFF8BF7AB),
    Color(0xFF3BE6E4),
    Color(0xFFE28788),
    Color(0xFFEE8DEE),
  ];

  @override
  void initState() {
    super.initState();
    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );
    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);
    final respuesta = evaluacionProvider.getReactivoRespuesta(
      widget.idReactivo,
    );

    if (reactivo != null) {
      _opciones =
          reactivo.opciones.map((opcion) {
            return {
              'id_opcion': opcion.idOpcion,
              'descripcion': opcion.descripcion,
              'imagen': opcion.imagen,
              'selected': false,
              'color': null,
              'correcta': opcion.correcta,
              'grupo': opcion.grupo,
              'estado': opcion.estado,
              'ponderacion': opcion.poderacion,
            };
          }).toList();

      if (respuesta != null && respuesta['grupo_respuesta'] != null) {
        final grupos = List<List<dynamic>>.from(respuesta['grupo_respuesta']);
        _grupoRespuesta = [];

        for (var grupo in grupos) {
          final grupoConvertido = <Map<String, dynamic>>[];
          for (var opcion in grupo) {
            final idOpcion = opcion['id_opcion'];
            final index = _opciones.indexWhere(
              (o) => o['id_opcion'] == idOpcion,
            );
            if (index != -1) {
              _opciones[index]['selected'] = true;
              _opciones[index]['color'] = opcion['color']; // Restaurar color
              grupoConvertido.add(_opciones[index]);
            }
          }
          _grupoRespuesta.add(grupoConvertido);
        }

        // Actualizar el índice de color (evita repetir)
        _colorIndex = _grupoRespuesta.length % _colores.length;
      }
    }
  }

  void seleccionarOpcion(int index) {
    if (_opciones[index]['selected']) return;

    setState(() {
      _seleccionActual.add(index);
      _opciones[index]['selected'] = true;
      final color = _colores[_colorIndex];
      final argb = color.toARGB32();
      final hexColor =
          '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
      _opciones[index]['color'] = hexColor;
    });

    if (_seleccionActual.length == 2) {
      final grupo = [
        _opciones[_seleccionActual[0]],
        _opciones[_seleccionActual[1]],
      ];
      log(grupo.toString());

      setState(() {
        _grupoRespuesta.add(grupo);
        _colorIndex = (_colorIndex + 1) % _colores.length;
        _seleccionActual.clear();
      });

      // Aquí arma el objeto completo para enviar la respuesta actualizada
      final evaluacionProvider = Provider.of<EvaluacionProvider>(
        context,
        listen: false,
      );
      final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);
      if (reactivo != null) {
        final reactivoSeleccionado = reactivo.toJson(
          grupoRespuesta: _grupoRespuesta,
        );

        reactivoSeleccionado['opciones'] = _opciones;
        log(reactivoSeleccionado.toString());
        evaluacionProvider.setRespuesta(reactivoSeleccionado);
      }
    }
  }

  void reiniciar() {
    setState(() {
      _seleccionActual.clear();
      _grupoRespuesta.clear();
      _colorIndex = 0;

      for (var opcion in _opciones) {
        opcion['selected'] = false;
        opcion['color'] = null;
      }
    });

    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );

    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);
    if (reactivo != null) {
      final reactivoSeleccionado = reactivo.toJson(grupoRespuesta: []);
      evaluacionProvider.setRespuesta(reactivoSeleccionado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );
    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);
    final bool deshabilitado = reactivo!.incorrecto != null;

    final size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _opciones.asMap().entries.map((entry) {
                  final index = entry.key;
                  final opcion = entry.value;
                  final colorHex = opcion['color'];
                  final color =
                      colorHex != null ? getColorFromHex(colorHex) : null;
                  final descripcion = opcion['descripcion'] as String;
                  final imagen = opcion['imagen'] as String?;

                  return GestureDetector(
                    onTap:
                        () => deshabilitado ? null : seleccionarOpcion(index),
                    child: Opacity(
                      opacity: deshabilitado ? 0.6 : 1.0,
                      child: Container(
                        width: size.width * 0.4,
                        constraints: BoxConstraints(minHeight: 150),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color ?? Colors.white,
                          border: Border.all(
                            color: color ?? Colors.grey,
                            width: opcion['selected'] ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (descripcion.isNotEmpty)
                              Text(
                                descripcion,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (imagen != null && imagen.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Image.network(
                                  getImageUrl(imagen),
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: deshabilitado ? null : reiniciar,
            child: Text(
              'Reiniciar selecciones',
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String getImageUrl(String nombreArchivo) {
    return "http://uct.tresguerras.com.mx:8007/media/${nombreArchivo.replaceFirst('data/', '')}";
  }

  Color getColorFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
