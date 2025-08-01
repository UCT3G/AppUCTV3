// import 'dart:developer';

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/widgets/breadcrumb_nav.dart';
import 'package:app_uct/widgets/connection_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticuloScreen extends StatefulWidget {
  final int idTema;

  const ArticuloScreen({super.key, required this.idTema});

  @override
  State<ArticuloScreen> createState() => _ArticuloScreenState();
}

class _ArticuloScreenState extends State<ArticuloScreen> {
  bool _hasConnectionError = false;

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
              'Error al cargar el articulo: $e',
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

  Future<void> abrirURL(Uri url) async {
    try {
      await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    } catch (e) {
      if (!mounted) return;
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
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          final imageHeight = MediaQuery.of(dialogContext).size.height * 0.30;

          return Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: EdgeInsets.only(top: imageHeight / 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(
                      top: imageHeight / 4,
                      bottom: 15,
                      right: 15,
                      left: 15,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Problemas de conexión",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                            color: Colors.grey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "No se pudo abrir el recurso externo. Intenta de nuevo.",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            color: Colors.grey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -(imageHeight / 4), // Hace que la imagen sobresalga
                  child: SizedBox(
                    height: imageHeight,
                    child: Image.asset(
                      'assets/images/YowiError.png',
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
          case 'INTERACTIVO':
          case 'TEMPLATE':
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.interactive,
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
                showDialog(
                  context: parentContext,
                  builder: (BuildContext dialogContext) {
                    final imageHeight =
                        MediaQuery.of(dialogContext).size.height * 0.30;

                    return Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: imageHeight / 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsetsGeometry.only(
                                top: imageHeight / 4,
                                bottom: 15,
                                right: 15,
                                left: 15,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Problemas de conexión",
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 22,
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No se pudieron validar los temas. Intenta de nuevo.",
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 18,
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(dialogContext),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey.shade600,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top:
                                -(imageHeight /
                                    4), // Hace que la imagen sobresalga
                            child: SizedBox(
                              height: imageHeight,
                              child: Image.asset(
                                'assets/images/YowiError.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
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
                arguments: nuevoTema.idTema,
              );
            }
            break;
          default:
            if (parentContext.mounted) {
              Navigator.pushReplacementNamed(
                parentContext,
                AppRoutes.recurso,
                arguments: nuevoTema.idTema,
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
        showDialog(
          context: parentContext,
          builder: (BuildContext dialogContext) {
            final imageHeight = MediaQuery.of(dialogContext).size.height * 0.30;

            return Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: imageHeight / 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(
                        top: imageHeight / 4,
                        bottom: 15,
                        right: 15,
                        left: 15,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Problemas de conexión",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 22,
                              color: Colors.grey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No se pudo navegar entre los temas. Intenta de nuevo.",
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              color: Colors.grey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -(imageHeight / 4), // Hace que la imagen sobresalga
                    child: SizedBox(
                      height: imageHeight,
                      child: Image.asset(
                        'assets/images/YowiError.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
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
                  child: GestureDetector(
                    onTap: () => abrirURL(Uri.parse(tema.rutaRecurso)),
                    child: Image.asset('assets/images/Recurso.png'),
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
