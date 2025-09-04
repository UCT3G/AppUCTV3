// import 'dart:developer';

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/utils/navegacion_temas.dart';
import 'package:app_uct/utils/utils.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:app_uct/widgets/connection_error_widget.dart';
import 'package:app_uct/widgets/full_screen_viewer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ImagenScreen extends StatefulWidget {
  final int idTema;

  const ImagenScreen({super.key, required this.idTema});

  @override
  State<ImagenScreen> createState() => _ImagenScreenState();
}

class _ImagenScreenState extends State<ImagenScreen> {
  String? imagenUrl;
  bool _hasConnectionError = false;

  Future<void> cargarImagen() async {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    setState(() {
      _hasConnectionError = false;
    });

    try {
      final nombreArchivo = tema.rutaRecurso.split('/').last;
      final rutaImagen =
          '${ApiService.baseURL}/imagen_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}/$nombreArchivo';

      final existe = await recursoDisponible(rutaImagen);

      if (!existe) {
        setState(() {
          _hasConnectionError = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Error al cargar la imagen',
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

      imagenUrl = rutaImagen;

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
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Error al cargar la imagen: $e',
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

  void openFullScreen() {
    if (imagenUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenViewer(images: [imagenUrl!]),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cargarImagen();
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
          onRetry: cargarImagen,
          message: 'Error al cargar el recurso, intenta de nuevo.',
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
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
            Column(
              children: [
                BreadcrumbNav(
                  paths: [
                    competenciaProvider.competencia!.titulo ?? 'Competencia',
                    currentUnidad.titulo,
                    tema.titulo ?? 'Titulo',
                  ],
                ),
                Expanded(
                  child: Center(
                    child:
                        imagenUrl == null
                            ? CircularProgressIndicator()
                            : SingleChildScrollView(
                              child: GestureDetector(
                                onTap: openFullScreen,
                                child: Image.network(
                                  imagenUrl!,
                                  fit: BoxFit.contain,
                                  width: size.width * 0.9,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/sinImagen.png',
                                      fit: BoxFit.contain,
                                      width: size.width * 0.9,
                                    );
                                  },
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
          ],
        ),
      ),
    );
  }
}
