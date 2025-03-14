// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:app_uct/services/auth_service.dart';

import 'package:app_uct/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final initialRoute = await getInitialRouteForTest();

    await tester.pumpWidget(MyApp(initialRoute: initialRoute));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

// Función auxiliar para simular el cálculo de la ruta inicial
Future<String> getInitialRouteForTest() async {
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
      return '/login';
    }
  }
}
