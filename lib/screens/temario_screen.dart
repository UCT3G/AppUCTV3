import 'package:app_uct/widgets/flull_text_temario.dart';
import 'package:app_uct/widgets/normal_view_temario.dart';
import 'package:app_uct/widgets/road_segment.dart';
import 'package:flutter/material.dart';
import 'package:app_uct/widgets/painter_temario.dart';

class TemarioScreen extends StatefulWidget {
  const TemarioScreen({super.key});

  @override
  State<TemarioScreen> createState() => _TemarioScreenState();
}

class _TemarioScreenState extends State<TemarioScreen> {
  bool showFullText = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final gradientHeight = screenSize.height * 0.25;

    return Scaffold(
      body: Stack(
        children: [
          // Parte scrollable (carretera y contenido)
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: gradientHeight + 20),
                ...buildRoadSegments(),
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
                    colors: [Color(0xFFF6A431), Color(0xFFCC151A)],
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
                            showFullText = !showFullText;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: AnimatedSwitcher(
                            duration: Duration(microseconds: 300),
                            child:
                                showFullText
                                    ? buildFullText()
                                    : buildNormalView(screenSize),
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

List<Widget> buildRoadSegments() {
  List<Widget> segments = [];
  bool nextCurveIsLeft = true;
  int totalTemas = 0;

  final unidades = [
    {
      "id_unidad": 1103,
      "titulo": "Antecedentes del servicio",
      "orden": 1,
      "temas": [
        {
          "id_tema": 3735,
          "titulo": "Bienvenida del Director",
          "descripcion": "Descripcion del tema",
          "orden": 1,
        },
        {
          "id_tema": 3736,
          "titulo": "Bienvenida y presentación",
          "descripcion": "Descripcion del tema",
          "orden": 2,
        },
        {
          "id_tema": 3737,
          "titulo": "Por que ADN del Servicio Tresguerras",
          "descripcion": "Descripcion del tema",
          "orden": 3,
        },
      ],
      "id_curso_fk": 1012,
    },
    {
      "id_unidad": 1104,
      "titulo": "Atención de Excelencia",
      "orden": 2,
      "temas": [
        {
          "id_tema": 3747,
          "titulo": "5 elementos de una empresa exitosa",
          "descripcion": "Descripcion del tema",
          "orden": 1,
        },
      ],
      "id_curso_fk": 1012,
    },
  ];

  for (var unidad in unidades) {
    totalTemas += (unidad['temas'] as List).length;
  }

  bool isTotalPar = totalTemas % 2 == 0;

  for (var unidad in unidades) {
    final temas = unidad['temas'] as List; // Accede como mapa
    for (var tema in temas) {
      SegmentType type;
      if (segments.isEmpty) {
        type = SegmentType.start;
      } else if (unidad == unidades.last && tema == temas.last) {
        print('CURVA IZQUIERDA: $nextCurveIsLeft');
        type = isTotalPar ? SegmentType.endLeft : SegmentType.endRight;
      } else {
        type = nextCurveIsLeft ? SegmentType.left : SegmentType.right;
        nextCurveIsLeft = !nextCurveIsLeft;
      }
      segments.add(
        RoadSegment(
          type: type,
          titulo: tema['titulo'] as String, // Accede como mapa
        ),
      );
    }
  }

  return segments;
}
