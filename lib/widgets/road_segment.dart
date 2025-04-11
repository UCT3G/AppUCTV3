import 'package:app_uct/screens/temario_screen.dart';
import 'package:flutter/material.dart';

class RoadSegment extends StatefulWidget {
  final SegmentType type;
  final String titulo;

  const RoadSegment({super.key, required this.type, required this.titulo});

  @override
  State<RoadSegment> createState() => _RoadSegmentState();
}

class _RoadSegmentState extends State<RoadSegment> {
  bool isExpanded = false;

  String get assetPath {
    switch (widget.type) {
      case SegmentType.start:
        return 'assets/images/Continuacioninicio.png';
      case SegmentType.left:
        return 'assets/images/CurvaIzquierda.png';
      case SegmentType.right:
        return 'assets/images/CurvaDerecha.png';
      case SegmentType.endLeft:
        return 'assets/images/Finalizq.png';
      case SegmentType.endRight:
        return 'assets/images/Finalder.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    bool isCardOnRight;
    bool isCircleOnLeft;

    switch (widget.type) {
      case SegmentType.start:
        // INICIO: Círculo a la izquierda (curva hacia izquierda)
        // Tarjeta a la derecha porque viene del lado derecho
        isCardOnRight = true;
        isCircleOnLeft = true;
        break;
      case SegmentType.left:
        // CURVA IZQUIERDA: Círculo a la izquierda, tarjeta a la derecha
        isCardOnRight = false;
        isCircleOnLeft = false;
        break;
      case SegmentType.right:
        // CURVA DERECHA: Círculo a la derecha, tarjeta a la izquierda
        isCardOnRight = true;
        isCircleOnLeft = true;
        break;
      case SegmentType.endLeft:
        // FINAL: Círculo a la derecha (última curva es derecha)
        // Tarjeta a la izquierda porque termina en izquierda
        isCardOnRight = false;
        isCircleOnLeft = false;
        break;
      case SegmentType.endRight:
        // FINAL: Círculo a la izquierda (última curva es izquierda)
        // Tarjeta a la derecha porque termina en derecha
        isCardOnRight = true;
        isCircleOnLeft = true;
        break;
    }

    return Stack(
      children: [
        Image.asset(assetPath, fit: BoxFit.cover, width: double.infinity),
        Positioned(
          top: screenSize.height * 0.02,
          left: isCardOnRight ? null : 50,
          right: isCardOnRight ? 50 : null,
          child: GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: SizedBox(
              width: screenSize.width * 0.7,
              height:
                  isExpanded
                      ? screenSize.height * 0.2
                      : screenSize.height * 0.13,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.titulo,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: isExpanded ? null : 4,
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      if (isExpanded)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('0'),
                            SizedBox(width: 10),
                            Icon(Icons.remove_red_eye),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: screenSize.height * 0.05,
          left: isCircleOnLeft ? 40 : null,
          right: isCircleOnLeft ? null : 40,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFCC151A),
            child: Icon(Icons.video_file, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
