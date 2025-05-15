// import 'dart:developer';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_navigator.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/widgets/painter_welcome.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<double> _animation1;
  late AnimationController _controller2;
  late Animation<double> _animation2;
  String _comentario = "";

  Future<void> loadCompetencia() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final competenciaProvider = Provider.of<CompetenciaProvider>(
      context,
      listen: false,
    );

    final accessToken = authProvider.accessToken;

    try {
      final competenciaData = await competenciaProvider.fetchCompetenciaActual(
        accessToken!,
      );

      setState(() {
        _comentario = competenciaData['comentario'];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            content: Text(
              competenciaData['comentario'],
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
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCompetencia();
    });

    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );

    _animation1 = Tween<double>(begin: -100, end: 500).animate(_controller1)
      ..addListener(() {
        setState(() {});
      });
    _controller1.repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );

    _animation2 = Tween<double>(begin: -100, end: 500).animate(_controller2)
      ..addListener(() {
        setState(() {});
      });
    _controller2.repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final competenciaProvider = Provider.of<CompetenciaProvider>(context);
    final competencia = Provider.of<CompetenciaProvider>(context).competencia;

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
          Positioned.fill(child: CustomPaint(painter: PainterWelcome())),
          Positioned(
            top: screenSize.height * 0.05,
            right: _animation1.value,
            child: Image.asset(
              "assets/images/lil_claud.png",
              width: screenSize.width * 0.2,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.2,
            left: _animation2.value,
            child: Image.asset(
              "assets/images/medium_claud.png",
              width: screenSize.width * 0.4,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: screenSize.width * 0.5,
                height: screenSize.width * 0.5,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 5,
                            spreadRadius: 8,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/yowi_web.png",
                          width: screenSize.width * 0.45,
                          height: screenSize.width * 0.45,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.2 + screenSize.width * 0.5,
            left: 20,
            right: 20,
            bottom: 0,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      screenSize.height *
                      0.3, // Asegura que se vea centrado en pantallas grandes
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "BIENVENIDO",
                        style: TextStyle(
                          color: Color(0xFF574293),
                          fontSize: screenSize.height * 0.05,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "a la app de",
                        style: TextStyle(
                          color: Color(0xFF574293),
                          fontSize: screenSize.height * 0.025,
                          height: 1.0,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "UCT",
                        style: TextStyle(
                          color: Color(0xFF574293),
                          fontSize: screenSize.height * 0.05,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      if (_comentario == 'No hay competencias pendientes.')
                        Column(
                          children: [
                            Text(
                              "¡FELICIDADES! No tienes competencias pendientes.",
                              style: TextStyle(
                                color: Color(0xFF4D4D4D),
                                fontSize: screenSize.height * 0.025,
                                height: 1.0,
                                fontFamily: 'Montserrat',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Tu aprendizaje no termina aquí. Revisa la app periódicamente para nuevos contenidos.',
                              style: TextStyle(
                                color: Color(0xFF4D4D4D),
                                fontSize: screenSize.height * 0.025,
                                fontStyle: FontStyle.italic,
                                height: 1.2,
                                fontFamily: 'Montserrat',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      if (_comentario ==
                              'Curso actual obtenido correctamente.' ||
                          _comentario == 'Curso nuevo obtenido correctamente.')
                        Column(
                          children: [
                            Text(
                              _comentario ==
                                      'Curso actual obtenido correctamente.'
                                  ? "Estás trabajando en:"
                                  : "Tienes una competencia pendiente:",
                              style: TextStyle(
                                color: Color(0xFF4D4D4D),
                                fontSize: screenSize.height * 0.025,
                                height: 1.0,
                                fontFamily: 'Montserrat',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ), // Para evitar que se corte el texto
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: screenSize.width * 0.8,
                                ),
                                child: Text(
                                  competencia?.tituloCurso ?? '',
                                  style: TextStyle(
                                    color: Color(0xFF4D4D4D),
                                    fontSize: screenSize.height * 0.025,
                                    fontStyle: FontStyle.italic,
                                    height: 1.2,
                                    fontFamily: 'Montserrat',
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                            SizedBox(
                              width: screenSize.width * 0.5,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.temario,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF86CBC8),
                                          Color(0xFF574293),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Continuar',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      SizedBox(
                        width: screenSize.width * 0.5,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.home,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Competencias',
                                  style: TextStyle(fontFamily: 'Montserrat'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.015,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA29DCD), Color(0xFFA5D2F1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
