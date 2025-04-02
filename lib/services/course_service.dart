import 'package:app_uct/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourseService {
  static Future<Map<String, dynamic>> getCompetenciaActual(
    String accessToken,
  ) async {
    final url = Uri.parse(
      '${ApiService.baseURL}/CURSOS_MOVIL/getCompetenciaActual',
    );
    print(url);
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
}
