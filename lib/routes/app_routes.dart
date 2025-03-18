import 'package:app_uct/screens/home_page.dart';
import 'package:app_uct/screens/login_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';

  static final routes = {
    login: (context) => LoginScreen(),
    home: (context) => HomePage(),
  };
}
