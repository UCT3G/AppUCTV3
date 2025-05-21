// import 'dart:developer';
import 'dart:io';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ArchivoScreen extends StatefulWidget {
  final Tema tema;

  const ArchivoScreen({super.key, required this.tema});

  @override
  State<ArchivoScreen> createState() => _ArchivoScreenState();
}

class _ArchivoScreenState extends State<ArchivoScreen> {
  double _progreso = 0.0;
  bool _descargando = false;

  Future<String> obtenerDirectorioDescarga() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Permiso de almacenamiento denegado');
      }
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory.path;
      } else {
        throw Exception('No se pudo acceder a la carpeta de descargas');
      }
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      throw Exception('Plataforma no soportada');
    }
  }

  Future<void> descargarArchivo() async {
    setState(() {
      _descargando = true;
      _progreso = 0.0;
    });

    try {
      final nombreArchivo = widget.tema.rutaRecurso.split('/').last;
      final descargableURL =
          '${ApiService.baseURL}/descargar_movil/${widget.tema.idCurso}/${widget.tema.idUnidad}/${widget.tema.idTema}/$nombreArchivo';
      final saveDirectory = await obtenerDirectorioDescarga();
      final savePath = '$saveDirectory/${widget.tema.idTema}_$nombreArchivo';

      await Dio().download(
        descargableURL,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              _progreso = count / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo guardado en: $savePath')),
        );
      }

      await OpenFilex.open(savePath);
    } catch (e) {
      debugPrint('Error al descargar: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _descargando = false;
      });
    }
  }

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
        child: Stack(
          children: [
            GestureDetector(
              onTap: descargarArchivo,
              child: Image.asset('assets/images/archivo_descargable.png'),
            ),
            if (_descargando)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(value: _progreso),
                  const SizedBox(height: 10),
                  Text('${(_progreso * 100).toStringAsFixed(0)}%'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
