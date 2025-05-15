import 'dart:async';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/utils/session_helper.dart';
import 'package:app_uct/widgets/flull_text_temario.dart';
import 'package:app_uct/widgets/normal_view_temario.dart';
import 'package:app_uct/widgets/road_segment.dart';
import 'package:flutter/material.dart';
import 'package:app_uct/widgets/painter_temario.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:app_uct/routes/app_routes.dart';

class TemarioScreen extends StatefulWidget {
  const TemarioScreen({super.key});

  @override
  State<TemarioScreen> createState() => _TemarioScreenState();
}

class _TemarioScreenState extends State<TemarioScreen> {
  bool _showFullText = false;
  late int _currentUnidadIndex;
  Timer? _debounce;

  static const List<List<Color>> _predefinedGradients = [
    [Color(0xFF574293), Color(0xFF86CBC8)],
    [Color(0xFF05696E), Color(0xFF6DB75E)],
    [Color(0xFFF6A431), Color(0xFFCC151A)],
    [Color(0xFF7B2884), Color(0xFF7C8AC4)],
  ];

  Future<void> loadTemario() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );

    final accessToken = authProvider.accessToken;
    // final idCurso = competenciaProvider.competencia?.idCurso;
    final idCurso = 19;

    if (accessToken != null && idCurso != null) {
      try {
        final response = await competenciaProvider.fetchTemario(
          idCurso,
          accessToken,
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
        debugPrint('Error: $e');
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
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
  }

  @override
  void initState() {
    super.initState();
    SessionHelper.updateLastActive();
    _currentUnidadIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTemario();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final competencia = competenciaProvider.competencia;
    final screenSize = MediaQuery.of(context).size;
    final gradientHeight = screenSize.height * 0.25;

    // log('$competenciaProvider');
    if (competenciaProvider.loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            "assets/animations/3g-tracto.json",
            fit: BoxFit.cover,
            width: screenSize.width * 0.6,
            height: screenSize.width * 0.6,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Parte scrollable (carretera y contenido)
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: gradientHeight + 20),
                Image.asset(
                  'assets/images/Lineainicio.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                ...buildRoadSegments(competenciaProvider),
              ],
            ),
          ),
          // Contenedor con gradiente Y Yowi
          Column(
            children: [
              Container(
                height: gradientHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _predefinedGradients[_currentUnidadIndex % 4],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: SizedBox(
                        width: screenSize.width,
                        height: screenSize.height,
                        child: CustomPaint(painter: PainterTemario()),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: MediaQuery.of(context).padding.top,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.home,
                          );
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: MediaQuery.of(context).padding.top,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(87, 66, 147, 1),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(15),
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 30,
                          onPressed: () {},
                          icon: Icon(Icons.menu, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onDoubleTap: () {
                          setState(() {
                            _showFullText = !_showFullText;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder:
                                (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child:
                                _showFullText
                                    ? buildFullText(
                                      competencia?.tituloCurso ??
                                          'Titulo curso',
                                    )
                                    : buildNormalView(
                                      screenSize,
                                      competencia?.tituloCurso ??
                                          'Titulo curso',
                                    ),
                          ),
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

  List<Widget> buildRoadSegments(CompetenciaProvider competenciaProvider) {
    List<Widget> segments = [];
    bool nextCurveIsLeft = true;
    int totalTemas = competenciaProvider.unidades.fold(
      0,
      (sum, unidad) => sum + unidad.temas.length,
    );
    bool isTotalPar = totalTemas % 2 == 0;
    int temaGlobalIndex = 0;

    bool esSoloUnTema =
        competenciaProvider.unidades.length == 1 &&
        competenciaProvider.unidades[0].temas.length == 1;

    Tema? siguienteTema = obtenerSiguienteTema(competenciaProvider);

    _currentUnidadIndex = siguienteTema?.idUnidad ?? 1;

    for (
      int unidadIndex = 0;
      unidadIndex < competenciaProvider.unidades.length;
      unidadIndex++
    ) {
      var unidad = competenciaProvider.unidades[unidadIndex];

      for (var tema in unidad.temas) {
        SegmentType type;

        if (esSoloUnTema) {
          type = SegmentType.endRight;
        } else if (temaGlobalIndex == 0) {
          // Solo para el PRIMER tema de TODOS
          type = SegmentType.start;
        } else if (temaGlobalIndex == totalTemas - 1) {
          // Último tema
          type = isTotalPar ? SegmentType.endLeft : SegmentType.endRight;
        } else {
          type = nextCurveIsLeft ? SegmentType.left : SegmentType.right;
          nextCurveIsLeft = !nextCurveIsLeft;
        }

        segments.add(
          RoadSegment(
            type: type,
            tema: tema,
            esSiguienteTema: tema == siguienteTema,
          ),
        );
        temaGlobalIndex++; // Incrementa el contador GLOBAL de temas
      }
    }

    return segments;
  }

  Tema? obtenerSiguienteTema(CompetenciaProvider competenciaProvider) {
    for (var unidad in competenciaProvider.unidades) {
      for (var tema in unidad.temas) {
        if (tema.resultado == 0) {
          return tema;
        }
      }
    }
    return null;
  }
}

enum SegmentType { start, left, right, endLeft, endRight }
