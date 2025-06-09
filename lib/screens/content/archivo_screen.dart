// import 'dart:developer';
import 'dart:io';

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ArchivoScreen extends StatefulWidget {
  final int idTema;

  const ArchivoScreen({super.key, required this.idTema});

  @override
  State<ArchivoScreen> createState() => _ArchivoScreenState();
}

class _ArchivoScreenState extends State<ArchivoScreen> {
  double _progreso = 0.0;
  bool _descargando = false;

  Future<String> obtenerDirectorioDescarga() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (status.isDenied || status.isRestricted) {
        status = await Permission.manageExternalStorage.request();
      }
      if (!status.isGranted) {
        openAppSettings(); // opción para guiar al usuario si no concede el permiso
        throw Exception('Permiso de almacenamiento completo denegado.');
      }
      Directory? downloadsDirectory;

      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
      }

      if (downloadsDirectory == null || !await downloadsDirectory.exists()) {
        downloadsDirectory = await getExternalStorageDirectory();
      }

      return downloadsDirectory!.path;
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      throw Exception('Plataforma no soportada');
    }
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
      final nombreArchivo = tema.rutaRecurso.split('/').last;
      final descargableURL =
          '${ApiService.baseURL}/descargar_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}/$nombreArchivo';
      final saveDirectory = await obtenerDirectorioDescarga();
      final savePath = '$saveDirectory/${tema.idTema}_$nombreArchivo';

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
              'Error al cargar el tema: $e',
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
          Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/background_recursos.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: descargarArchivo,
                    child: Image.asset(
                      'assets/images/Archivo.png',
                      height: size.height * 0.8,
                    ),
                  ),
                ),
                if (_descargando)
                  Center(
                    child: Container(
                      width: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                              Colors.teal,
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
                BreadcrumbNav(
                  paths: [
                    competenciaProvider.competencia!.tituloCurso ??
                        'Competencia',
                    currentUnidad.titulo,
                    tema.titulo,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
