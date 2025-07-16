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
  List<dynamic> _opciones = [];
  List<List<int>> _grupoRespuesta = [];
  List<int> _seleccionActual = [];
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

    if (reactivo != null) {
      _opciones =
          reactivo.opciones.map((opcion) {
            return {
              'id': opcion.idOpcion,
              'descripcion': opcion.descripcion,
              'imagen': opcion.imagen,
              'selected': false,
              'color': null,
            };
          }).toList();
    }
  }

  void seleccionarOpcion(int index) {
    if (_opciones[index]['selected']) return;

    setState(() {
      _seleccionActual.add(index);
      _opciones[index]['selected'] = true;
      _opciones[index]['color'] = _colores[_colorIndex];
    });

    if (_seleccionActual.length == 2) {
      final id1 = _opciones[_seleccionActual[0]]['id'] as int;
      final id2 = _opciones[_seleccionActual[1]]['id'] as int;

      setState(() {
        _grupoRespuesta.add([id1, id2]);
        _colorIndex = (_colorIndex + 1) % _colores.length;
        _seleccionActual.clear();
      });

      final evaluacionProvider = Provider.of<EvaluacionProvider>(
        context,
        listen: false,
      );
      evaluacionProvider.setRespuesta(widget.idReactivo, _grupoRespuesta);
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
    evaluacionProvider.setRespuesta(widget.idReactivo, []);
  }

  @override
  Widget build(BuildContext context) {
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
                  final color = opcion['color'] as Color?;
                  final descripcion = opcion['descripcion'] as String;
                  final imagen = opcion['imagen'] as String?;

                  return GestureDetector(
                    onTap: () => seleccionarOpcion(index),
                    child: Container(
                      width: 120,
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
                  );
                }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: reiniciar,
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
}
