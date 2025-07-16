import 'dart:developer';

import 'package:app_uct/models/formulario_model.dart';
import 'package:app_uct/models/reactivo_model.dart';
import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/evaluacion_service.dart';
import 'package:flutter/foundation.dart';

class EvaluacionProvider with ChangeNotifier {
  late AuthProvider _authProvider;

  EvaluacionProvider(this._authProvider);

  void updateAuth(AuthProvider newAuth) {
    _authProvider = newAuth;
  }

  bool _loading = false;
  Formulario? _formulario;
  Map<int, dynamic> _respuestas = {};

  bool get loading => _loading;
  Formulario? get formulario => _formulario;
  Map<int, dynamic> get respuestas => _respuestas;

  Reactivo? getReactivoById(int idReactivo) {
    try {
      final reactivo = _formulario!.reactivos.firstWhere(
        (r) => r.idReactivo == idReactivo,
      );
      return reactivo;
    } catch (e) {
      debugPrint('No se encontro el reactivo en el formulario: $e');
    }
    return null;
  }

  void setRespuesta(int idReactivo, dynamic valor) {
    _respuestas[idReactivo] = valor;
    notifyListeners();
  }

  dynamic getRespuestas(int idReactivo) {
    return _respuestas[idReactivo];
  }

  Future<Map<String, dynamic>> getFormularioEvaluacion(
    int idEvaluacion,
    int tipo,
    int idUnidad,
    int user,
  ) async {
    _loading = true;

    notifyListeners();

    try {
      final response = await EvaluacionService.getFormularioEvaluacion(
        idEvaluacion,
        tipo,
        idUnidad,
        user,
        _authProvider.accessToken!,
      );

      final formularioJson = response['formulario'] as Map<String, dynamic>;
      log('${response['formulario']}');
      _formulario = Formulario.fromJson(formularioJson);
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
                idEvaluacion,
                tipo,
                idUnidad,
                user,
                _authProvider.accessToken!,
              );

              final formularioJson =
                  response['formulario'] as Map<String, dynamic>;
              log('${response['formulario']}');
              _formulario = Formulario.fromJson(formularioJson);
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

  void clearRespuestas() {
    _respuestas = {};
    notifyListeners();
  }
}
