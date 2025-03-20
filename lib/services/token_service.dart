import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const storage = FlutterSecureStorage();

  // METODO PARA GUARDAR LOS TOKENS EN EL ALMACENAMIENTO SEGURO
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
  }

  // METODO PARA GUARDAR LAS CREDENCIALES DE MANERA SEGURA
  static Future<void> saveCredentials(String username, String password) async {
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);
  }

  // METODO PRA GUARDAR LOS DATOS DEL USUARIO
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', json.encode(userData));
  }

  // METODO PARA OBTENER EL ACCESS TOKEN
  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  // METODO PARA OBTENER EL REFRESH TOKEN
  static Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }

  static Future<bool> hasCredentials() async {
    final username = await storage.read(key: 'username');
    final password = await storage.read(key: 'password');
    return username != null && password != null;
  }
}
