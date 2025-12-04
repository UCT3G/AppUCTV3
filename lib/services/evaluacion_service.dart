import 'dart:convert';
import 'dart:developer';

import 'package:app_uct/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    try {
      final lastRequest = prefs.getString('last-request') ?? '';
      if (lastRequest.isNotEmpty) {
        try {
          final lastDate = DateTime.parse(lastRequest);
          final now = DateTime.now();
          final difference = now.difference(lastDate);

          if (difference >= Duration(hours: 2)) {
            await http.post(
              Uri.parse('${ApiService.baseURL}/USUARIO/cerrarSesion'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $accessToken',
              },
              body: json.encode({'motivo': 'timeout', 'fuente': 'recolector'}),
            );
          }
        } catch (e) {
          log('No se pudo parsear last-request: $lastRequest -> $e');
        }
      }
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
        prefs.setString('last-request', DateTime.now().toIso8601String());
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

  static Future<Map<String, dynamic>> enviarEvaluacion(
    Map<String, dynamic> jsonFinal,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiService.baseURL}/CURSOS_MOVIL/saveEvaluacion');
    final prefs = await SharedPreferences.getInstance();
    try {
      final lastRequest = prefs.getString('last-request') ?? '';
      if (lastRequest.isNotEmpty) {
        try {
          final lastDate = DateTime.parse(lastRequest);
          final now = DateTime.now();
          final difference = now.difference(lastDate);

          if (difference >= Duration(hours: 2)) {
            await http.post(
              Uri.parse('${ApiService.baseURL}/USUARIO/cerrarSesion'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $accessToken',
              },
              body: json.encode({'motivo': 'timeout', 'fuente': 'recolector'}),
            );
          }
        } catch (e) {
          log('No se pudo parsear last-request: $lastRequest -> $e');
        }
      }
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(jsonFinal),
      );

      if (response.statusCode == 200) {
        prefs.setString('last-request', DateTime.now().toIso8601String());
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

  static Future<Map<String, dynamic>> getFormularioEncuesta(
    int idFormulario,
    int tipo,
    String accessToken,
  ) async {
    final url = Uri.parse(
      '${ApiService.baseURL}/CURSOS_MOVIL/loadFormEncuesta',
    );
    final prefs = await SharedPreferences.getInstance();
    try {
      final lastRequest = prefs.getString('last-request') ?? '';
      if (lastRequest.isNotEmpty) {
        try {
          final lastDate = DateTime.parse(lastRequest);
          final now = DateTime.now();
          final difference = now.difference(lastDate);

          if (difference >= Duration(hours: 2)) {
            await http.post(
              Uri.parse('${ApiService.baseURL}/USUARIO/cerrarSesion'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $accessToken',
              },
              body: json.encode({'motivo': 'timeout', 'fuente': 'recolector'}),
            );
          }
        } catch (e) {
          log('No se pudo parsear last-request: $lastRequest -> $e');
        }
      }
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'id_formulario': idFormulario, 'tipo': tipo}),
      );

      if (response.statusCode == 200) {
        prefs.setString('last-request', DateTime.now().toIso8601String());
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

  static Future<Map<String, dynamic>> enviarEncuesta(
    Map<String, dynamic> jsonFinal,
    String accessToken,
  ) async {
    final url = Uri.parse('${ApiService.baseURL}/CURSOS_MOVIL/saveEncuesta');
    final prefs = await SharedPreferences.getInstance();
    try {
      final lastRequest = prefs.getString('last-request') ?? '';
      if (lastRequest.isNotEmpty) {
        try {
          final lastDate = DateTime.parse(lastRequest);
          final now = DateTime.now();
          final difference = now.difference(lastDate);

          if (difference >= Duration(hours: 2)) {
            await http.post(
              Uri.parse('${ApiService.baseURL}/USUARIO/cerrarSesion'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $accessToken',
              },
              body: json.encode({'motivo': 'timeout', 'fuente': 'recolector'}),
            );
          }
        } catch (e) {
          log('No se pudo parsear last-request: $lastRequest -> $e');
        }
      }
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(jsonFinal),
      );

      if (response.statusCode == 200) {
        prefs.setString('last-request', DateTime.now().toIso8601String());
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
