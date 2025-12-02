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
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseURL}/USUARIO/LoginApp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': encodeBase64(username),
          'password': encodeBase64(password),
          'administrador': prefs.getBool('administrador') ?? false,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': json.decode(response.body)['message'],
          'tipo': json.decode(response.body)['tipo'],
        };
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
        throw Exception('No se encontraron credenciales guardadas.');
      }

      bool isAuthenticated =
          await biometricService.authenticateWithBiometrics();

      if (isAuthenticated) {
        final username = await _storage.read(key: 'username');
        final password = await _storage.read(key: 'password');

        if (username != null && password != null) {
          return await login(username, password);
        } else {
          throw Exception('No se encontraron credenciales guardadas.');
        }
      } else {
        throw Exception('Autenticación biométrica fallida.');
      }
    } catch (e) {
      throw Exception('Error en la autenticación biométrica: $e');
    }
  }

  // METODO PARA INICIAR SESION CON CREDENCIALES
  Future<Map<String, dynamic>> loginWithLockScreen() async {
    try {
      if (!await TokenService.hasCredentials()) {
        throw Exception('No se encontraron credenciales guardadas.');
      }

      bool isAuthenticated =
          await biometricService.authenticateWithDeviceLock();

      if (isAuthenticated) {
        final username = await _storage.read(key: 'username');
        final password = await _storage.read(key: 'password');

        if (username != null && password != null) {
          return await login(username, password);
        } else {
          throw Exception('No se encontraron credenciales guardadas.');
        }
      } else {
        throw Exception('Autenticación fallida.');
      }
    } catch (e) {
      throw Exception('Error en la autenticación with lock screen: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithCredentials() async {
    try {
      if (!await TokenService.hasCredentials()) {
        throw Exception('No se encontraron credenciales guardadas.');
      }

      final username = await _storage.read(key: 'username');
      final password = await _storage.read(key: 'password');

      if (username != null && password != null) {
        return await login(username, password);
      } else {
        throw Exception('No se encontraron credenciales guardadas.');
      }
    } catch (e) {
      throw Exception('Error en la autenticación: $e');
    }
  }

  // METODO PARA CERRAR SESION
  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');

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
        final data = json.decode(response.body);
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

  static Future<Map<String, dynamic>> loginAdministrador(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseURL}/USUARIO/LoginAppAdministrador'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': encodeBase64(username),
          'password': encodeBase64(password),
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'message': json.decode(response.body)['message'],
          'tipo': json.decode(response.body)['tipo'],
        };
      } else {
        throw Exception(
          'Error en el login administrador: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error en el login administrador: $e');
    }
  }
}
