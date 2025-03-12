import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255)
          ..style = PaintingStyle.fill
          ..strokeWidth = size.width * 0
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter;

    paint.shader = LinearGradient(
      colors: [Color(0xFFA6D3F2), Color(0xFFA4A0EF)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path_1 = Path();
    path_1.moveTo(size.width * 1.0144928, size.height * -0.0011161);
    path_1.quadraticBezierTo(
      size.width * 0.6720531,
      size.height * 0.0786272,
      size.width * 0.5434783,
      size.height * 0.1004464,
    );
    path_1.cubicTo(
      size.width * 0.4323430,
      size.height * 0.1212612,
      size.width * 0.4350000,
      size.height * 0.1419978,
      size.width * 0.4483092,
      size.height * 0.1587054,
    );
    path_1.cubicTo(
      size.width * 0.4813043,
      size.height * 0.1847321,
      size.width * 0.5596618,
      size.height * 0.2082143,
      size.width * 0.5663768,
      size.height * 0.2399554,
    );
    path_1.quadraticBezierTo(
      size.width * 0.5666184,
      size.height * 0.2746429,
      size.width * 0.4637681,
      size.height * 0.3158482,
    );
    path_1.quadraticBezierTo(
      size.width * 0.3314251,
      size.height * 0.3606027,
      size.width * 0.2739130,
      size.height * 0.3757589,
    );
    path_1.cubicTo(
      size.width * 0.1571498,
      size.height * 0.4021540,
      size.width * 0.2830435,
      size.height * 0.4404799,
      size.width * 0.2922705,
      size.height * 0.4620536,
    );
    path_1.cubicTo(
      size.width * 0.3225604,
      size.height * 0.5011607,
      size.width * 0.1528019,
      size.height * 0.4893750,
      size.width * 0.1784541,
      size.height * 0.5363393,
    );
    path_1.cubicTo(
      size.width * 0.2528261,
      size.height * 0.6376897,
      size.width * 0.1403140,
      size.height * 0.6005692,
      size.width * 0.1002899,
      size.height * 0.6195982,
    );
    path_1.cubicTo(
      size.width * 0.0657488,
      size.height * 0.6322768,
      size.width * 0.0774396,
      size.height * 0.6979911,
      size.width * 0.0966184,
      size.height * 0.7488839,
    );
    path_1.quadraticBezierTo(
      size.width * 0.1197826,
      size.height * 0.7885938,
      size.width * -0.0024155,
      size.height * 0.7734375,
    );
    path_1.lineTo(size.width * -0.0096618, size.height * -0.0033482);
    path_1.lineTo(size.width * 1.0144928, size.height * -0.0011161);
    path_1.close();

    canvas.drawPath(path_1, paint);

    Path path_2 = Path();
    path_2.moveTo(size.width * 1.0072464, size.height * 1.0033482);
    path_2.lineTo(size.width * 0.3695652, size.height * 1.0044643);
    path_2.quadraticBezierTo(
      size.width * 0.0505797,
      size.height * 0.9828013,
      size.width * 0.3405797,
      size.height * 0.9475446,
    );
    path_2.cubicTo(
      size.width * 0.4399758,
      size.height * 0.9370089,
      size.width * 0.5666184,
      size.height * 0.9328795,
      size.width * 0.6427053,
      size.height * 0.9295313,
    );
    path_2.cubicTo(
      size.width * 0.7150725,
      size.height * 0.9258929,
      size.width * 0.7526087,
      size.height * 0.9235603,
      size.width * 0.8044203,
      size.height * 0.9010268,
    );
    path_2.cubicTo(
      size.width * 0.8656039,
      size.height * 0.8668415,
      size.width * 0.7472222,
      size.height * 0.8508371,
      size.width * 0.7222222,
      size.height * 0.8258929,
    );
    path_2.cubicTo(
      size.width * 0.6902415,
      size.height * 0.7865625,
      size.width * 0.8683575,
      size.height * 0.7987165,
      size.width * 0.8429952,
      size.height * 0.7812500,
    );
    path_2.cubicTo(
      size.width * 0.7719807,
      size.height * 0.7465513,
      size.width * 0.7489130,
      size.height * 0.7310268,
      size.width * 0.7899034,
      size.height * 0.7142857,
    );
    path_2.quadraticBezierTo(
      size.width * 0.8691063,
      size.height * 0.6913170,
      size.width,
      size.height * 0.6696429,
    );
    path_2.lineTo(size.width * 1.0072464, size.height * 1.0033482);
    path_2.close();

    canvas.drawPath(path_2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
