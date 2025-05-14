import 'dart:developer';

import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final bool isInitialLoad;

  const SplashScreen({super.key, this.isInitialLoad = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences _preferences;

  @override
  void initState() {
    super.initState();
    if (widget.isInitialLoad) {
      checkLoginState();
    }
  }

  Future<void> checkLoginState() async {
    _preferences = await SharedPreferences.getInstance();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final lastPausedString = _preferences.getString('lastPausedTime');
    final lastScreenString = _preferences.getString('lastScreen');

    if (!authProvider.isLoggedIn) {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    
    if (lastPausedString != null) {
      final lastPaused = DateTime.parse(lastPausedString);
      final difference = DateTime.now().difference(lastPaused);
      if (difference.inMinutes >= 1) {
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            lastScreenString ?? AppRoutes.welcome,
          );
        }
        log('$lastScreenString');
      }
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          "assets/animations/3g-tracto.json",
          fit: BoxFit.cover,
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
