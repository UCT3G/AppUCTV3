import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImagenScreen extends StatefulWidget {
  final Tema tema;

  const ImagenScreen({super.key, required this.tema});

  @override
  State<ImagenScreen> createState() => _ImagenScreenState();
}

class _ImagenScreenState extends State<ImagenScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tema.titulo),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Image.asset(
          'assets/images/recurso_basico.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
