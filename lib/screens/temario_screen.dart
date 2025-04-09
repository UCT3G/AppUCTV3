import 'package:app_uct/widgets/flull_text_temario.dart';
import 'package:app_uct/widgets/normal_view_temario.dart';
import 'package:flutter/material.dart';
import 'package:app_uct/widgets/painter_temario.dart';

class TemarioScreen extends StatefulWidget {
  const TemarioScreen({super.key});

  @override
  State<TemarioScreen> createState() => _TemarioScreenState();
}

class _TemarioScreenState extends State<TemarioScreen> {
  bool showFullText = false;
  final List<String> competencias = [
    "ISO 27001",
    "Seguridad de la información",
    "Protección de datos",
    "Auditoría de sistemas",
  ];

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
                RoadSegment(type: SegmentType.start),

                // 🧩 Curvas intermedias
                ...List.generate(competencias.length, (index) {
                  final isEven = index % 2 == 0;
                  return RoadSegment(
                    type: isEven ? SegmentType.left : SegmentType.right,
                    title: competencias[index],
                  );
                }),

                // 🏁 Carretera de final
                RoadSegment(type: SegmentType.end),
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

enum SegmentType { start, left, right, end }

class RoadSegment extends StatelessWidget {
  final SegmentType type;
  final String? title;

  const RoadSegment({required this.type, this.title});

  String get assetPath {
    switch (type) {
      case SegmentType.start:
        return 'assets/images/CarreteraInicio.png';
      case SegmentType.left:
        return 'assets/images/CarreteraDerecha.png';
      case SegmentType.right:
        return 'assets/images/CarreteraIzquierda.png';
      case SegmentType.end:
        return 'assets/images/CarreteraFinal.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(assetPath, fit: BoxFit.cover, width: double.infinity),
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(title!, style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
      ],
    );
  }
}
