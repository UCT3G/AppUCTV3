import 'dart:developer';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:flutter/material.dart';

class ImagenScreen extends StatefulWidget {
  final Tema tema;

  const ImagenScreen({super.key, required this.tema});

  @override
  State<ImagenScreen> createState() => _ImagenScreenState();
}

class _ImagenScreenState extends State<ImagenScreen> {
  @override
  Widget build(BuildContext context) {
    final nombreArchivo = widget.tema.rutaRecurso.split('/').last;
    log(nombreArchivo);

    final imagenURL = Uri.parse(
      '${ApiService.baseURL}/imagen_movil/${widget.tema.idCurso}/${widget.tema.idUnidad}/${widget.tema.idTema}/$nombreArchivo',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tema.titulo),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(double.infinity),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imagenURL.toString(),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
