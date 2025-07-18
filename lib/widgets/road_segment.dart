import 'dart:math';

import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/screens/temario_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoadSegment extends StatefulWidget {
  final SegmentType type;
  final int idTema;

  const RoadSegment({super.key, required this.type, required this.idTema});

  @override
  State<RoadSegment> createState() => _RoadSegmentState();
}

class _RoadSegmentState extends State<RoadSegment> {
  static const Map<String, IconData> _resourceIcons = {
    'ARCHIVO': Icons.insert_drive_file,
    'ARTICULO': Icons.article,
    'ENCUESTA': Icons.assignment,
    'EVALUACION': Icons.quiz,
    'IMAGEN': Icons.image,
    'INTERACTIVO': Icons.html,
    'TEMPLATE': Icons.html,
    'PDF': Icons.picture_as_pdf,
    'PRACTICA': Icons.science,
    'PRESENCIAL': Icons.person,
    'PRESENTACION': Icons.video_label,
    'VIDEO': Icons.slideshow,
  };

  static const List<Color> _predefinedColors = [
    Color(0xFF574293),
    Color(0xFF05696E),
    Color(0xFFCC151A),
    Color(0xFF7B2884),
  ];

  String get _assetPath {
    switch (widget.type) {
      case SegmentType.start:
        return 'assets/images/Continuacioninicio.png';
      case SegmentType.left:
        return 'assets/images/CurvaIzquierda.png';
      case SegmentType.right:
        return 'assets/images/CurvaDerecha.png';
      case SegmentType.endLeft:
        return 'assets/images/Finalizq.png';
      case SegmentType.endRight:
        return 'assets/images/Finalder.png';
    }
  }

  static const List<String> _randomImages = [
    'assets/images/CajaAbierta.png',
    'assets/images/Cajas.png',
    'assets/images/CamionDetras.png',
    'assets/images/CamionFrente.png',
  ];

  late bool _showExtraImage;
  late String? _extraImagePath;
  late bool _isImageAbove; // true = arriba, false = abajo (contenedor)

