import 'package:app_uct/screens/content/archivo_screen.dart';
import 'package:app_uct/screens/content/articulo_screen.dart';
import 'package:app_uct/screens/content/evaluacion/evaluacion_intro_screen.dart';
import 'package:app_uct/screens/content/evaluacion/evaluacion_screen.dart';
import 'package:app_uct/screens/content/imagen_screen.dart';
import 'package:app_uct/screens/content/interactive_screen.dart';
import 'package:app_uct/screens/content/pdf_screen.dart';
import 'package:app_uct/screens/content/practica_screen.dart';
import 'package:app_uct/screens/content/presencial_screen.dart';
import 'package:app_uct/screens/content/presentacion_screen.dart';
import 'package:app_uct/screens/content/video_screen.dart';
import 'package:app_uct/screens/home_screen.dart';
import 'package:app_uct/screens/login_screen.dart';
import 'package:app_uct/screens/splash_screen.dart';
import 'package:app_uct/screens/temario_screen.dart';
import 'package:app_uct/screens/welcome_screen.dart';
import 'package:flutter/widgets.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String loading = '/';
  static const String welcome = '/welcome';
  static const String interactive = '/interactive-content';
  static const String video = '/video-content';
  static const String temario = '/temario';
  static const String imagen = '/imagen';
  static const String pdf = '/pdf';
  static const String archivo = '/archivo';
  static const String articulo = '/articulo';
  static const String presencial = '/presencial';
  static const String presentacion = '/presentacion';
  static const String practica = '/practica';
  static const String evaluacionIntro = '/evaluacion_intro';
  static const String evaluacion = '/evaluacion';

  static final routes = {
    login: (context) => LoginScreen(),
    home: (context) => HomeScreen(),
    loading: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final isInitialLoad = args is bool ? args : true;
      return SplashScreen(isInitialLoad: isInitialLoad);
    },
    welcome: (context) => WelcomeScreen(),
    interactive: (context) {
      final tema =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return InteractiveScreen(tema: tema);
    },
    video: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return VideoScreen(idTema: idTema);
    },
    temario: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final fromHome = args?['fromHome'] ?? false;
      return TemarioScreen(fromHome: fromHome);
    },
    imagen: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return ImagenScreen(idTema: idTema);
    },
    pdf: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return PdfScreen(idTema: idTema);
    },
    archivo: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return ArchivoScreen(idTema: idTema);
    },
    articulo: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return ArticuloScreen(idTema: idTema);
    },
    presencial: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return PresencialScreen(idTema: idTema);
    },
    presentacion: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return PresentacionScreen(idTema: idTema);
    },
    practica: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return PracticaScreen(idTema: idTema);
    },
    evaluacionIntro: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return EvaluacionIntroScreen(idTema: idTema);
    },
    evaluacion: (context) {
      final idTema = ModalRoute.of(context)!.settings.arguments as int;
      return EvaluacionScreen(idTema: idTema);
    },
  };
}
