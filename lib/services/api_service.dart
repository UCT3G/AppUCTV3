// import 'package:http/http.dart' as http;
// import 'dart:convert';

class ApiService {
  // static const String baseURL = 'http://192.168.1.7:8007';
  // static const String baseURL = 'http://192.168.1.198:8007';
  static const String baseURL = 'http://10.10.31.14:8005';
  // static const String baseURL = 'https://uct.tresguerras.com.mx/uct_app';

  // METODO PARA HACER SOLICITUDES GET
  // static Future<http.Response> get(String endpoint) async {
  //   final url = Uri.parse('$baseURL/$endpoint');
  //   return await http.get(url);
  // }

  // // METODO PARA HACER SOLICITUDES GET CON TOKEN
  // static Future<http.Response> getToken(String endpoint, String token) async {
  //   final url = Uri.parse('$baseURL/$endpoint');
  //   return await http.get(url, headers: {'Authorization': 'Bearer $token'});
  // }

  // // METODO PARA HACER SOLICITUDES POST
  // static Future<http.Response> post(
  //   String endpoint,
  //   Map<String, dynamic> body,
  // ) async {
  //   final url = Uri.parse('$baseURL/$endpoint');
  //   return await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(body),
  //   );
  // }
}
