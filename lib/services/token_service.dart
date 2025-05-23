import 'dart:convert';

import 'package:app_uct/models/usuario_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static String? _accessToken;
  static String? _refreshToken;

  // METODO PARA GUARDAR LOS TOKENS EN EL ALMACENAMIENTO SEGURO
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  // METODO PARA GUARDAR LAS CREDENCIALES DE MANERA SEGURA
  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  // METODO PRA GUARDAR LOS DATOS DEL USUARIO
  static Future<void> saveUserData(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', json.encode(usuario.toJson()));
  }

  // METODO PARA OBTENER EL ACCESS TOKEN
  static Future<String?> getAccessToken() async {
    _accessToken ??= await _storage.read(key: 'access_token');
    return _accessToken;
  }

  // METODO PARA OBTENER EL REFRESH TOKEN
  static Future<String?> getRefreshToken() async {
    _refreshToken ??= await _storage.read(key: 'refresh_token');
    return _refreshToken;
  }

  static Future<Usuario?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('userData');
    if (jsonString == null) return null;
    final jsonData = json.decode(jsonString);
    return Usuario.fromJson(jsonData);
  }

  static Future<bool> hasCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return username != null && password != null;
  }
}
