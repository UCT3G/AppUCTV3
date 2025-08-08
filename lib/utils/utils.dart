import 'dart:convert';

// import 'package:app_uct/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// METODO PARA CODIFICAR EN BASE64
String encodeBase64(String text) {
  return base64.encode(utf8.encode(text));
}

Future<bool> recursoDisponible(String rutaRecurso) async {
  final url = Uri.parse(rutaRecurso);

  try {
    final res = await http.get(url, headers: {'Range': 'bytes=0-0'});

    return res.statusCode == 200 || res.statusCode == 206;
  } catch (e) {
    debugPrint('Error al verificar el recurso: $e');
    return false;
  }
}
