import 'package:app_uct/services/biometric_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:app_uct/utils/utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();
  final BiometricService biometricService = BiometricService();

  // METODO PARA INICIAR SESION
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseURL}/USUARIO/LoginApp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': encodeBase64(username),
          'password': encodeBase64(password),
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error en el login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en el login: $e');
    }
  }

  // METODO PARA INICIAR SESION CON BIOMETRICOS
  Future<Map<String, dynamic>> loginWithBiometrics() async {
    try {
      if (!await TokenService.hasCredentials()) {
        throw Exception('No se encontraron credenciales guardadas');
      }

      bool isAuthenticated = await biometricService.authenticate();

      if (isAuthenticated) {
        final username = await _storage.read(key: 'username');
        final password = await _storage.read(key: 'password');

        if (username != null && password != null) {
          return await login(username, password);
        } else {
          throw Exception('No se encontraron credenciales guardadas');
        }
      } else {
        throw Exception('Autenticación biométrica fallida');
      }
    } catch (e) {
      throw Exception('Error en la autenticación biométrica: $e');
    }
  }

  // METODO PARA CERRAR SESION
  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');

    final isEnabled = await BiometricService.isBiometricAuthEnabled();

    if (!isEnabled) {
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'password');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  // METODO PARA RENOVAR EL ACCESS TOKEN
  static Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseURL}/USUARIO/RefreshToken'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': refreshToken}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Error al renovar el token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error en la solicitud de renovación: $e');
      return null;
    }
  }

  // METODO PARA VERIFICAR SI EL ACCESS TOKEN ES VALIDO
  static Future<bool> checkTokenValidity(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseURL}/USUARIO/VerificarToken'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
