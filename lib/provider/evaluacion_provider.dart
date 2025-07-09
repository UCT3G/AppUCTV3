import 'dart:developer';

import 'package:app_uct/models/formulario_model.dart';
import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/provider/competencia_provider.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/evaluacion_service.dart';
import 'package:flutter/foundation.dart';

class EvaluacionProvider with ChangeNotifier {
  late AuthProvider _authProvider;
  late CompetenciaProvider _competenciaProvider;

  EvaluacionProvider(this._authProvider);

  void updateAuth(AuthProvider newAuth) {
    _authProvider = newAuth;
  }

  bool _loading = false;
  List<Formulario> _formulario = [];

  bool get loading => _loading;
  List<Formulario> get formulario => _formulario;

  Future<Map<String, dynamic>> getFormularioEvaluacion(
    int tipo,
    int idUnidad,
    int user,
  ) async {
    _loading = true;

    notifyListeners();

    try {
      final response = await EvaluacionService.getFormularioEvaluacion(
        _competenciaProvider.idEvaluacion,
        tipo,
        idUnidad,
        user,
        _authProvider.accessToken!,
      );

      final formularioJson = response['formulario'] as List;
      log('${response['formulario']}');
      _formulario =
          formularioJson.map((json) => Formulario.fromJson(json)).toList();
      log('$_formulario');
      return response;
    } catch (e) {
      if (e.toString().contains('Token expirado o inválido')) {
        final tokenRefreshValid = await AuthService.checkTokenValidity(
          _authProvider.refreshToken ?? '',
        );
        if (tokenRefreshValid) {
          final newAccessToken = await AuthService.refreshAccessToken(
            _authProvider.refreshToken ?? '',
          );
          if (newAccessToken != null) {
            await _authProvider.updateAccessToken(newAccessToken);
            try {
              final response = await EvaluacionService.getFormularioEvaluacion(
                _competenciaProvider.idEvaluacion,
                tipo,
                idUnidad,
                user,
                _authProvider.accessToken!,
              );

              final formularioJson = response['formulario'] as List;
              log('${response['formulario']}');
              _formulario =
                  formularioJson
                      .map((json) => Formulario.fromJson(json))
                      .toList();
              log('$_formulario');
              return response;
            } catch (e) {
              throw Exception(
                'Error al reintentar con token renovado: ${e.toString()}',
              );
            }
          }
        } else {
          await _authProvider.logout();
          throw Exception('Sesión expirada.');
        }
      }
      throw Exception(
        'Error al cargar el formulario de la evaluacion: ${e.toString()}',
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
