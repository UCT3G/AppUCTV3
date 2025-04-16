import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_navigator.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CompetenciaProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState? previousAppState;
  bool wasPaused = false;

  Future<void> initializeApp() async {
    AppNavigator.navigatorKey.currentState?.pushReplacementNamed(
      AppRoutes.loading,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) AppNavigator.checkTokenAndUpdateRoute(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('Estado actual: $state');
    debugPrint('Estado anterior: $previousAppState');
    debugPrint('wasPaused: $wasPaused');
    if (state == AppLifecycleState.paused) {
      wasPaused = true;
      AppNavigator.navigatorKey.currentState?.pushReplacementNamed(
        AppRoutes.loading,
      );
    } else if (state == AppLifecycleState.resumed) {
      if (wasPaused) {
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) AppNavigator.checkTokenAndUpdateRoute(context);
        });
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
      initialRoute: AppRoutes.loading,
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
    );
  }
}
