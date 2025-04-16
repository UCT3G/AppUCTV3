import 'package:flutter/material.dart';

Widget buildNormalView(Size screenSize, String titulo) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Image.asset(
        "assets/images/Yowi2.png",
        width: screenSize.width * 0.35,
        height: screenSize.width * 0.35,
        alignment: Alignment.centerLeft,
      ),
      SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            titulo.toUpperCase(),
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
