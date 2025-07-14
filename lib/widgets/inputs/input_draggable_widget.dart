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
  late List<String> _ordenUsuario;

  @override
  void initState() {
    super.initState();
    final evaluacionProvider = Provider.of<EvaluacionProvider>(
      context,
      listen: false,
    );
    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);

    _ordenUsuario = List<String>.from(
      reactivo!.opciones.map((o) => o.descripcion),
    );
    // _ordenUsuario.shuffle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      evaluacionProvider.setRespuesta(widget.idReactivo, _ordenUsuario);
    });
  }

  @override
  Widget build(BuildContext context) {
    final evaluacionProvider = Provider.of<EvaluacionProvider>(context);
    final reactivo = evaluacionProvider.getReactivoById(widget.idReactivo);

    if (reactivo == null) return const Text("Reactivo no encontrado");

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
              key: ValueKey(item),
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF84A9CA)),
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
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 🔍 Busca la opción completa (para acceder a la imagen)
                  if (reactivo.opciones.any(
                    (op) => op.descripcion == item && op.imagen.isNotEmpty,
                  ))
                    Image.network(
                      getImageUrl(
                        reactivo.opciones
                            .firstWhere((op) => op.descripcion == item)
                            .imagen,
                      ),
                      height: 100,
                    ),
                ],
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _ordenUsuario.removeAt(oldIndex);
              _ordenUsuario.insert(newIndex, item);

              evaluacionProvider.setRespuesta(widget.idReactivo, _ordenUsuario);
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
