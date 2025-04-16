import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/widgets/flull_text_temario.dart';
import 'package:app_uct/widgets/normal_view_temario.dart';
import 'package:app_uct/widgets/road_segment.dart';
import 'package:flutter/material.dart';
import 'package:app_uct/widgets/painter_temario.dart';
import 'package:provider/provider.dart';

class TemarioScreen extends StatefulWidget {
  final Map<String, dynamic> curso;

  const TemarioScreen({super.key, required this.curso});

  @override
  State<TemarioScreen> createState() => _TemarioScreenState();
}

class _TemarioScreenState extends State<TemarioScreen> {
  bool _showFullText = false;
  bool _initialLoad = true;
  late ScrollController _scrollController;
  late int _currentUnidadIndex;

  List<GlobalKey> _unidadKeys = [];

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
    ).fetchTemario(widget.curso['id_curso_fk'], accessToken!);

    final unidades =
        Provider.of<CompetenciaProvider>(context, listen: false).unidades;

    setState(() {
      _unidadKeys = List.generate(unidades.length, (_) => GlobalKey());
      _initialLoad = false;
    });
  }

  void handleScroll() {
    if (!mounted) return;

    double minDistance = double.infinity;
    int closestIndex = _currentUnidadIndex;

    for (int i = 0; i < _unidadKeys.length; i++) {
      final key = _unidadKeys[i];
      final contextUnidad = key.currentContext;
      if (contextUnidad == null) continue;

      final box = contextUnidad.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;

      // Calcula la distancia del centro de la unidad al centro de la pantalla
      final unidadCenterY = position.dy + box.size.height / 2;
      final screenCenterY = screenHeight / 2;
      final distanceToCenter = (unidadCenterY - screenCenterY).abs();

      if (distanceToCenter < minDistance) {
        minDistance = distanceToCenter;
        closestIndex = i;
      }
    }

    if (closestIndex != _currentUnidadIndex) {
      setState(() => _currentUnidadIndex = closestIndex);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUnidadIndex = 0;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTemario();
      _scrollController.addListener(handleScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: gradientHeight + 20),
                Image.asset(
                  'assets/images/Lineainicio.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                ...buildRoadSegments(competenciaProvider, _unidadKeys),
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
                    colors: _predefinedGradients[_currentUnidadIndex],
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
}

enum SegmentType { start, left, right, endLeft, endRight }

List<Widget> buildRoadSegments(
  CompetenciaProvider competenciaProvider,
  List<GlobalKey> unidadKeys,
) {
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

  for (
    int unidadIndex = 0;
    unidadIndex < competenciaProvider.unidades.length;
    unidadIndex++
  ) {
    var unidad = competenciaProvider.unidades[unidadIndex];
    GlobalKey unidadKey = unidadKeys[unidadIndex];
    List<Widget> unidadTemas = [];

    for (var tema in unidad.temas) {
      SegmentType type;
      if (esSoloUnTema) {
        type = SegmentType.endRight; // Camino especial para 1 tema/1 unidad
      } else if (segments.isEmpty) {
        type = SegmentType.start;
      } else if (temaGlobalIndex == totalTemas - 1) {
        type = isTotalPar ? SegmentType.endLeft : SegmentType.endRight;
      } else {
        type = nextCurveIsLeft ? SegmentType.left : SegmentType.right;
        nextCurveIsLeft = !nextCurveIsLeft;
      }
      bool esSiguienteTema = tema == siguienteTema;

      segments.add(
        RoadSegment(type: type, tema: tema, esSiguienteTema: esSiguienteTema),
      );
      temaGlobalIndex++;
    }
    segments.add(
      Container(key: unidadKey, child: Column(children: unidadTemas)),
    );
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
