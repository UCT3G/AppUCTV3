import 'package:flutter/material.dart';

Widget buildFullText() {
  return Container(
    padding: EdgeInsets.only(bottom: 20),
    child: Text(
      'FACULTAD DE CAMIONETAS - ESTIBADORES Y OPERADORES DE CAMIONETA (ALINEACIÓN)'
          .toUpperCase(),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