  Future<void> showTemarioDialog(BuildContext parentContext) async {
    if (!parentContext.mounted) return;

    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final competenciaProvider = Provider.of<CompetenciaProvider>(
          dialogContext,
        );
        final tema = competenciaProvider.getTemaById(widget.idTema)!;
        final unidad = competenciaProvider.unidades.firstWhere(
          (u) => u.idUnidad == tema.idUnidad,
        );
        final imageHeight = MediaQuery.of(dialogContext).size.height * 0.15;

        if (competenciaProvider.loadingDialog) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: imageHeight / 2,
                ), // Espacio para la imagen
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tema.titulo ?? 'Titulo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(dialogContext).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Contador de intentos
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${tema.intentosConsumidos} visualizaciones',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            if (tema.recursoBasicoTipo == 'EVALUACION' ||
                                tema.recursoBasicoTipo == 'PRACTICA')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.grade_rounded,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${tema.resultado}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Cerrar'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (unidad.orden > 1) {
                                try {
                                  final response = await competenciaProvider
                                      .validarUnidadAnterior(
                                        unidad.idCurso,
                                        unidad.orden,
                                      );

                                  final comentario =
                                      response['comentario'] ?? '';

                                  if (dialogContext.mounted) {
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
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
                                  if (comentario.contains(
                                    'Unidad anterior no aprobada',
                                  )) {
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                    if (parentContext.mounted) {
                                      showAlertDialog(
                                        parentContext,
                                        '¡Tienes que pasar las unidades anteriores para ver este recurso!',
                                      );
                                    }
                                    return;
                                  }
                                } catch (e) {
                                  if (e.toString().contains(
                                    'Sesión expirada.',
                                  )) {
                                    if (parentContext.mounted) {
                                      Navigator.pushReplacementNamed(
                                        parentContext,
                                        AppRoutes.login,
                                      );
                                      return;
                                    }
                                  }
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  debugPrint('Error: $e');
                                  if (parentContext.mounted) {
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
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
                              }

                              switch (tema.recursoBasicoTipo) {
                                case 'VIDEO':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.video,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'IMAGEN':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.imagen,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'DOCUMENTO':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.pdf,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'PDF':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.pdf,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'ARCHIVO':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.archivo,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'ARTICULO':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.articulo,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'PRESENCIAL':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.presencial,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'PRESENTACION':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.presentacion,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'PRACTICA':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.practica,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                                case 'INTERACTIVO':
                                case 'TEMPLATE':
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (parentContext.mounted) {
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.interactive,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break; 
                                case 'EVALUACION':
                                  try {
                                    final response = await competenciaProvider
                                        .validarTemasUnidad(
                                          tema.idUnidad,
                                          tema.idTema,
                                          tema.idCurso,
                                          tema.recursoBasicoTipo,
                                        );

                                    final comentario =
                                        response['comentario'] ?? '';

                                    if (parentContext.mounted) {
                                      ScaffoldMessenger.of(
                                        parentContext,
                                      ).showSnackBar(
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

                                    if (comentario.contains(
                                      'No tienes mas intentos',
                                    )) {
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                      if (parentContext.mounted) {
                                        showAlertDialog(
                                          parentContext,
                                          'Lo siento no puedes contestar esta evaluación, ya consumiste todos los intentos',
                                        );
                                      }
                                      return;
                                    } else if (comentario.contains(
                                      'No puede contestar esta encuesta',
                                    )) {
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                      if (parentContext.mounted) {
                                        showAlertDialog(
                                          parentContext,
                                          'Lo siento no puedes contestar esta evaluación, no has visto todos los temas.',
                                        );
                                      }
                                      return;
                                    }
                                  } catch (e) {
                                    if (e.toString().contains(
                                      'Sesión expirada.',
                                    )) {
                                      if (parentContext.mounted) {
                                        Navigator.pushReplacementNamed(
                                          parentContext,
                                          AppRoutes.login,
                                        );
                                        return;
                                      }
                                    }
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                    debugPrint('Error: $e');
                                    if (parentContext.mounted) {
                                      ScaffoldMessenger.of(
                                        parentContext,
                                      ).showSnackBar(
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
                                    Navigator.pushNamed(
                                      parentContext,
                                      AppRoutes.evaluacionIntro,
                                      arguments: tema.idTema,
                                    );
                                  }
                                  break;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(dialogContext).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Ver tema'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Imagen que sobresale (posición absoluta)
              Positioned(
                top: -(imageHeight / 2), // Hace que la imagen sobresalga
                child: SizedBox(
                  height: imageHeight,
                  child: Image.asset(
                    'assets/images/YowMitad.png',
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

  Future<void> showAlertDialog(
    BuildContext parentContext,
    String message,
  ) async {
    return await showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;
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
                    SizedBox(width: imageSize / 2), // Espacio para la imagen
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Estimado Usuario ¡Lo sentimos!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(dialogContext).primaryColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            message,
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
                              onPressed: () => Navigator.pop(dialogContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(dialogContext).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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

  @override
  void initState() {
    super.initState();

    final random = Random();

    _showExtraImage = random.nextBool();

    if (_showExtraImage) {
      _extraImagePath = _randomImages[random.nextInt(_randomImages.length)];
      _isImageAbove = random.nextBool();
    } else {
      _extraImagePath = null;
      _isImageAbove = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final tema = competenciaProvider.getTemaById(widget.idTema);
    final siguienteTema = competenciaProvider.obtenerSiguienteTema();
    final currentUnidadIndex =
        siguienteTema == null
            ? 0
            : competenciaProvider.unidades.indexWhere(
              (u) => u.idUnidad == siguienteTema.idUnidad,
            );

    final screenSize = MediaQuery.of(context).size;
    bool isCardOnRight;
    bool isCircleOnLeft;

    switch (widget.type) {
      case SegmentType.start:
        // INICIO: Círculo a la izquierda (curva hacia izquierda)
        // Tarjeta a la derecha porque viene del lado derecho
        isCardOnRight = true;
        isCircleOnLeft = true;
        break;
      case SegmentType.left:
        // CURVA IZQUIERDA: Círculo a la izquierda, tarjeta a la derecha
        isCardOnRight = false;
        isCircleOnLeft = false;
        break;
      case SegmentType.right:
        // CURVA DERECHA: Círculo a la derecha, tarjeta a la izquierda
        isCardOnRight = true;
        isCircleOnLeft = true;
        break;
      case SegmentType.endLeft:
        // FINAL: Círculo a la derecha (última curva es derecha)
        // Tarjeta a la izquierda porque termina en izquierda
        isCardOnRight = false;
        isCircleOnLeft = false;
        break;
      case SegmentType.endRight:
        // FINAL: Círculo a la izquierda (última curva es izquierda)
        // Tarjeta a la derecha porque termina en derecha
        isCardOnRight = true;
        isCircleOnLeft = true;
        break;
    }

    return Stack(
      children: [
        Image.asset(_assetPath, fit: BoxFit.cover, width: double.infinity),
        Positioned(
          top: screenSize.height * 0.02,
          left: isCardOnRight ? null : 50,
          right: isCardOnRight ? 50 : null,
          child: GestureDetector(
            onTap: () async {
              await showTemarioDialog(context);
            },
            child: SizedBox(
              width: screenSize.width * 0.7,
              height: screenSize.height * 0.13,
              child: Card(
                color:
                    (tema!.recursoBasicoTipo == 'EVALUACION' &&
                                tema.resultado >= 80) ||
                            (tema.recursoBasicoTipo != 'EVALUACION' &&
                                tema.intentosConsumidos >= 1)
                        ? Color.fromRGBO(119, 200, 0, 1)
                        : tema == siguienteTema
                        ? Color.fromRGBO(186, 15, 60, 0.7)
                        : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  // side: BorderSide(width: 1, color: Colors.grey.shade400),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tema.titulo ?? 'Titulo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color:
                              (tema.intentosConsumidos > 0 ||
                                      tema == siguienteTema)
                                  ? Colors.white
                                  : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: screenSize.height * 0.05,
          left: isCircleOnLeft ? 40 : null,
          right: isCircleOnLeft ? null : 40,
          child: Container(
            padding: const EdgeInsets.all(2), // Grosor del borde blanco
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // Color del borde
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: _predefinedColors[currentUnidadIndex],
              child: Icon(
                _resourceIcons[tema.recursoBasicoTipo] ?? Icons.note_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (_showExtraImage && _extraImagePath != null)
          Positioned(
            top: _isImageAbove ? 0 : null,
            bottom: _isImageAbove ? null : 0,
            left: isCardOnRight ? null : 0,
            right: isCardOnRight ? 0 : null,
            child: Image.asset(
              _extraImagePath!,
              width: screenSize.width * 0.18,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
  }
}
