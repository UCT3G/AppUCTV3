import 'dart:io';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PracticaScreen extends StatefulWidget {
  final Tema tema;
  const PracticaScreen({super.key, required this.tema});

  @override
  State<PracticaScreen> createState() => _PracticaScreenState();
}

class _PracticaScreenState extends State<PracticaScreen> {
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
        throw Exception('No se puede acceder a la carpeta de descargas');
      }
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      throw Exception('Plataforma no soportada');
    }
  }

  Future<void> descargarPractica() async {
    setState(() {
      _descargando = true;
      _progreso = 0.0;
    });

    try {
      final nombreArchivo = widget.tema.rutaRecurso.split('/').last;
      final descargableURL =
          '${ApiService.baseURL}/descargar_movil/${widget.tema.idCurso}/${widget.tema.idUnidad}/${widget.tema.idTema}/$nombreArchivo';
      final saveDirectory = await obtenerDirectorioDescarga();
      final savePath =
          '$saveDirectory/practica_${widget.tema.idTema}_$nombreArchivo';

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
          SnackBar(content: Text('Practica guardada en: $savePath')),
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

  Future<void> descargarPracticaSubida() async {
    setState(() {
      _descargando = true;
      _progreso = 0.0;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final nombreArchivo = 'practica_tema${widget.tema.idTema}.pdf';
      final descargableURL =
          '${ApiService.baseURL}/descargar_practica_movil/${authProvider.currentUsuario!.idUsuario}/$nombreArchivo';
      final saveDirectory = await obtenerDirectorioDescarga();
      final savePath =
          '$saveDirectory/practicaSubida_${widget.tema.idTema}_$nombreArchivo';

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
          SnackBar(content: Text('Practica subida guardada en: $savePath')),
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

  Future<void> subirPractica() async {
    try {
      final competenciaProvider = Provider.of<CompetenciaProvider>(
        context,
        listen: false,
      );
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (resultado == null ||
          resultado.files.isEmpty ||
          resultado.files.first.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se seleccionó ningún archivo')),
          );
        }
        return;
      }

      // Dart aquí ya reconoce que `resultado` no es null.
      final archivo = File(resultado.files.first.path!);

      final response = await competenciaProvider.subirPractica(
        widget.tema.idTema,
        archivo,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la practica: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);

    final temaActualizado = competenciaProvider.unidades
        .expand((unidad) => unidad.temas)
        .firstWhere(
          (t) => t.idTema == widget.tema.idTema,
          orElse: () => widget.tema,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tema.titulo),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Archivo de la práctica:"),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text("Ver practica"),
                trailing: ElevatedButton.icon(
                  onPressed: () => descargarPractica(),
                  icon: Icon(Icons.download),
                  label: Text('Descargar'),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text('Tu entrega'),
            const SizedBox(height: 8),
            temaActualizado.intentosConsumidos > 0
                ? Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.file_present),
                          title: Text('Archivo subido'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: descargarPracticaSubida,
                              icon: Icon(Icons.file_download),
                              label: Text("Evidencia"),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: subirPractica,
                              icon: Icon(Icons.upload_file),
                              label: Text("Volver a subir"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                : ElevatedButton.icon(
                  onPressed: subirPractica,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Subir práctica"),
                ),
            const SizedBox(height: 24),
            Text(
              "Calificación:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                "${widget.tema.resultado} / 100",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              "Comentarios:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(widget.tema.observaciones),
              ),
            ),
            //COMENTARIOS
          ],
        ),
      ),
    );
  }
}
