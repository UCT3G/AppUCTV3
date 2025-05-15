import 'dart:developer';

import 'package:app_uct/models/tema_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:app_uct/services/api_service.dart';

class PdfScreen extends StatelessWidget {
  final Tema tema;

  const PdfScreen({super.key, required this.tema});

  @override
  Widget build(BuildContext context) {
    log('PDF: ${tema.rutaRecurso}');
    final pdfURL = Uri.parse(
      '${ApiService.baseURL}/pdf_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tema.titulo),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SfPdfViewer.network(pdfURL.toString()),
    );
  }
}
