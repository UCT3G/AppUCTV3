import 'dart:developer';

import 'package:app_uct/models/tema_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticuloScreen extends StatelessWidget {
  final Tema tema;

  const ArticuloScreen({super.key, required this.tema});

  Future<void> abrirURL(Uri url) async{  
    log('$url');
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

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
        child: GestureDetector(
          onTap: () => abrirURL(Uri.parse(tema.rutaRecurso)),
          child: Image.asset('assets/images/articulo.png'),
        ),
      ),
    );
  }
}
