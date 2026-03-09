import 'dart:io';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/utils/navegacion_temas.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:app_uct/widgets/connection_error_widget.dart';
import 'package:app_uct/widgets/dialogs/dialog_error_connection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PracticaScreen extends StatefulWidget {
  final int idTema;
  const PracticaScreen({super.key, required this.idTema});

  @override
  State<PracticaScreen> createState() => _PracticaScreenState();
}

class _PracticaScreenState extends State<PracticaScreen> {
  double _progresoPractica = 0.0;
  bool _descargandoPractica = false;
  double _progresoSubida = 0.0;
  bool _descargandoSubida = false;
  bool _hasConnectionError = false;

  Future<SaveInfo?> guardarEnDownloads(
    String filePath,
    String nombreArchivo,
  ) async {
    final mediaStore = MediaStore();

    final savedFile = await mediaStore.saveFile(
      tempFilePath: filePath,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    return savedFile;
  }

  Future<void> descargarPractica() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    setState(() {
      _descargandoPractica = true;
      _progresoPractica = 0.0;
    });

    try {
      final originalNombre = tema.rutaRecurso.split('/').last;
      final composedNombre = 'practica_${tema.idTema}_$originalNombre';
      final descargableURL =
          '${ApiService.baseURL}/descargar_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}/$originalNombre';

      final tempDir = await getTemporaryDirectory();
      final tempPath = "${tempDir.path}/$composedNombre";

      await Dio().download(
        descargableURL,
        tempPath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              _progresoPractica = count / total;
            });
          }
        },
      );

      final rutaFinal = await guardarEnDownloads(tempPath, composedNombre);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Practica guardada en: Downloads/App UCT/$composedNombre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        );
      }

      if (rutaFinal != null) {
        final mediaStore = MediaStore();
        try {
          // Try to get a direct file path for the content URI
          final filePath = await mediaStore.getFilePathFromUri(
            uriString: rutaFinal.uri.toString(),
          );

          if (filePath != null) {
            await OpenFilex.open(filePath);
          } else {
            // If there's no direct path, copy to a temporary file and open
            final tempDir2 = await getTemporaryDirectory();
            final tempPath2 = '${tempDir2.path}/$composedNombre';
            await mediaStore.readFileUsingUri(
              uriString: rutaFinal.uri.toString(),
              tempFilePath: tempPath2,
            );
            await OpenFilex.open(tempPath2);
          }
        } catch (e) {
          debugPrint('Error al abrir archivo desde MediaStore: $e');
          // Fallback: show toast/snackbar already handled below
        }
      }
    } catch (e) {
      debugPrint('Error al descargar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error: ${e.toString()}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return DialogErrorConnection(
              title: "Problemas de conexión",
              message:
                  "No se pudo realizar la descarga del archivo. Intenta de nuevo.",
              imagePath: 'assets/images/YowiError.png',
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF574293),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _descargandoPractica = false;
      });
    }
  }

  Future<void> descargarPracticaSubida() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _descargandoSubida = true;
      _progresoSubida = 0.0;
    });

    try {
      final originalNombre = tema.rutaRecurso.split('/').last;
      final composedNombre = 'practica_${tema.idTema}_$originalNombre';
      final descargableURL =
          '${ApiService.baseURL}/descargar_practica_movil/${authProvider.currentUsuario!.idUsuario}/$originalNombre';

      final tempDir = await getTemporaryDirectory();
      final tempPath = "${tempDir.path}/$composedNombre";

      await Dio().download(
        descargableURL,
        tempPath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              _progresoSubida = count / total;
            });
          }
        },
      );

      final rutaFinal = await guardarEnDownloads(tempPath, composedNombre);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Practica subida guardada en: $rutaFinal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        );
      }

      if (rutaFinal != null) {
        final mediaStore = MediaStore();
        try {
          // Try to get a direct file path for the content URI
          final filePath = await mediaStore.getFilePathFromUri(
            uriString: rutaFinal.uri.toString(),
          );

          if (filePath != null) {
            await OpenFilex.open(filePath);
          } else {
            // If there's no direct path, copy to a temporary file and open
            final tempDir2 = await getTemporaryDirectory();
            final tempPath2 = '${tempDir2.path}/$composedNombre';
            await mediaStore.readFileUsingUri(
              uriString: rutaFinal.uri.toString(),
              tempFilePath: tempPath2,
            );
            await OpenFilex.open(tempPath2);
          }
        } catch (e) {
          debugPrint('Error al abrir archivo desde MediaStore: $e');
          // Fallback: show toast/snackbar already handled below
        }
      }
    } catch (e) {
      debugPrint('Error al descargar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error: ${e.toString()}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return DialogErrorConnection(
              title: "Problemas de conexión",
              message:
                  "No se pudo realizar la descarga del archivo. Intenta de nuevo.",
              imagePath: 'assets/images/YowiError.png',
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF574293),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _descargandoSubida = false;
      });
    }
  }

  Future<void> actualizarTemaVisto() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    setState(() {
      _hasConnectionError = false;
    });

    try {
      final response = await competenciaProvider.actualizarTemaUsuario(
        tema.idCurso,
        tema.idTema,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              response['comentario'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (e.toString().contains('Sesión expirada.')) {
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      debugPrint('Error: $e');
      setState(() {
        _hasConnectionError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar el PDF: $e',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> subirPractica() async {
    try {
      final competenciaProvider = Provider.of<CompetenciaProvider>(
        context,
        listen: false,
      );
      final tema = competenciaProvider.getTemaById(widget.idTema)!;
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (resultado == null ||
          resultado.files.isEmpty ||
          resultado.files.first.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'No se seleccionó ningún archivo',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }
        return;
      }

      // Dart aquí ya reconoce que `resultado` no es null.
      final archivo = File(resultado.files.first.path!);

      final response = await competenciaProvider.subirPractica(
        tema.idTema,
        archivo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              response['comentario'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        );
      }
      actualizarTemaVisto();
    } catch (e) {
      if (e.toString().contains('Sesión expirada.')) {
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al subir la practica: ${e.toString()}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return DialogErrorConnection(
              title: "Problemas de conexión",
              message: "No se pudo subir el archivo. Intenta de nuevo.",
              imagePath: 'assets/images/YowiError.png',
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFF574293),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final tema = competenciaProvider.getTemaById(widget.idTema)!;
    final currentUnidad = competenciaProvider.unidades.firstWhere(
      (u) => u.idUnidad == tema.idUnidad,
    );

    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 600;

    if (competenciaProvider.loadingDialog) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            "assets/animations/3g-tracto.json",
            fit: BoxFit.cover,
            width: size.width * 0.6,
            height: size.width * 0.6,
          ),
        ),
      );
    }

    if (_hasConnectionError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: ConnectionErrorWidget(
          onRetry: actualizarTemaVisto,
          message: 'Error al cargar el recurso, intenta de nuevo.',
        ),
      );
    }

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
          tema.titulo ?? 'Titulo',
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_videos.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - kToolbarHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      BreadcrumbNav(
                        paths: [
                          competenciaProvider.competencia!.titulo ??
                              'Competencia',
                          currentUnidad.titulo,
                          tema.titulo ?? 'Titulo',
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/Practica.png',
                                fit: BoxFit.contain,
                                width: size.width * 0.9,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Archivo de la práctica:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Card(
                                elevation: 3,
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromRGBO(86, 66, 148, 1),
                                        Color.fromRGBO(165, 209, 241, 1),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.insert_drive_file,
                                      color: Colors.white,
                                    ),
                                    title: const Text(
                                      "Ver practica",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    trailing: ElevatedButton.icon(
                                      onPressed: () => descargarPractica(),
                                      icon: Icon(Icons.download),
                                      label: Text(
                                        'Descargar',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              if (_descargandoPractica)
                                Container(
                                  width: 250,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LinearProgressIndicator(
                                        value: _progresoPractica,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color.fromRGBO(165, 209, 241, 1),
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${(_progresoPractica * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: 24),
                              Text(
                                'Tu entrega',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 8),
                              tema.intentosConsumidos > 0
                                  ? Card(
                                    elevation: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromRGBO(86, 66, 148, 1),
                                            Color.fromRGBO(165, 209, 241, 1),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Icon(
                                                Icons.file_present,
                                                color: Colors.white,
                                              ),
                                              title: Text(
                                                'Archivo subido',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: ElevatedButton.icon(
                                                    onPressed:
                                                        descargarPracticaSubida,
                                                    icon: const Icon(
                                                      Icons.file_download,
                                                    ),
                                                    label: const Text(
                                                      "Evidencia",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: ElevatedButton.icon(
                                                    onPressed: subirPractica,
                                                    icon: const Icon(
                                                      Icons.upload_file,
                                                    ),
                                                    label: const Text(
                                                      "Volver a subir",
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis, // 👈 evita desbordar
                                                      softWrap: false,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  : ElevatedButton.icon(
                                    onPressed: subirPractica,
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text(
                                      "Subir práctica",
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                              SizedBox(height: 5),
                              if (_descargandoSubida)
                                Container(
                                  width: 250,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LinearProgressIndicator(
                                        value: _progresoSubida,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color.fromRGBO(165, 209, 241, 1),
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${(_progresoSubida * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),
                              if (tema.resultado > 0)
                                Row(
                                  children: [
                                    Spacer(), // Empuja el contenido hacia la derecha
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .end, // Alinea los textos a la derecha
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .end, // Todo a la derecha
                                          children: [
                                            Text(
                                              "Calificación:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ), // Espacio entre el texto y el chip
                                            Chip(
                                              label: Text(
                                                "${tema.resultado} / 100",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Montserrat',
                                                  color:
                                                      tema.resultado >= 80
                                                          ? const Color.fromRGBO(
                                                            50,
                                                            101,
                                                            53,
                                                            1,
                                                          )
                                                          : const Color.fromRGBO(
                                                            134,
                                                            26,
                                                            30,
                                                            1,
                                                          ),
                                                ),
                                              ),
                                              backgroundColor:
                                                  tema.resultado >= 80
                                                      ? const Color.fromRGBO(
                                                        221,
                                                        232,
                                                        202,
                                                        1,
                                                      )
                                                      : const Color.fromRGBO(
                                                        222,
                                                        179,
                                                        178,
                                                        1,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 24),
                              if (tema.observaciones.isNotEmpty) ...[
                                Text(
                                  "Comentarios:",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      tema.observaciones,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              //COMENTARIOS
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: isSmall ? 8 : 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 150),
                              child: ElevatedButton(
                                onPressed: () {
                                  NavegacionTemas.atrasarAdelantarTema(
                                    context,
                                    0,
                                    tema.idTema,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back_ios_new_rounded),
                                    Text(
                                      'Atras',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 150),
                              child: ElevatedButton(
                                onPressed: () {
                                  NavegacionTemas.atrasarAdelantarTema(
                                    context,
                                    1,
                                    tema.idTema,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Adelante',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
