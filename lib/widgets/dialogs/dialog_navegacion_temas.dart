import 'package:flutter/material.dart';

class DialogNavegacionTemas extends StatelessWidget {
  final String title;
  final String message;
  final String imagePath;
  final double heightFactor;
  final List<Widget> actions;

  const DialogNavegacionTemas({
    super.key,
    required this.title,
    required this.message,
    required this.imagePath,
    this.heightFactor = 0.4,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * heightFactor;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // Card contenedor
          Container(
            margin: EdgeInsets.only(left: imageSize / 2),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: imageSize / 2), // Espacio para la imagen
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 20),
                      ...actions,
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Imagen a la izquierda, sobrepuesta
          Positioned(
            left: 0,
            child: SizedBox(
              width: imageSize,
              child: Image.asset(
                'assets/images/yowi_perfil.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
