import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/screens/content/archivo_screen.dart';
import 'package:app_uct/screens/content/imagen_screen.dart';
import 'package:app_uct/screens/content/interactive_screen.dart';
import 'package:app_uct/screens/content/pdf_screen.dart';
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
      final tema = ModalRoute.of(context)!.settings.arguments as Tema;
      return VideoScreen(tema: tema);
    },
    temario: (context) => TemarioScreen(),
    imagen: (context) {
      final tema = ModalRoute.of(context)!.settings.arguments as Tema;
      return ImagenScreen(tema: tema);
    },
    pdf: (context) {
      final tema = ModalRoute.of(context)!.settings.arguments as Tema;
      return PdfScreen(tema: tema);
    },
    archivo: (context) {
      final tema = ModalRoute.of(context)!.settings.arguments as Tema;
      return ArchivoScreen(tema: tema);
    },
  };
}
