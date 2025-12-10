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
  List<Map<String, dynamic>> _respuestas = [];

  bool get loading => _loading;
  Formulario? get formulario => _formulario;
  List<Map<String, dynamic>> get respuestas => _respuestas;

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

  void setRespuesta(Map<String, dynamic> respuesta) {
    _respuestas.removeWhere(
      (r) => r['id_reactivo'] == respuesta['id_reactivo'],
    );
    _respuestas.add(respuesta);
    notifyListeners();
  }

  Map<String, dynamic>? getReactivoRespuesta(int idReactivo) {
    try {
      return _respuestas.firstWhere((r) => r['id_reactivo'] == idReactivo);
    } catch (_) {
      return null;
    }
  }

  void marcarError(int idReactivo, bool error) {
    final index = _formulario!.reactivos.indexWhere(
      (r) => r.idReactivo == idReactivo,
    );

    if (index != -1) {
      _formulario!.reactivos[index].error = error;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getFormularioEvaluacion(
    int idEvaluacion,
    int tipo,
    int idUnidad,
    int user,
  ) async {
    try {
      final response = await EvaluacionService.getFormularioEvaluacion(
        idEvaluacion,
        tipo,
        idUnidad,
        user,
        _authProvider.accessToken!,
      );

      final formularioJson = response['formulario'] as Map<String, dynamic>;

      _formulario = Formulario.fromJson(formularioJson);

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
              _formulario = Formulario.fromJson(formularioJson);
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
    }
  }

  Future<Map<String, dynamic>> guardarEvaluacion(
    Map<String, dynamic> jsonFinal,
  ) async {
    _loading = true;

    notifyListeners();

    try {
      final response = await EvaluacionService.enviarEvaluacion(
        jsonFinal,
        _authProvider.accessToken!,
      );

      final reactivosIncorrectos = List<int>.from(
        response['reactivos_incorrectos'],
      );
      final temasIncorrectos = List<String>.from(response['temas_incorrectos']);

      for (var i = 0; i < _formulario!.reactivos.length; i++) {
        final reactivo = _formulario!.reactivos[i];
        final incorrecto = reactivosIncorrectos.indexOf(reactivo.idReactivo);

        if (incorrecto != -1) {
          reactivo.incorrecto = true;
          reactivo.temaIncorrecto = temasIncorrectos[incorrecto];
        } else {
          reactivo.incorrecto = false;
        }
      }

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
              final response = await EvaluacionService.enviarEvaluacion(
                jsonFinal,
                _authProvider.accessToken!,
              );

              final reactivosIncorrectos = List<int>.from(
                response['reactivos_incorrectos'],
              );
              final temasIncorrectos = List<String>.from(
                response['temas_incorrectos'],
              );

              for (var i = 0; i < _formulario!.reactivos.length; i++) {
                final reactivo = _formulario!.reactivos[i];
                final incorrecto = reactivosIncorrectos.indexOf(
                  reactivo.idReactivo,
                );

                if (incorrecto != -1) {
                  reactivo.incorrecto = true;
                  reactivo.error;
                  reactivo.temaIncorrecto = temasIncorrectos[incorrecto];
                } else {
                  reactivo.incorrecto = false;
                }
              }

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
      throw Exception('Error al guardar la evaluación: ${e.toString()}');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getFormularioEncuesta(
    int idEncuesta,
    int tipo,
  ) async {
    try {
      final response = await EvaluacionService.getFormularioEncuesta(
        idEncuesta,
        tipo,
        _authProvider.accessToken!,
      );

      final formularioJson = response['formulario'] as Map<String, dynamic>;

      _formulario = Formulario.fromJson(formularioJson);

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
              final response = await EvaluacionService.getFormularioEncuesta(
                idEncuesta,
                tipo,
                _authProvider.accessToken!,
              );

              final formularioJson =
                  response['formulario'] as Map<String, dynamic>;

              _formulario = Formulario.fromJson(formularioJson);

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
        'Error al cargar el formulario de la encuesta: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> guardarEncuesta(
    Map<String, dynamic> jsonFinal,
  ) async {
    _loading = true;

    notifyListeners();

    try {
      final response = await EvaluacionService.enviarEncuesta(
        jsonFinal,
        _authProvider.accessToken!,
      );

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
              final response = await EvaluacionService.enviarEncuesta(
                jsonFinal,
                _authProvider.accessToken!,
              );

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
      throw Exception('Error al guardar la encuesta: ${e.toString()}');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearRespuestas() {
    _respuestas = [];
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
