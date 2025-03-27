import 'package:app_uct/services/token_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // METODO QUE CARGA LOS TOKENS AL INICIAR LA APP
  Future<void> loadTokens() async {
    _accessToken = await TokenService.getAccessToken();
    _refreshToken = await TokenService.getRefreshToken();
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
}
