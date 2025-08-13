import 'package:flutter/material.dart';

class DialogErrorConnection extends StatelessWidget {
  final String title;
  final String message;
  final String imagePath;
  final double heightFactor;
  final List<Widget> actions;

  const DialogErrorConnection({
    super.key,
    required this.title,
    required this.message,
    required this.imagePath,
    this.heightFactor = 0.3,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * heightFactor;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: imageHeight / 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: imageHeight / 4,
                bottom: 15,
                right: 15,
                left: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      color: Colors.grey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      color: Colors.grey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 20),
                  ...actions,
                ],
              ),
            ),
          ),
          Positioned(
            top: -(imageHeight / 4), // Hace que la imagen sobresalga
            child: SizedBox(
              height: imageHeight,
              child: Image.asset(
                'assets/images/YowiError.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
