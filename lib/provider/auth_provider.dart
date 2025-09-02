// import 'dart:developer';

import 'package:app_uct/models/usuario_model.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/biometric_service.dart';
import 'package:app_uct/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();
  String? _accessToken;
  String? _refreshToken;
  String? _username;
  String? _password;
  Usuario? _currentUsuario;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get username => _username;
  String? get password => _password;
  Usuario? get currentUsuario => _currentUsuario;

  // METODO QUE CARGA LOS TOKENS AL INICIAR LA APP
  Future<void> loadTokens() async {
    try {
      _accessToken = await TokenService.getAccessToken();
      _refreshToken = await TokenService.getRefreshToken();
      _currentUsuario = await TokenService.getUserData();
      _username = await TokenService.getUsername();
      _password = await TokenService.getPassword();
    } catch (e) {
      debugPrint("Error al cargar tokens: $e");
      await TokenService.clearAll();
      _accessToken = null;
      _refreshToken = null;
      _currentUsuario = null;
      _username = null;
      _password = null;
    }

    notifyListeners();
  }

  // METODO QUE GUARDA LOS TOKENS
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await TokenService.saveTokens(accessToken, refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  // METODO PARA ACTUALIZAR SOLO EL ACCESS TOKEN
  Future<void> updateAccessToken(String newAccessToken) async {
    _accessToken = newAccessToken;
    await TokenService.saveTokens(newAccessToken, _refreshToken ?? "");
    notifyListeners();
  }

  // METODO PARA ACTUALIZAR SOLO EL REFRESH TOKEN
  Future<void> updateRefreshToken(String newRefreshToken) async {
    _refreshToken = newRefreshToken;
    await TokenService.saveTokens(_accessToken ?? "", newRefreshToken);
    notifyListeners();
  }

  //METODO PARA GUARDAR LA INFORMACION DEL USUARIO
  Future<void> saveUser(
    Usuario usuario,
    String username,
    String password,
  ) async {
    _currentUsuario = usuario;
    _username = username;
    _password = password;
    await TokenService.saveUserData(usuario);
    await TokenService.saveCredentials(username, password);
    notifyListeners();
  }

  //METODO PARA GUARDAR LA INFORMACION DEL USUARIO CON CREDENCIALES
  Future<void> saveUserWithCredentials(Usuario usuario) async {
    _currentUsuario = usuario;
    await TokenService.saveUserData(usuario);
    notifyListeners();
  }

  //METODO PARA INICIAR SESION
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await AuthService.login(username, password);
    if (!response['success']) {
      return {
        'success': false,
        'message': response['message'],
        'tipo': response['tipo'],
      };
    }
    final data = response['data'];
    await saveTokens(data['access_token'], data['refresh_token']);
    await saveUser(Usuario.fromJson(data['data_user']), username, password);
    return {
      'success': true,
      'access_token': data['access_token'],
      'message': data['message'],
    };
  }

  //METODO PARA INICIAR SESION CON BIOMETRICOS
  Future<Map<String, dynamic>> loginWithBiometrics() async {
    final response = await AuthService().loginWithBiometrics();

    if (!response['success']) {
      if (response['tipo'] == 1) {
        _password = null;
      } else if (response['tipo'] == 2) {
        _username = null;
        _password = null;
      }
      return {
        'success': false,
        'message': response['message'],
        'tipo': response['tipo'],
      };
    }
    final data = response['data'];
    await saveTokens(data['access_token'], data['refresh_token']);
    await saveUserWithCredentials(Usuario.fromJson(data['data_user']));
    return {
      'success': true,
      'access_token': data['access_token'],
      'message': data['message'],
    };
  }

  //METODO PARA INICIAR SESION CON CREDENCIALES
  Future<Map<String, dynamic>> loginWithLockScreen() async {
    final response = await AuthService().loginWithLockScreen();
    await saveTokens(response['access_token'], response['refresh_token']);
    await saveUserWithCredentials(Usuario.fromJson(response['data_user']));
    return response;
  }

  //METODO PARA INICIAR SESION CON CREDENCIALES
  Future<Map<String, dynamic>> loginWithCredentials() async {
    final response = await AuthService().loginWithCredentials();
    await saveTokens(response['access_token'], response['refresh_token']);
    await saveUserWithCredentials(Usuario.fromJson(response['data_user']));
    return response;
  }

  //METODO PARA CERRAR SESION
  Future<void> logout() async {
    await AuthService.logout();
    _accessToken = null;
    _refreshToken = null;
    _currentUsuario = null;
    notifyListeners();
  }

  //METODO PARA RENOVAR EL ACCESS TOKEN
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    final newAccessToken = await AuthService.refreshAccessToken(_refreshToken!);
    if (newAccessToken != null) {
      await updateAccessToken(newAccessToken);
      return true;
    }
    return false;
  }

  Future<bool> isLockScreen() async {
    return await _biometricService.isLockScreen();
  }

  Future<bool> isBiometricAvailable() async {
    return await _biometricService.isBiometricAvailable();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _authService.biometricService.getAvailableBiometrics();
  }

  //METODO PARA SABER SI UN USUARIO ESTA LOGUEADO
  bool get isLoggedIn {
    return _accessToken != null &&
        _accessToken!.isNotEmpty &&
        _currentUsuario != null;
  }
}
