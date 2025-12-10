import 'package:flutter/material.dart';

Widget buildNormalView(String titulo, BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isLandscape = screenSize.width > screenSize.height;

  return LayoutBuilder(
    builder: (context, constraints) {
      // Fallback to a reasonable height when constraints are unbounded.
      final maxH =
          (constraints.maxHeight > 0)
              ? constraints.maxHeight
              : (isLandscape
                  ? screenSize.height * 0.30
                  : screenSize.height * 0.20);

      final imageWidth = screenSize.width * 0.3;
      final fontSize = screenSize.width * (isLandscape ? 0.04 : 0.065);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/Yowi2.png",
            width: imageWidth,
            height: maxH,
            alignment: Alignment.bottomLeft,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              height: maxH,
              padding: EdgeInsets.only(bottom: 10),
              alignment: Alignment.center,
              child: Text(
                titulo.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
