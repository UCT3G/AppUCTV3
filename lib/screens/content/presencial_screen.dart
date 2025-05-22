import 'package:app_uct/models/tema_model.dart';
import 'package:flutter/material.dart';

class PresencialScreen extends StatelessWidget {
  final Tema tema;
  const PresencialScreen({super.key, required this.tema});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tema.titulo),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Image.asset('assets/images/recurso-presencial.png'),
      ),
    );
  }
}