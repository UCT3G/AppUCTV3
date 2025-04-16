import 'package:flutter/material.dart';

Widget buildFullText(String titulo) {
  return Container(
    padding: EdgeInsets.only(bottom: 20, left: 20),
    child: Text(
      titulo.toUpperCase(),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
