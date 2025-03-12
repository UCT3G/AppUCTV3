import 'package:app_uct/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF84A9CA), // #A5D0EF
                  Color(0xFF575398), // #A29ECE
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: WavePainter())),
          Positioned(
            top: 50,
            right: 20,
            child: Lottie.asset(
              "assets/animations/cloud-animation.json",
              width: 70,
            ),
          ),
          Positioned(
            top: 200,
            left: 20,
            child: Lottie.asset(
              "assets/animations/cloud-animation.json",
              width: 200,
            ),
          ),
          Positioned(
            top: 250,
            right: 20,
            child: Lottie.asset(
              "assets/animations/cloud-animation.json",
              width: 150,
            ),
          ),
        ],
      ),
    );
  }
}
