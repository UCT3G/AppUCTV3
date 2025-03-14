import 'dart:convert';

// METODO PARA CODIFICAR EN BASE64
String encodeBase64(String text) {
  return base64.encode(utf8.encode(text));
}
