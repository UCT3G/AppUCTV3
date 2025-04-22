import 'dart:async';
import 'dart:developer';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/widgets/flull_text_temario.dart';
import 'package:app_uct/widgets/normal_view_temario.dart';
import 'package:app_uct/widgets/road_segment.dart';
import 'package:flutter/material.dart';
import 'package:app_uct/widgets/painter_temario.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TemarioScreen extends StatefulWidget {
  final Map<String, dynamic> curso;

  const TemarioScreen({super.key, required this.curso});

  @override
  State<TemarioScreen> createState() => _TemarioScreenState();
}

class _TemarioScreenState extends State<TemarioScreen> {
  bool _showFullText = false;
  bool _initialLoad = true;
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
    final accessToken = authProvider.accessToken;

    await Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    ).fetchTemario(1012, accessToken!);

    setState(() {
      _initialLoad = false;
    });
  }

  @override
  void initState() {
    super.initState();
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
    final screenSize = MediaQuery.of(context).size;
    final gradientHeight = screenSize.height * 0.25;

    if (_initialLoad) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (competenciaProvider.error.isNotEmpty) {
      return Scaffold(body: Center(child: Text(competenciaProvider.error)));
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
                        onPressed: () {},
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
                            duration: Duration(microseconds: 300),
                            child:
                                _showFullText
                                    ? buildFullText(
                                      widget.curso['titulo_curso'],
                                    )
                                    : buildNormalView(
                                      screenSize,
                                      widget.curso['titulo_curso'],
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

    _currentUnidadIndex = siguienteTema!.idUnidad;

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
