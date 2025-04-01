import 'package:flutter/material.dart';

class PainterWelcome extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paint_fill_0 =
        Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255)
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    paint_fill_0.shader = LinearGradient(
      colors: [
        Color(0xFF86CBC8),
        Color(0xFF574293),
      ], // Azul PRIMERO, morado SEGUNDO
      stops: [0.0, 0.4],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path_0 = Path();
    path_0.moveTo(size.width * -0.0126111, size.height * 0.3901664);
    path_0.cubicTo(
      size.width * 0.4460278,
      size.height * 0.2526165,
      size.width * 0.5515833,
      size.height * 0.2520365,
      size.width * 1.0166667,
      size.height * 0.3908334,
    );
    path_0.quadraticBezierTo(
      size.width * 1.0166667,
      size.height * 0.2907813,
      size.width * 1.0166667,
      size.height * -0.0093750,
    );
    path_0.lineTo(size.width * -0.0128333, size.height * -0.0065909);
    path_0.quadraticBezierTo(
      size.width * -0.0127778,
      size.height * 0.0925984,
      size.width * -0.0126111,
      size.height * 0.3901664,
    );
    path_0.close();

    canvas.drawPath(path_0, paint_fill_0);

    // Layer 1

    Paint paint_fill_1 =
        Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255)
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    paint_fill_1.shader = LinearGradient(
      colors: [
        Color(0xFFA5D2F1),
        Color(0xFFA29DCD),
      ], // Azul PRIMERO, morado SEGUNDO
      stops: [0.0, 0.4],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path_1 = Path();
    path_1.moveTo(size.width * -0.0138889, size.height * 0.2468750);
    path_1.cubicTo(
      size.width * 0.0424444,
      size.height * 0.2463594,
      size.width * 0.1281111,
      size.height * 0.2420156,
      size.width * 0.0805556,
      size.height * 0.1953125,
    );
    path_1.quadraticBezierTo(
      size.width * 0.0395556,
      size.height * 0.1433437,
      size.width * 0.1305556,
      size.height * 0.1125000,
    );
    path_1.lineTo(size.width * 0.4861111, size.height * -0.0078125);
    path_1.lineTo(size.width * -0.0138889, size.height * -0.0062500);
    path_1.quadraticBezierTo(
      size.width * -0.0138889,
      size.height * 0.0570312,
      size.width * -0.0138889,
      size.height * 0.2468750,
    );
    path_1.close();

    canvas.drawPath(path_1, paint_fill_1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
