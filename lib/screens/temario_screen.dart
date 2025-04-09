import 'package:flutter/material.dart';

class TemarioScreen extends StatefulWidget {
  const TemarioScreen({super.key});

  @override
  State<TemarioScreen> createState() => _TemarioScreenState();
}

class _TemarioScreenState extends State<TemarioScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screenSize.height * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF6A431), Color(0xFFCC151A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(
              "assets/images/yowi_web.png",
              width: screenSize.width * 0.3,
              height: screenSize.width * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
