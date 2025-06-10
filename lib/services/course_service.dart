import 'dart:io';

import 'package:app_uct/models/tema_model.dart';
import 'package:app_uct/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourseService {
  static Future<Map<String, dynamic>> getCompetenciaActual(
    String accessToken,
  ) async {
    final url = Uri.parse(
      '${ApiService.baseURL}/CURSOS_MOVIL/getCompetenciaActual',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> getTemario(
    int idCurso,
    String accessToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseURL}/CURSOS_MOVIL/getTemarioCompetencia'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'id_curso': idCurso}),
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> subirPractica(
    int idTema,
    int idCurso,
    File archivo,
    String accessToken,
  ) async {
    final dio = Dio();

    try {
      final formData = FormData.fromMap({
        'id_tema': idTema,
        'id_curso': idCurso,
        'file': await MultipartFile.fromFile(
          archivo.path,
          filename: 'practica_tema$idTema.pdf',
        ),
      });

      final response = await dio.post(
        '${ApiService.baseURL}/CURSOS_MOVIL/subirPractica',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> actualizarTemaUsuario(
    int idCurso,
    int idTema,
    String accessToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseURL}/CURSOS_MOVIL/actualizar_tema_usuario'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'id_curso': idCurso, 'id_tema': idTema}),
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado o inválido');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Uri getVideoUrl(Tema tema) {
    return Uri.parse(
      '${ApiService.baseURL}/video_movil/${tema.idCurso}/${tema.idUnidad}/${tema.idTema}',
    );
  }
}
