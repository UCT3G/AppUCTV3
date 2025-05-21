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
  Usuario? _currentUsuario;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Usuario? get currentUsuario => _currentUsuario;

  // METODO QUE CARGA LOS TOKENS AL INICIAR LA APP
  Future<void> loadTokens() async {
    _accessToken = await TokenService.getAccessToken();
    _refreshToken = await TokenService.getRefreshToken();
    _currentUsuario = await TokenService.getUserData();
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
  Future<void> saveUser(Usuario usuario) async {
    _currentUsuario = usuario;
    await TokenService.saveUserData(usuario);
    notifyListeners();
  }

  //METODO PARA INICIAR SESION
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await AuthService.login(username, password);
    await saveTokens(response['access_token'], response['refresh_token']);
    await TokenService.saveCredentials(username, password);
    await saveUser(Usuario.fromJson(response['data_user']));
    return response;
  }

  //METODO PARA INICIAR SESION CON BIOMETRICOS
  Future<Map<String, dynamic>> loginWithBiometrics() async {
    final response = await AuthService().loginWithBiometrics();
    await saveTokens(response['access_token'], response['refresh_token']);
    await saveUser(Usuario.fromJson(response['data_user']));
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

  //METODO PARA HABILITAR/DESHABILITAR AUTENTICACION BIOMETRICA
  Future<bool> hasBiometricPreference() async {
    final value = await BiometricService.getBiometricAuthPreference();
    return value?.toLowerCase() == 'true';
  }

  Future<void> enableBiometricAuth() async {
    await BiometricService.enableBiometricAuth();
  }

  Future<void> disableBiometricAuth() async {
    await BiometricService.disableBiometricAuth();
  }

  Future<bool> isBiometricAuthEnabled() async {
    return await BiometricService.isBiometricAuthEnabled();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _authService.biometricService.getAvailableBiometrics();
  }

  Future<bool> checkBiometricSupport() async {
    return await _biometricService.isBiometricAvailable();
  }

  //METODO PARA SABER SI UN USUARIO ESTA LOGUEADO
  bool get isLoggedIn {
    return _accessToken != null &&
        _accessToken!.isNotEmpty &&
        _currentUsuario != null;
  }
}
