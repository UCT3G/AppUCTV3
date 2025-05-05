import 'package:app_uct/models/tema_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatelessWidget {
  final Tema tema;

  PdfScreen({required this.tema});

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
      body: SfPdfViewer.network(
        'https://uct.tresguerras.com.mx:8000/recurso?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkYXRhL1VDM0dfTUFURVJJQVMvbWF0ZXJpYTEwMTIvdW5pZGFkMTEwNC90ZW1hMzc1Mi9yZWN1cnNvX2Jhc2ljby5wZGYifQ.L-9RXik8dHZB_KfoYjeyl72R5gAA7qAO8fjj2ltgQXI',
      ),
    );
  }
}
