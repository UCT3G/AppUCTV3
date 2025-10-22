import 'package:flutter/material.dart';

Widget buildFullText(String titulo, BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isLandscape = screenSize.width > screenSize.height;

  return Container(
    padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
    child: SizedBox(
      // Ajusta la altura según lo que necesites
      height: isLandscape ? screenSize.height * 0.30 : screenSize.height * 0.20,
      child: SingleChildScrollView(
        child: Text(
          titulo.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenSize.width * (isLandscape ? 0.045 : 0.06),
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    ),
  );
}
