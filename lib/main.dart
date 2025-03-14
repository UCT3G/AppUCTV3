import 'package:app_uct/screens/home_page.dart';
import 'package:app_uct/screens/login_screen.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await getInitialRoute();
  print('Ruta inicial: $initialRoute');
  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> getInitialRoute() async {
  final accessToken = await TokenService.getAccessToken();
  final refreshToken = await TokenService.getRefreshToken();

  print('Access Token: $accessToken');
  print('Refresh Token: $refreshToken');

  if (accessToken == null || refreshToken == null) {
    print('No hay tokens, redirigiendo al login');
    return '/login';
  }

  final isAccessTokenValid = await AuthService.checkTokenValidity(accessToken);
  print('Access Token válido: $isAccessTokenValid');

  if (isAccessTokenValid) {
    print('Access Token válido, redirigiendo al home');
    return '/home';
  } else {
    final newAccessToken = await AuthService.refreshAccessToken(refreshToken);

    if (newAccessToken != null) {
      print('Nuevo Access Token generado: $newAccessToken');
      await TokenService.saveTokens(newAccessToken, refreshToken);
      return '/home';
    } else {
      print('No se pudo renovar el Access Token, redirigiendo al login');
      await AuthService.logout();
      return '/login';
    }
  }
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String currentRoute = '/login';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentRoute = widget.initialRoute;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkTokenAndUpdateRoute();
    }
  }

  Future<void> checkTokenAndUpdateRoute() async {
    final newRoute = await getInitialRoute();
    if (newRoute != currentRoute) {
      setState(() {
        currentRoute = newRoute;
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APP UCT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginScreen(),
      },
      initialRoute: currentRoute,
    );
  }
}
