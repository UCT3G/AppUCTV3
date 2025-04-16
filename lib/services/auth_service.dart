import 'package:app_uct/provider/auth_provider.dart';
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
    AuthProvider authProvider,
  ) async {
    try {
      final encodeUsername = encodeBase64(username);
      final encodePassword = encodeBase64(password);

      final url = Uri.parse('${ApiService.baseURL}/USUARIO/LoginApp');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': encodeUsername,
          'password': encodePassword,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await authProvider.saveTokens(
          responseData['access_token'],
          responseData['refresh_token'],
        );
        await TokenService.saveCredentials(username, password);
        await TokenService.saveUserData(responseData['data_user']);
        return responseData;
      } else {
        throw Exception('Error en el login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en el login: $e');
    }
  }

  // METODO PARA INICIAR SESION CON BIOMETRICOS
  Future<bool> loginWithBiometrics(AuthProvider authProvider) async {
    try {
      if (!await TokenService.hasCredentials()) {
        throw Exception('No se encontraron credenciales guardadas');
      }

      bool isAuthenticated = await biometricService.authenticate();

      if (isAuthenticated) {
        final username = await _storage.read(key: 'username');
        final password = await _storage.read(key: 'password');

        if (username != null && password != null) {
          await login(username, password, authProvider);
          return true;
        } else {
          throw Exception('No se encontraron credenciales guardadas');
        }
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error en la autenticación biométrica: $e');
    }
  }

  // METODO PARA HABILITAR LA AUTENTICACION BIOMETRICA
  static Future<void> enableBiometricAuth() async {
    await _storage.write(key: 'biometric_auth_enabled', value: 'true');
  }

  // METODO PARA DESHABILITAR LA AUTENTICACION BIOMETRICA
  static Future<void> disableBiometricAuth() async {
    await _storage.write(key: 'biometric_auth_enabled', value: 'false');
  }

  // METODO PARA VERIFICAR SI LA AUTENTICACION BIOMETRICA ESTA HABILITADA
  static Future<bool> isBiometricAuthEnabled() async {
    final value = await _storage.read(key: 'biometric_auth_enabled');
    return value == 'true';
  }

  // METODO PARA CERRAR SESION
  static Future<void> logout(AuthProvider authProvider) async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');

    final isEnabled = await isBiometricAuthEnabled();

    if (!isEnabled) {
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'password');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');

    await authProvider.saveTokens("", "");
  }

  // METODO PARA RENOVAR EL ACCESS TOKEN
  static Future<String?> refreshAccessToken(
    String refreshToken,
    AuthProvider authProvider,
  ) async {
    try {
      final body = json.encode({'token': refreshToken});

      final response = await http.post(
        Uri.parse('${ApiService.baseURL}/USUARIO/RefreshToken'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // print('Respuesta del backend: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await authProvider.updateAccessToken(data['access_token']);
        await TokenService.saveUserData(data['data_user']);
        return data['access_token'];
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
