import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/routes/app_routes.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> checkTokenAndUpdateRoute(BuildContext context) async {
    final navigator = navigatorKey.currentState;

    if (navigator == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final newRoute = await getInitialRoute(authProvider);
    navigator.pushReplacementNamed(newRoute);
  }

  static Future<String> getInitialRoute(AuthProvider authProvider) async {
    if (authProvider.accessToken == null || authProvider.refreshToken == null) {
      await authProvider.loadTokens();
      return AppRoutes.login;
    }

    final isAccessTokenValid = await AuthService.checkTokenValidity(
      authProvider.accessToken!,
    );
    if (isAccessTokenValid) {
      return AppRoutes.welcome;
    }

    try {
      final newAccessToken = await AuthService.refreshAccessToken(
        authProvider.refreshToken!,
        authProvider,
      );
      if (newAccessToken != null) {
        await authProvider.updateAccessToken(newAccessToken);
        return AppRoutes.welcome;
      }
    } catch (e) {
      debugPrint('Error al renovar token: $e');
    }
    await AuthService.logout(authProvider);
    return AppRoutes.login;
  }
}
