import 'package:app_uct/screens/temario_screen.dart';
import 'package:flutter/material.dart';

class RoadSegment extends StatelessWidget {
  final SegmentType type;
  final String titulo;

  const RoadSegment({super.key, required this.type, required this.titulo});

  String get assetPath {
    switch (type) {
      case SegmentType.start:
        return 'assets/images/CarreteraInicio.png';
      case SegmentType.left:
        return 'assets/images/CarreteraIzquierda.png';
      case SegmentType.right:
        return 'assets/images/CarreteraDerecha.png';
      case SegmentType.endLeft:
        return 'assets/images/CarreteraFinal.png';
      case SegmentType.endRight:
        return 'assets/images/CarreteraFinal2.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCardOnRight;
    bool isCircleOnLeft;

    switch (type) {
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
          top: 50,
          left: isCardOnRight ? null : 100,
          right: isCardOnRight ? 100 : null,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: isCircleOnLeft ? 40 : null,
          right: isCircleOnLeft ? null : 40,
          child: CircleAvatar(radius: 30, backgroundColor: Colors.red),
        ),
      ],
    );
  }
}
