import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:flutter/cupertino.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> checkTokenAndUpdateRoute() async {
    final newRoute = await getInitialRoute();
    if (newRoute == AppRoutes.login) {
      print('Forzando el login');
      navigatorKey.currentState?.pushReplacementNamed(AppRoutes.login);
    } else if (newRoute == AppRoutes.home) {
      print('Redirigiendo al home.');
      navigatorKey.currentState?.pushReplacementNamed(AppRoutes.home);
    }
  }

  static Future<String> getInitialRoute() async {
    final accessToken = await TokenService.getAccessToken();
    final refreshToken = await TokenService.getRefreshToken();

    print('Access Token: $accessToken');
    print('Refresh Token: $refreshToken');

    if (accessToken == null || refreshToken == null) {
      print('No hay tokens, redirigiendo al login');
      return AppRoutes.login;
    }

    final isAccessTokenValid = await AuthService.checkTokenValidity(
      accessToken,
    );
    print('Access Token válido: $isAccessTokenValid');

    if (isAccessTokenValid) {
      print('Access Token válido, redirigiendo al home');
      return AppRoutes.home;
    } else {
      final newAccessToken = await AuthService.refreshAccessToken(refreshToken);

      if (newAccessToken != null) {
        print('Nuevo Access Token generado: $newAccessToken');
        await TokenService.saveTokens(newAccessToken, refreshToken);
        return AppRoutes.home;
      } else {
        print('No se pudo renovar el Access Token, redirigiendo al login');
        await AuthService.logout();
        return AppRoutes.login;
      }
    }
  }
}
