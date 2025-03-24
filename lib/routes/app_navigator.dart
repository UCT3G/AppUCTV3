import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:flutter/cupertino.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> checkTokenAndUpdateRoute() async {
    final navigator = navigatorKey.currentState;

    if (navigator == null) return;

    final newRoute = await getInitialRoute();
    navigator.pushReplacementNamed(newRoute);
  }

  static Future<String> getInitialRoute() async {
    final accessToken = await TokenService.getAccessToken();
    final refreshToken = await TokenService.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      return AppRoutes.login;
    }

    final isAccessTokenValid = await AuthService.checkTokenValidity(
      accessToken,
    );
    if (isAccessTokenValid) {
      return AppRoutes.home;
    }

    try {
      final newAccessToken = await AuthService.refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        await TokenService.saveTokens(newAccessToken, refreshToken);
        return AppRoutes.home;
      }
    } catch (e) {
      print('Error al renovar token: $e');
    }
    await AuthService.logout();
    return AppRoutes.login;
  }
}
