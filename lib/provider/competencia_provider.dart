import 'package:app_uct/models/competencia_model.dart';
import 'package:app_uct/models/unidad_model.dart';
import 'package:app_uct/services/course_service.dart';
import 'package:flutter/material.dart';

class CompetenciaProvider with ChangeNotifier {
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

  Future<Map<String, dynamic>> fetchTemario(
    int idCurso,
    String accessToken,
  ) async {
    _loading = true;

    notifyListeners();

    try {
      final response = await CourseService.getTemario(idCurso, accessToken);
      final unidadesJson = response['unidades'] as List;
      _unidades = unidadesJson.map((json) => Unidad.fromJson(json)).toList();
      return response;
    } catch (e) {
      throw Exception(
        'Error al cargar el temario de la competencia: ${e.toString()}',
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchCompetenciaActual(String token) async {
    _loading = true;

    notifyListeners();

    try {
      final response = await CourseService.getCompetenciaActual(token);
      if (response['ultima_competencia'] != null) {
        _competencia = Competencia.fromJson(response['ultima_competencia']);
      } else {
        _competencia = null;
      }
      return response;
    } catch (e) {
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
