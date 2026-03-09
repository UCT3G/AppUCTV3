// import 'dart:developer';
import 'dart:io';

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
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ArchivoScreen extends StatefulWidget {
  final int idTema;

  const ArchivoScreen({super.key, required this.idTema});

  @override
  State<ArchivoScreen> createState() => _ArchivoScreenState();
}

class _ArchivoScreenState extends State<ArchivoScreen> {
  double _progreso = 0.0;
  bool _descargando = false;
  bool _hasConnectionError = false;

  Future<String?> guardarEnDownloads(
    String tempPath,
    String nombreArchivo,
  ) async {
    // FilePicker.saveFile requiere bytes en Android/iOS y falla al usarlo solo para obtener una ruta.
    // En su lugar pedimos carpeta al usuario y copiamos el archivo temporal allá.
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Guardar archivo en',
    );

    if (directoryPath != null) {
      final destPath = '$directoryPath/$nombreArchivo';
      final file = File(tempPath);
      await file.copy(destPath);
      return destPath;
    }

    return null;
  }

  Future<void> descargarArchivo() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    setState(() {
      _descargando = true;
      _progreso = 0.0;
    });

    try {
      final originalNombre = tema.rutaRecurso.split('/').last;
      final composedNombre = '${tema.idTema}_$originalNombre';
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
              _progreso = count / total;
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
              'Archivo guardado.',
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
        final Uri uri = Uri.file(rutaFinal);
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            // Si por alguna razón no puede abrirlo directamente
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Archivo guardado. Ábrelo desde tu administrador de archivos.',
                  ),
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('Error al abrir el archivo: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return DialogErrorConnection(
              title: "Problemas de conexión",
              message:
                  "No se pudo realizar la descarga del archivo, intenta de nuevo.",
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
        ScaffoldMessenger.of(context).showSnackBar(
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
    } finally {
      setState(() {
        _descargando = false;
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
      setState(() {
        _hasConnectionError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      actualizarTemaVisto();
    });
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
                image: AssetImage('assets/images/background_recursos.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                BreadcrumbNav(
                  paths: [
                    competenciaProvider.competencia!.titulo ?? 'Competencia',
                    currentUnidad.titulo,
                    tema.titulo ?? 'Titulo',
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: GestureDetector(
                        onTap: descargarArchivo,
                        child: Image.asset(
                          'assets/images/Archivo.png',
                          fit: BoxFit.contain,
                          width: size.width * 0.9,
                        ),
                      ),
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
              ],
            ),
          ),
          if (_descargando)
            SafeArea(
              child: Center(
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
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
                        value: _progreso,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(165, 209, 241, 1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(_progreso * 100).toStringAsFixed(0)}%',
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
              ),
            ),
        ],
      ),
    );
  }
}
