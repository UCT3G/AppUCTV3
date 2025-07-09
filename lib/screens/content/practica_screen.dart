import 'dart:io';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<String> obtenerDirectorioDescarga() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (status.isDenied || status.isRestricted) {
        status = await Permission.manageExternalStorage.request();
      }
      if (!status.isGranted) {
        openAppSettings();
        throw Exception('Permiso de almacenamiento denegado');
      }

      Directory downloadsDirectory = Directory('/storage/emulated/0/Download');

      if (!await downloadsDirectory.exists()) {
        downloadsDirectory =
            await getExternalStorageDirectory() ?? downloadsDirectory;
      }

      return downloadsDirectory.path;
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      throw Exception('Plataforma no soportada');
    }
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
      final nombreArchivo = tema.rutaRecurso.split('/').last;
      final descargableURL =
          '${ApiService.baseURL}/descargar_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}/$nombreArchivo';
      final saveDirectory = await obtenerDirectorioDescarga();
      final savePath = '$saveDirectory/practica_${tema.idTema}_$nombreArchivo';

      await Dio().download(
        descargableURL,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              _progresoPractica = count / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Practica guardada en: $savePath',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        );
      }

      await OpenFilex.open(savePath);
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
      final nombreArchivo = 'practica_tema${tema.idTema}.pdf';
      final descargableURL =
          '${ApiService.baseURL}/descargar_practica_movil/${authProvider.currentUsuario!.idUsuario}/$nombreArchivo';
      final saveDirectory = await obtenerDirectorioDescarga();
      final savePath =
          '$saveDirectory/practicaSubida_${tema.idTema}_$nombreArchivo';

      await Dio().download(
        descargableURL,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              _progresoSubida = count / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Practica subida guardada en: $savePath',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        );
      }

      await OpenFilex.open(savePath);
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
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar la presentación: $e',
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
      }
    }
  }

  Future<void> atrasarAdelantarTema(
    BuildContext parentContext,
    int accion,
  ) async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      parentContext,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;
    final unidad = competenciaProvider.unidades.firstWhere(
      (u) => u.idUnidad == tema.idUnidad,
    );

    try {
      final response = await competenciaProvider.adelantarAtrasarTemas(
        tema.idCurso,
        unidad.idUnidad,
        tema.orden,
        unidad.orden,
        accion,
      );
      if (response['tema_usuario'] == 0) {
        if (parentContext.mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
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
        if (response['comentario'].contains('Ya no hay mas temas')) {
          if (parentContext.mounted) {
            await showDialog(
              context: parentContext,
              barrierDismissible: false,
              builder: (BuildContext context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final imageSize = screenWidth * 0.4;

                return Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      // Card contenedor
                      Container(
                        margin: EdgeInsets.only(left: imageSize / 2),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: imageSize / 2,
                            ), // Espacio para la imagen
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Estimado Usuario",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Ya no hay más temas para ver.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: const Text("Salir"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Imagen a la izquierda, sobrepuesta
                      Positioned(
                        left: 0,
                        child: SizedBox(
                          width: imageSize,
                          child: Image.asset(
                            'assets/images/yowi_perfil.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return;
        }
      } else {
        if (parentContext.mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
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
        final nuevoTema =
            competenciaProvider.getTemaById(response['tema_usuario'])!;
        switch (nuevoTema.recursoBasicoTipo) {
          case 'VIDEO':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.video,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'IMAGEN':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.imagen,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'DOCUMENTO':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.pdf,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'PDF':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.pdf,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'ARCHIVO':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.archivo,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'ARTICULO':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.articulo,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'PRESENCIAL':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.presencial,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'PRESENTACION':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.presentacion,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'PRACTICA':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.practica,
                arguments: nuevoTema.idTema,
              );
            }
            break;
          case 'EVALUACION':
            try {
              final response = await competenciaProvider.validarTemasUnidad(
                nuevoTema.idUnidad,
                nuevoTema.idTema,
                nuevoTema.idCurso,
                nuevoTema.recursoBasicoTipo,
              );

              final comentario = response['comentario'] ?? '';

              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
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
              if (comentario.contains('No tienes mas intentos')) {
                if (parentContext.mounted) {
                  await showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final imageSize = screenWidth * 0.4;

                      return Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.centerLeft,
                          children: [
                            // Card contenedor
                            Container(
                              margin: EdgeInsets.only(left: imageSize / 2),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: imageSize / 2,
                                  ), // Espacio para la imagen
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Estimado Usuario",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                            decoration: TextDecoration.none,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Lo siento no puedes contestar esta evaluación, ya consumiste todos los intentos.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                            decoration: TextDecoration.none,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 20),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text("Salir"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Imagen a la izquierda, sobrepuesta
                            Positioned(
                              left: 0,
                              child: SizedBox(
                                width: imageSize,
                                child: Image.asset(
                                  'assets/images/yowi_perfil.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return;
              } else if (comentario.contains(
                'No puede contestar esta encuesta',
              )) {
                if (parentContext.mounted) {
                  await showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final imageSize = screenWidth * 0.4;

                      return Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.centerLeft,
                          children: [
                            // Card contenedor
                            Container(
                              margin: EdgeInsets.only(left: imageSize / 2),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: imageSize / 2,
                                  ), // Espacio para la imagen
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Estimado Usuario",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                            decoration: TextDecoration.none,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Lo siento no puedes contestar esta evaluación, no has visto todos los temas.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                            decoration: TextDecoration.none,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 20),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text("Salir"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Imagen a la izquierda, sobrepuesta
                            Positioned(
                              left: 0,
                              child: SizedBox(
                                width: imageSize,
                                child: Image.asset(
                                  'assets/images/yowi_perfil.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return;
              }
            } catch (e) {
              if (e.toString().contains('Sesión expirada.')) {
                if (parentContext.mounted) {
                  Navigator.pushReplacementNamed(
                    parentContext,
                    AppRoutes.login,
                  );
                  return;
                }
              }
              debugPrint('Error: $e');
              if (parentContext.mounted) {
                Navigator.of(parentContext, rootNavigator: true).pop();
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Error: $e',
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
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.evaluacion,
                arguments: tema.idTema,
              );
            }
            break;
        }
      }
    } catch (e) {
      if (e.toString().contains('Sesión expirada.')) {
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      debugPrint('Error: $e');
      if (parentContext.mounted) {
        Navigator.of(parentContext, rootNavigator: true).pop();
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar la presentación: $e',
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

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final tema = competenciaProvider.getTemaById(widget.idTema)!;
    final currentUnidad = competenciaProvider.unidades.firstWhere(
      (u) => u.idUnidad == tema.idUnidad,
    );

    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 600;

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
          tema.titulo,
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
          Column(
            children: [
              BreadcrumbNav(
                paths: [
                  competenciaProvider.competencia!.titulo ?? 'Competencia',
                  currentUnidad.titulo,
                  tema.titulo,
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/Practica.png'),
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
                                style: TextStyle(fontFamily: 'Montserrat'),
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
                                color: Colors.black.withValues(alpha: 0.1),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        ElevatedButton.icon(
                                          onPressed: descargarPracticaSubida,
                                          icon: Icon(Icons.file_download),
                                          label: Text(
                                            "Evidencia",
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: subirPractica,
                                          icon: Icon(Icons.upload_file),
                                          label: Text(
                                            "Volver a subir",
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
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
                              style: TextStyle(fontFamily: 'Montserrat'),
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
                                color: Colors.black.withValues(alpha: 0.1),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              tema.observaciones,
                              style: TextStyle(fontFamily: 'Montserrat'),
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
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          atrasarAdelantarTema(context, 0);
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
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          atrasarAdelantarTema(context, 1);
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
            ],
          ),
        ],
      ),
    );
  }
}
