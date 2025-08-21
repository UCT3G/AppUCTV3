import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CompetenciaCardHorizontal extends StatefulWidget {
  final int idCompetencia;

  const CompetenciaCardHorizontal({super.key, required this.idCompetencia});

  @override
  State<CompetenciaCardHorizontal> createState() =>
      _CompetenciaCardHorizontalState();
}

class _CompetenciaCardHorizontalState extends State<CompetenciaCardHorizontal> {
  static const Map<int, String> _imageAreasTematicas = {
    1000: 'assets/images/areas_tematicas/produccion_general.svg',
    2000: 'assets/images/areas_tematicas/servicios.svg',
    3000: 'assets/images/areas_tematicas/administracion.svg',
    4000: 'assets/images/areas_tematicas/comercializacion.svg',
    5000: 'assets/images/areas_tematicas/mantenimiento.svg',
    6000: 'assets/images/areas_tematicas/seguridad.svg',
    7000: 'assets/images/areas_tematicas/desarrollo_personal.svg',
    8000: 'assets/images/areas_tematicas/uso_tecnologias.svg',
    9000: 'assets/images/areas_tematicas/participacion_social.svg',
  };

  @override
  Widget build(BuildContext context) {
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );
    final competencia = competenciaProvider.getCompetenciaById(
      widget.idCompetencia,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            competenciaProvider.setCompetencia(competencia);
            Navigator.pushNamed(context, AppRoutes.temario);
          },
          child: Container(
            width: 300,
            margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [Color(0xFFA29DCD), Color(0xFFA5D2F1)],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Icon(Icons.star_border_rounded, size: 30),
                    ),
                    ClipPath(
                      clipper: FlechaClipper(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFA29DCD), Color(0xFFA5D2F1)],
                          ),
                        ),
                        child: Text(
                          competencia!.promedio!.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    // 'FACULTAD DE CAMIONETAS -  ESTIBADORES Y OPERADORES DE CAMIONETA (ALINEACIÓN)',
                    competencia.titulo ?? 'Titulo curso',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      foreground:
                          competencia.esObligatoria == '1'
                              ? (Paint()
                                ..shader = LinearGradient(
                                  colors: [
                                    Color.fromRGBO(237, 30, 121, 0.8),
                                    Color.fromRGBO(139, 0, 0, 0.8),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(
                                  Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                ))
                              : (Paint()
                                ..color = Color.fromRGBO(86, 66, 148, 1)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Barra de progreso personalizada con gradiente y bordes redondeados
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade300, // Color del fondo
                                ),
                              ),
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    (competencia.avance ?? 0) /
                                    100, // % completado
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(
                                          0xFFA29DCD,
                                        ), // Color inicial (ejemplo)
                                        Color(
                                          0xFFA5D2F1,
                                        ), // Color final (ejemplo)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${(competencia.avance ?? 0).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Color.fromRGBO(86, 66, 148, 1),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: -5,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple,
            child: SvgPicture.asset(
              _imageAreasTematicas[competencia.areaTematica] ??
                  'assets/images/areas_tematicas/START.svg',
              width: 25,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }
}

class FlechaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(size.width * 0.3333333, size.height * 0.3316667);
    path.cubicTo(
      size.width * 0.3767083,
      size.height * 0.4960833,
      size.width * 0.3760417,
      size.height * 0.4960833,
      size.width * 0.3325,
      size.height * 0.67,
    );
    path.cubicTo(
      size.width * 0.41625,
      size.height * 0.6691667,
      size.width * 0.58375,
      size.height * 0.6675,
      size.width * 0.6675,
      size.height * 0.6666667,
    );
    path.cubicTo(
      size.width * 0.7495,
      size.height * 0.62425,
      size.width * 0.7508333,
      size.height * 0.3754167,
      size.width * 0.6675,
      size.height * 0.3316667,
    );
    path.cubicTo(
      size.width * 0.5839583,
      size.height * 0.3316667,
      size.width * 0.5839583,
      size.height * 0.3316667,
      size.width * 0.3333333,
      size.height * 0.3316667,
    );

    path.close();

    Rect bounds = path.getBounds();
    final Matrix4 matrix4 =
        Matrix4.identity()
          ..scale(size.width / bounds.width, size.height / bounds.height)
          ..translate(-bounds.left, -bounds.top);
    return path.transform(matrix4.storage);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
