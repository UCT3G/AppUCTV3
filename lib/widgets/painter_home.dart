import 'package:flutter/material.dart';

class PainterHome extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paintFill0 =
        Paint()
          ..color = const Color.fromARGB(255, 162, 157, 205)
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * -0.0072222, size.height * 0.3772500);
    path_0.cubicTo(
      size.width * 0.1244444,
      size.height * 0.4634375,
      size.width * 0.3000000,
      size.height * 0.4564375,
      size.width * 0.2750000,
      size.height * 0.3775000,
    );
    path_0.cubicTo(
      size.width * 0.2722222,
      size.height * 0.3480000,
      size.width * 0.2688889,
      size.height * 0.3760000,
      size.width * 0.2683333,
      size.height * 0.2765000,
    );
    path_0.cubicTo(
      size.width * 0.2704167,
      size.height * 0.2195625,
      size.width * 0.3968056,
      size.height * 0.2706875,
      size.width * 0.4477778,
      size.height * 0.3057500,
    );
    path_0.cubicTo(
      size.width * 0.5345833,
      size.height * 0.3501250,
      size.width * 0.5993056,
      size.height * 0.3128750,
      size.width * 0.6194444,
      size.height * 0.2612500,
    );
    path_0.cubicTo(
      size.width * 0.6479167,
      size.height * 0.2039375,
      size.width * 0.6359722,
      size.height * 0.1663125,
      size.width * 0.7333333,
      size.height * 0.1600000,
    );
    path_0.cubicTo(
      size.width * 0.7966667,
      size.height * 0.1616875,
      size.width * 0.8233333,
      size.height * 0.1740625,
      size.width * 0.8466667,
      size.height * 0.2037500,
    );
    path_0.cubicTo(
      size.width * 0.8655556,
      size.height * 0.2249375,
      size.width * 0.9655556,
      size.height * 0.2363125,
      size.width * 1.0177778,
      size.height * 0.2165000,
    );
    path_0.quadraticBezierTo(
      size.width * 1.0205556,
      size.height * 0.1433750,
      size.width * 1.0177778,
      size.height * -0.0050000,
    );
    path_0.lineTo(size.width * -0.0166667, size.height * -0.0075000);
    path_0.quadraticBezierTo(
      size.width * -0.0143056,
      size.height * 0.0886875,
      size.width * -0.0072222,
      size.height * 0.3772500,
    );
    path_0.close();

    canvas.drawPath(path_0, paintFill0);

    // Layer 1

    Paint paintFill1 =
        Paint()
          ..color = const Color.fromARGB(255, 165, 210, 241)
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0.00
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    Path path_1 = Path();
    path_1.moveTo(size.width * -0.0152222, size.height * 0.9704000);
    path_1.cubicTo(
      size.width * 0.1057222,
      size.height * 0.9090625,
      size.width * 0.1297222,
      size.height * 0.9770625,
      size.width * 0.2112222,
      size.height * 0.9899500,
    );
    path_1.cubicTo(
      size.width * 0.2447500,
      size.height * 0.9931500,
      size.width * 0.2789167,
      size.height * 0.9835500,
      size.width * 0.3240000,
      size.height * 0.9563500,
    );
    path_1.cubicTo(
      size.width * 0.3653611,
      size.height * 0.9267500,
      size.width * 0.4107500,
      size.height * 0.9555500,
      size.width * 0.4503333,
      size.height * 0.9707500,
    );
    path_1.cubicTo(
      size.width * 0.5073056,
      size.height * 0.9958625,
      size.width * 0.5803611,
      size.height * 0.9732875,
      size.width * 0.6302222,
      size.height * 0.9544000,
    );
    path_1.cubicTo(
      size.width * 0.6970833,
      size.height * 0.9296000,
      size.width * 0.7632500,
      size.height * 0.9944000,
      size.width * 0.8443333,
      size.height * 1.0032000,
    );
    path_1.cubicTo(
      size.width * 0.9326944,
      size.height * 1.0036875,
      size.width * 0.9600833,
      size.height * 0.9774625,
      size.width * 1.0075556,
      size.height * 0.9771500,
    );
    path_1.quadraticBezierTo(
      size.width * 1.0067222,
      size.height * 0.9888500,
      size.width * 1.0131111,
      size.height * 1.0055500,
    );
    path_1.lineTo(size.width * -0.0158889, size.height * 1.0070500);
    path_1.quadraticBezierTo(
      size.width * -0.0143889,
      size.height * 1.0068875,
      size.width * -0.0152222,
      size.height * 0.9704000,
    );
    path_1.close();

    canvas.drawPath(path_1, paintFill1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
