import 'package:flutter/material.dart';

class EvaluacionScreen extends StatelessWidget {
  const EvaluacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(162, 157, 205, 1),
                Color.fromRGBO(165, 210, 241, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'EVALUACIOON',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Montserrat',
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Center(
        child: Text('Esta es la evaluacion, suerte bb!'),
      ),
    );
  }
}