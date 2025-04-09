import 'package:flutter/material.dart';

class PainterTemario extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paint_fill_0 =
        Paint()
          ..color = const Color.fromARGB(127, 255, 255, 255)
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.4545833, size.height * -0.0101389);
    path_0.cubicTo(
      size.width * 0.4251667,
      size.height * 0.0089167,
      size.width * 0.3987500,
      size.height * 0.0949306,
      size.width * 0.6651389,
      size.height * 0.0673611,
    );
    path_0.cubicTo(
      size.width * 0.8497222,
      size.height * 0.0412500,
      size.width * 0.8555556,
      size.height * 0.0901389,
      size.width * 0.8684722,
      size.height * 0.1059722,
    );
    path_0.cubicTo(
      size.width * 0.9200833,
      size.height * 0.2483611,
      size.width * 0.9565000,
      size.height * 0.2205417,
      size.width * 1.0329167,
      size.height * 0.2240278,
    );
    path_0.quadraticBezierTo(
      size.width * 1.0313889,
      size.height * 0.1654167,
      size.width * 1.0268056,
      size.height * -0.0104167,
    );
    path_0.quadraticBezierTo(
      size.width * 0.8837500,
      size.height * -0.0103472,
      size.width * 0.4545833,
      size.height * -0.0101389,
    );
    path_0.close();

    canvas.drawPath(path_0, paint_fill_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
