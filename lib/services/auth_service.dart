import 'package:app_uct/services/biometric_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app_uct/services/api_service.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:app_uct/utils/utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final storage = FlutterSecureStorage();
  static final localAuth = LocalAuthentication();
  final BiometricService biometricService = BiometricService();

  // METODO PARA INICIAR SESION
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final encodeUsername = encodeBase64(username);
      final encodePassword = encodeBase64(password);

      final response = await ApiService.post('USUARIO/LoginApp', {
        'username': encodeUsername,
        'password': encodePassword,
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await TokenService.saveTokens(
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
  Future<bool> loginWithBiometrics() async {
    try {
      if (!await biometricService.isBiometricAvailable()) {
        throw Exception('El dispositivo no soporta autenticación biométrica');
      }

      if (!await TokenService.hasCredentials()) {
        throw Exception('No se encontraron credenciales guardadas');
      }

      bool isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Por favor, autentícate para acceder',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (isAuthenticated) {
        final username = await storage.read(key: 'username');
        final password = await storage.read(key: 'password');

        if (username != null && password != null) {
          await login(username, password);
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
    await storage.write(key: 'biometric_auth_enabled', value: 'true');
  }

  // METODO PARA DESHABILITAR LA AUTENTICACION BIOMETRICA
  static Future<void> disableBiometricAuth() async {
    await storage.write(key: 'biometric_auth_enabled', value: 'false');
  }

  // METODO PARA VERIFICAR SI LA AUTENTICACION BIOMETRICA ESTA HABILITADA
  static Future<bool> isBiometricAuthEnabled() async {
    final value = await storage.read(key: 'biometric_auth_enabled');
    return value == 'true';
  }

  // METODO PARA CERRAR SESION
  static Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    final isEnabled = await isBiometricAuthEnabled();

    if (!isEnabled) {
      await storage.delete(key: 'username');
      await storage.delete(key: 'password');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  // METODO PARA RENOVAR EL ACCESS TOKEN
  static Future<String?> refreshAccessToken(String refreshToken) async {
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
        await TokenService.saveUserData(data['data_user']);
        return data['access_token'];
      } else {
        print('Error al renovar el token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error en la solicitud de renovación: $e');
      return null;
    }
  }

  // METODO PARA VERIFICAR SI EL ACCESS TOKEN ES VALIDO
  static Future<bool> checkTokenValidity(String accessToken) async {
    try {
      final response = await ApiService.getToken(
        'USUARIO/VerificarToken',
        accessToken,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
