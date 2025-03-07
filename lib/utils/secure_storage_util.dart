import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtil {
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  // OBTIENE EL VALOR DE ALMACENAMIENTO SEGURO A PARTIR DE UNA LLAVE
  Future<String?> getValue(String key) async {
    return await storage.read(key: key);
  }

  // ASIGNA UN VALOR A LA LLAVE CORRESPONDIENTE EN EL ALMACENAMIENTO SEGURO
  Future<void> setValue(String key, String value) async {
    return storage.write(key: key, value: value);
  }

  // ELIMINA EL VALOR DE LA CLAVE DEFINIDA EN EL ALMACENAMIENTO SEGURO
  Future<void> deleteValue(String key) async {
    return storage.delete(key: key);
  }
}
