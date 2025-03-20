import 'package:app_uct/routes/app_navigator.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await AppNavigator.getInitialRoute();
  // print('Ruta inicial: $initialRoute');
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String currentRoute = '/login';
  AppLifecycleState? previousAppState;
  bool wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNavigator.navigatorKey.currentState?.pushReplacementNamed(
        widget.initialRoute,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // print('Estado actual: $state');
    // print('Estado anterior: $previousAppState');
    if (state == AppLifecycleState.paused) {
      wasPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      if (wasPaused) {
        AppNavigator.checkTokenAndUpdateRoute();
        wasPaused = false;
      }
    }
    previousAppState = state;
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
      navigatorKey: AppNavigator.navigatorKey,
      onGenerateRoute: (settings) {
        final routeBuilder = AppRoutes.routes[settings.name];
        if (routeBuilder != null) {
          return MaterialPageRoute(builder: routeBuilder, settings: settings);
        }

        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: Text('Ruta no encontrada: ${settings.name}'),
                ),
              ),
        );
      },
      home: Container(),
    );
  }
}
