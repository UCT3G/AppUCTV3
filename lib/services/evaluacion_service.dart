import 'dart:convert';

import 'package:app_uct/services/api_service.dart';
import 'package:http/http.dart' as http;

class EvaluacionService {
  static Future<Map<String, dynamic>> getFormularioEvaluacion(
    int idFormulario,
    int tipo,
    int idUnidad,
    int user,
    String accessToken,
  ) async {
    final url = Uri.parse(
      '${ApiService.baseURL}/CURSOS_MOVIL/cargarEvaluacion',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'id_formulario': idFormulario,
          'tipo': tipo,
          'id_unidad': idUnidad,
          'user': user,
        }),
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
}
