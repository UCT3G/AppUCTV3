import 'dart:math';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/screens/temario_screen.dart';
import 'package:flutter/material.dart';

class RoadSegment extends StatefulWidget {
  final SegmentType type;
  final Tema tema;
  final bool esSiguienteTema;

  const RoadSegment({
    super.key,
    required this.type,
    required this.tema,
    required this.esSiguienteTema,
  });

  @override
  State<RoadSegment> createState() => _RoadSegmentState();
}

class _RoadSegmentState extends State<RoadSegment> {
  static const Map<String, IconData> _resourceIcons = {
    'ARCHIVO': Icons.insert_drive_file,
    'ARTICULO': Icons.article,
    'DOCUMENTO': Icons.description,
    'ENCUESTA': Icons.assignment,
    'EVALUACION': Icons.quiz,
    'IMAGEN': Icons.image,
    'INTERACTIVO': Icons.html,
    'PDF': Icons.picture_as_pdf,
    'PRACTICA': Icons.science,
    'PRESENCIAL': Icons.person,
    'PRESENTACION': Icons.slideshow,
    'VIDEO': Icons.videocam,
  };

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

  Future<void> showTemarioDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final imageHeight = MediaQuery.of(context).size.height * 0.15;

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
                      color: Colors.black.withOpacity(0.2),
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
                        widget.tema.titulo,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.tema.intentosConsumidos} visualizaciones',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
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
                            onPressed: () => Navigator.pop(context),
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
                              switch (widget.tema.recursoBasicoTipo) {
                                case 'VIDEO':
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.video,
                                    arguments: widget.tema,
                                  );
                                  break;
                                case 'IMAGEN':
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.imagen,
                                    arguments: widget.tema,
                                  );
                                  break;
                                case 'DOCUMENTO':
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.pdf,
                                    arguments: widget.tema,
                                  );
                                  break;
                                case 'ARCHIVO':
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.archivo,
                                    arguments: widget.tema,
                                  );
                                  break;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
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
            onTap: () {
              showTemarioDialog();
            },
            child: SizedBox(
              width: screenSize.width * 0.7,
              height: screenSize.height * 0.13,
              child: Card(
                color:
                    (widget.tema.intentosConsumidos > 0 &&
                            widget.tema.resultado > 0)
                        ? Color.fromRGBO(
                          184,
                          255,
                          102,
                          1,
                        ).withValues(alpha: 0.5)
                        : widget.esSiguienteTema
                        ? Color.fromRGBO(255, 44, 80, 1).withValues(alpha: 0.6)
                        : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(width: 1, color: Colors.grey.shade400),
                ),
                elevation: 5,
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
                        widget.tema.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color:
                              (widget.tema.intentosConsumidos > 0 &&
                                      widget.tema.resultado > 0)
                                  ? Color.fromRGBO(19, 79, 8, 1)
                                  : widget.esSiguienteTema
                                  ? Color.fromRGBO(66, 5, 5, 1)
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
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFCC151A),
            child: Icon(
              _resourceIcons[widget.tema.recursoBasicoTipo] ??
                  Icons.note_rounded,
              color: Colors.white,
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
