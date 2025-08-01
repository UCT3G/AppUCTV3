// import 'dart:developer';
import 'dart:developer';
import 'dart:io';

import 'package:app_uct/models/competencia_model.dart';
import 'package:app_uct/models/tema_model.dart';
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
  bool _loadingDialog = false;
  List<Competencia> _competencias = [];
  List<Competencia> _competenciasFiltradas = [];
  List<Competencia> _competenciasRecientes = [];
  int _idEvaluacion = 0;

  Competencia? get competencia => _competencia;
  List<Unidad> get unidades => _unidades;
  bool get loading => _loading;
  bool get loadingDialog => _loadingDialog;
  List<Competencia> get competencias => _competencias;
  List<Competencia> get competenciasFiltradas => _competenciasFiltradas;
  List<Competencia> get competenciasRecientes => _competenciasRecientes;
  int get idEvaluacion => _idEvaluacion;

  void setCompetencia(Competencia competencia) {
    _competencia = competencia;
  }

  Tema? getTemaById(int idTema) {
    for (final unidad in _unidades) {
      try {
        final tema = unidad.temas.firstWhere((t) => t.idTema == idTema);
        return tema;
      } catch (e) {
        debugPrint('No se encontro el tema en la unidad: $e');
      }
    }
    return null;
  }

  Competencia? getCompetenciaById(int idCurso) {
    for (final c in _competencias) {
      if (c.idCurso == idCurso) return c;
    }
    return null;
  }

  void registrarIntento(int idTema) {
    for (var unidad in _unidades) {
      final index = unidad.temas.indexWhere((t) => t.idTema == idTema);
      if (index != -1) {
        final tema = unidad.temas[index];
        final tiposNoCalificables = [
          'PRACTICA',
          'EVALUACION',
          'ENCUESTA',
          'PRESENCIAL',
        ];

        final actualizarTema = tema.copyWith(
          intentosConsumidos: tema.intentosConsumidos + 1,
          resultado:
              !tiposNoCalificables.contains(tema.recursoBasicoTipo)
                  ? 100
                  : tema.resultado,
        );
        unidad.temas[index] = actualizarTema;
        break;
      }
    }
    //AQUI LLAMAR ACTUALIZAR AVANCE Y CALIFICACION WUUU
    notifyListeners();
  }

  void actualizarEvaluacion(int idTema, int resultado) {
    for (var unidad in _unidades) {
      final index = unidad.temas.indexWhere((t) => t.idTema == idTema);
      if (index != -1) {
        final tema = unidad.temas[index];

        final actualizarTema = tema.copyWith(
          resultado: resultado.toDouble().truncateToDouble(),
        );
        unidad.temas[index] = actualizarTema;
        break;
      }
    }
    //AQUI LLAMAR ACTUALIZAR AVANCE Y CALIFICACION WUUU
    notifyListeners();
  }

  Tema? obtenerSiguienteTema() {
    for (var unidad in _unidades) {
      for (var tema in unidad.temas) {
        if (tema.recursoBasicoTipo == 'EVALUACION') {
          if (tema.resultado < 80) {
            return tema;
          }
        } else {
          if (tema.intentosConsumidos == 0) {
            return tema;
          }
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchTemario(int idCurso) async {
    _loading = true;

    notifyListeners();

    try {
      final response = await CourseService.getTemario(
        idCurso,
        _authProvider.accessToken!,
      );
      final unidadesJson = response['unidades'] as List;
      log('${response['unidades']}');
      _unidades = unidadesJson.map((json) => Unidad.fromJson(json)).toList();
      log('$_unidades');
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

  Future<Map<String, dynamic>> subirPractica(int idTema, File archivo) async {
    _loadingDialog = true;
    notifyListeners();

    try {
      final response = await CourseService.subirPractica(
        idTema,
        archivo,
        _authProvider.accessToken!,
      );

      registrarIntento(idTema);

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
              final response = await CourseService.subirPractica(
                idTema,
                archivo,
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
      throw Exception('Error al subir la practica: ${e.toString()}');
    } finally {
      _loadingDialog = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> actualizarTemaUsuario(
    int idCurso,
    int idTema,
  ) async {
    _loadingDialog = true;

    notifyListeners();

    try {
      final response = await CourseService.actualizarTemaUsuario(
        idCurso,
        idTema,
        _authProvider.accessToken!,
      );

      registrarIntento(idTema);

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
              final response = await CourseService.actualizarTemaUsuario(
                idCurso,
                idTema,
                _authProvider.accessToken!,
              );

              registrarIntento(idTema);
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
      _loadingDialog = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchCompetencias() async {
    try {
      final response = await CourseService.getCursosUsuario(
        _authProvider.accessToken!,
      );
      final competenciasJson = response['cursos_usuario'] as List;
      _competencias =
          competenciasJson.map((json) => Competencia.fromJson(json)).toList();
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
              final response = await CourseService.getCursosUsuario(
                _authProvider.accessToken!,
              );
              final competenciasJson = response['cursos_usuario'] as List;
              _competencias =
                  competenciasJson
                      .map((json) => Competencia.fromJson(json))
                      .toList();
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
        'Error al cargar las competencias del usuario: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> buscarCompetencias(String texto) async {
    _loading = true;

    notifyListeners();
    try {
      final response = await CourseService.buscadorCompetencia(
        texto,
        _authProvider.accessToken!,
      );

      final List competenciasFiltradas = response['respuesta']['resultados'];
      final List<int> idsCursos =
          competenciasFiltradas
              .take(10)
              .map((competencia) => competencia['id_curso'] as int)
              .toList();

      _competenciasFiltradas =
          _competencias
              .where((competencia) => idsCursos.contains(competencia.idCurso))
              .toList();

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
              final response = await CourseService.buscadorCompetencia(
                texto,
                _authProvider.accessToken!,
              );

              final List competenciasFiltradas =
                  response['respuesta']['resultados'];
              final List<int> idsCursos =
                  competenciasFiltradas
                      .take(10)
                      .map((competencia) => competencia['id_curso'] as int)
                      .toList();

              _competenciasFiltradas =
                  _competencias
                      .where(
                        (competencia) =>
                            idsCursos.contains(competencia.idCurso),
                      )
                      .toList();

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
      throw Exception('Error al realizar la busqueda: ${e.toString()}');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchCompetenciasRecientes() async {
    try {
      final response = await CourseService.getCursosUsuarioRecientes(
        _authProvider.accessToken!,
      );
      final competenciasJson = response['cursos_usuario'] as List;
      _competenciasRecientes =
          competenciasJson.map((json) => Competencia.fromJson(json)).toList();
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
              final response = await CourseService.getCursosUsuarioRecientes(
                _authProvider.accessToken!,
              );
              final competenciasJson = response['cursos_usuario'] as List;
              _competenciasRecientes =
                  competenciasJson
                      .map((json) => Competencia.fromJson(json))
                      .toList();
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
        'Error al cargar las competencias recientes del usuario: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> validarUnidadAnterior(
    int idCurso,
    int orden,
  ) async {
    _loadingDialog = true;

    notifyListeners();

    try {
      final response = await CourseService.validarUnidadAnterior(
        idCurso,
        orden,
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
              final response = await CourseService.validarUnidadAnterior(
                idCurso,
                orden,
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
      throw Exception('Error validar la unidad anterior: ${e.toString()}');
    } finally {
      _loadingDialog = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> validarTemasUnidad(
    int idUnidad,
    int idTema,
    int idCurso,
    String recursoBasicoTipo,
  ) async {
    _loadingDialog = true;

    notifyListeners();

    try {
      final response = await CourseService.validarTemasUnidad(
        idUnidad,
        idTema,
        idCurso,
        recursoBasicoTipo,
        _authProvider.accessToken!,
      );

      _idEvaluacion = response['id_evaluacion'];
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
              final response = await CourseService.validarTemasUnidad(
                idUnidad,
                idTema,
                idCurso,
                recursoBasicoTipo,
                _authProvider.accessToken!,
              );

              _idEvaluacion = response['id_evaluacion'];
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
        'Error al validar los temas de la unidad: ${e.toString()}',
      );
    } finally {
      _loadingDialog = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> adelantarAtrasarTemas(
    int idCurso,
    int idUnidad,
    int ordenTema,
    int ordenUnidad,
    int accion,
  ) async {
    _loadingDialog = true;

    notifyListeners();

    try {
      final response = await CourseService.adelantarAtrasar(
        idCurso,
        idUnidad,
        ordenTema,
        ordenUnidad,
        accion,
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
              final response = await CourseService.adelantarAtrasar(
                idCurso,
                idUnidad,
                ordenTema,
                ordenUnidad,
                accion,
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
      throw Exception(
        'Error al validar los temas de la unidad: ${e.toString()}',
      );
    } finally {
      _loadingDialog = false;
      notifyListeners();
    }
  }

  void clear() {
    _competencia = null;
    notifyListeners();
  }

  void clearFiltro() {
    _competenciasFiltradas = [];
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
