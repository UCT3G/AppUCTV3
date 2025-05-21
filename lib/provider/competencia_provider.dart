import 'package:app_uct/models/competencia_model.dart';
import 'package:app_uct/models/unidad_model.dart';
import 'package:app_uct/provider/auth_provider.dart';
import 'package:app_uct/services/auth_service.dart';
import 'package:app_uct/services/course_service.dart';
import 'package:flutter/material.dart';

class CompetenciaProvider with ChangeNotifier {
  late AuthProvider _authProvider;

  CompetenciaProvider(this._authProvider);

  void updateAuth(AuthProvider newAuth) {
    _authProvider = newAuth;
  }

  List<Unidad> _unidades = [];
  Competencia? _competencia;
  bool _loading = false;
  String _error = '';

  Competencia? get competencia => _competencia;
  List<Unidad> get unidades => _unidades;
  bool get loading => _loading;
  String get error => _error;

  // static const List<List<Color>> _predefinedGradients = [
  //   [Color(0xFF574293), Color(0xFF86CBC8)],
  //   [Color(0xFF05696E), Color(0xFF6DB75E)],
  //   [Color(0xFFF6A431), Color(0xFFCC151A)],
  //   [Color(0xFF7B2884), Color(0xFF7C8AC4)],
  // ];

  Future<Map<String, dynamic>> fetchTemario(int idCurso) async {
    _loading = true;

    notifyListeners();

    try {
      final response = await CourseService.getTemario(
        idCurso,
        _authProvider.accessToken!,
      );
      final unidadesJson = response['unidades'] as List;
      _unidades = unidadesJson.map((json) => Unidad.fromJson(json)).toList();
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
              final response = await CourseService.getTemario(
                idCurso,
                _authProvider.accessToken!,
              );
              final unidadesJson = response['unidades'] as List;
              _unidades =
                  unidadesJson.map((json) => Unidad.fromJson(json)).toList();
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
        'Error al cargar el temario de la competencia: ${e.toString()}',
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchCompetenciaActual() async {
    _loading = true;

    notifyListeners();

    try {
      final response = await CourseService.getCompetenciaActual(
        _authProvider.accessToken!,
      );
      if (response['ultima_competencia'] != null) {
        _competencia = Competencia.fromJson(response['ultima_competencia']);
      } else {
        _competencia = null;
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
              final response = await CourseService.getCompetenciaActual(
                _authProvider.accessToken!,
              );
              if (response['ultima_competencia'] != null) {
                _competencia = Competencia.fromJson(
                  response['ultima_competencia'],
                );
              } else {
                _competencia = null;
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
      throw Exception('Error al cargar la competencia actual: ${e.toString()}');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _competencia = null;
    notifyListeners();
  }
}
