import 'dart:developer';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/routes/app_navigator.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.loadTokens();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProxyProvider<AuthProvider, CompetenciaProvider>(
          create: (_) => CompetenciaProvider(authProvider),
          update:
              (_, auth, competenciaProvider) =>
                  competenciaProvider!..updateAuth(auth),
        ),
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
  late SharedPreferences _preferences;
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPreferences();
  }

  Future<void> initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('Cambio de estado: $state');
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
      _preferences.setString(
        'lastPausedTime',
        DateTime.now().toIso8601String(),
      );
      if (currentRoute != AppRoutes.loading &&
          currentRoute != AppRoutes.login) {
        _preferences.setString('lastScreen', currentRoute ?? '/welcome');
      }
    } else if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      if (!authProvider.isLoggedIn) {
        AppNavigator.navigatorKey.currentState?.pushReplacementNamed(
          AppRoutes.login,
        );
        return;
      }
      final lastPausedString = _preferences.getString('lastPausedTime');
      if (lastPausedString != null) {
        final lastPaused = DateTime.parse(lastPausedString);
        final difference = DateTime.now().difference(lastPaused);
        if (difference.inMinutes >= 1) {
          if (mounted) {
            AppNavigator.navigatorKey.currentState?.pushReplacementNamed(
              AppRoutes.welcome,
            );
          }
        }
      } else {
        AppNavigator.navigatorKey.currentState?.pushReplacementNamed(
          AppRoutes.login,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App UCT',
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
