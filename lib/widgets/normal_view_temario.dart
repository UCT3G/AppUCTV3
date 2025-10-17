import 'package:flutter/material.dart';

Widget buildNormalView(String titulo, BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isLandscape = screenSize.width > screenSize.height;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Image.asset(
        "assets/images/Yowi2.png",
        width: screenSize.width * 0.3,
        height: screenSize.height * 0.3,
        alignment: Alignment.bottomLeft,
      ),
      SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height:
                isLandscape
                    ? screenSize.height * 0.30
                    : screenSize.height * 0.20,
            child: SingleChildScrollView(
              child: Text(
                titulo.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * (isLandscape ? 0.04 : 0.065),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
