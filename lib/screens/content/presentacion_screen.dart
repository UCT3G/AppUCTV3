// import 'dart:developer';

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:app_uct/widgets/full_screen_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PresentacionScreen extends StatefulWidget {
  final int idTema;

  const PresentacionScreen({super.key, required this.idTema});

  @override
  State<PresentacionScreen> createState() => _PresentacionScreenState();
}

class _PresentacionScreenState extends State<PresentacionScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  void openFullScreen(int initialIndex) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FullScreenViewer(
              images:
                  tema.slideImages
                      .map(
                        (img) =>
                            '${ApiService.baseURL}/presentacion_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}/$img',
                      )
                      .toList(),
              initialIndex: initialIndex,
            ),
      ),
    );
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
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Lo siento no puedes contestar esta evaluación, no has visto todos los temas.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
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
                AppRoutes.evaluacionIntro,
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      actualizarTemaVisto();
    });
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final tema = competenciaProvider.getTemaById(widget.idTema)!;
    final currentUnidad = competenciaProvider.unidades.firstWhere(
      (u) => u.idUnidad == tema.idUnidad,
    );
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 600;
    final padding = size.width * 0.04;

    final imageUrls =
        tema.slideImages
            .map(
              (img) =>
                  '${ApiService.baseURL}/presentacion_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}/$img',
            )
            .toList();

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
                // Breadcrumb arriba
                BreadcrumbNav(
                  paths: [
                    competenciaProvider.competencia!.titulo ?? 'Competencia',
                    currentUnidad.titulo,
                    tema.titulo,
                  ],
                ),

                // Contenido centrado
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: imageUrls.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => openFullScreen(index),
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 1,
                                maxScale: 4,
                                child: CachedNetworkImage(
                                  imageUrl: imageUrls[index],
                                  fit: BoxFit.contain,
                                  placeholder:
                                      (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget:
                                      (context, error, stackTrace) =>
                                          const Center(
                                            child: Text(
                                              'Error al cargar la imagen',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                          ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: imageUrls.length,
                        effect: WormEffect(
                          dotHeight: isSmall ? 8 : 10,
                          dotWidth: isSmall ? 8 : 10,
                          activeDotColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Text(
                          'Diapositiva ${_currentPage + 1} de ${imageUrls.length}',
                          style: TextStyle(
                            fontSize: isSmall ? 12 : 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Botones en el pie
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
      ),
    );
  }
}
