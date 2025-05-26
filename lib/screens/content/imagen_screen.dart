import 'dart:developer';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/widgets/full_screen_viewer.dart';
import 'package:flutter/material.dart';

class ImagenScreen extends StatefulWidget {
  final Tema tema;

  const ImagenScreen({super.key, required this.tema});

  @override
  State<ImagenScreen> createState() => _ImagenScreenState();
}

class _ImagenScreenState extends State<ImagenScreen> {
  late String imagenUrl;

  @override
  void initState() {
    super.initState();
    final nombreArchivo = widget.tema.rutaRecurso.split('/').last;
    imagenUrl =
        '${ApiService.baseURL}/imagen_movil/${widget.tema.idCurso}/${widget.tema.idUnidad}/${widget.tema.idTema}/$nombreArchivo';
    log(imagenUrl);
  }

  void openFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullScreenViewer(images: [imagenUrl])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tema.titulo),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: GestureDetector(
          onTap: openFullScreen,
          child: Center(
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.all(double.infinity),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imagenUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
