import 'package:flutter/material.dart';

Widget buildNormalView(Size screenSize) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      SizedBox(
        width: screenSize.width * 0.35,
        child: Image.asset(
          "assets/images/Yowi.png",
          width: screenSize.width * 0.35,
          height: screenSize.width * 0.35,
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'FACULTAD DE CAMIONETAS -  ESTIBADORES Y OPERADORES DE CAMIONETA (ALINEACIÓN)'
                .toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
}
