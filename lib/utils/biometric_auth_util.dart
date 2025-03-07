import 'local_auth_util.dart';
import 'secure_storage_util.dart';

class BiometricAuthUtil {
  final LocalAuthUtil localAuthUtil = LocalAuthUtil();
  final SecureStorageUtil secureStorageUtil = SecureStorageUtil();
  final String passwordKey = 'password', usernameKey = 'username';

  // VALIDA SI EL DISPOSITIVO SOPORTA LA BIOMETRIA Y SI LA TIENE CONFIGURADA EN EL SISTEMA
  Future<bool> isBiometricSupported() async {
    final availableBiometrics = await localAuthUtil.getAvailableBiometrics();

    return await localAuthUtil.deviceSupportBiometric() &&
        await localAuthUtil.canCheckBiometrics() &&
        availableBiometrics.isNotEmpty;
  }

  // VALIDA SI EL USUARIO TIENE HABILITADO EL INICIO BIOMÉTRICO, REVISANDO LAS CREDENCIALES ALMACENADAS EN SECURE STORAGE
  Future<bool> hasEnabledBiometricAuth() async {
    final String savedUsername =
        await getValueFromSecureStorage(usernameKey) ?? '';
    final String savedPassword =
        await getValueFromSecureStorage(passwordKey) ?? '';

    final bool isEnableBiometric =
        savedUsername.isNotEmpty && savedPassword.isNotEmpty;
    return isEnableBiometric;
  }

  // EJECUTA LA AUTENTICACIÓN BIOMÉTRICA
  Future<bool> biometricAuthenticate() async {
    if (await isBiometricSupported()) {
      return await localAuthUtil.authenticate();
    } else {
      return false;
    }
  }

  // HABILITA LA AUTENTICACIÓN BIOMÉTRICA ALMACENANDO LAS CREDENCIALES EN EL SECURE STORAGE
  Future<void> enableBiometricAuth(String username, String password) async {
    try {
      await secureStorageUtil.setValue(usernameKey, username);
      await secureStorageUtil.setValue(passwordKey, password);
    } catch (e) {
      print(e);
    }
  }

  // DESHABILITA LA AUTENTICACIÓN BIOMÉTRICA ELIMINANDO LAS CREDENCIALES ALMACENADAS EN EL SECURE STORAGE
  Future<void> disableBiometricAuth() async {
    try {
      await secureStorageUtil.deleteValue(usernameKey);
      await secureStorageUtil.deleteValue(passwordKey);
    } catch (e) {
      print(e);
    }
  }

  // VALIDA SI LA BIOMÉTRIA SE ENCUENTRA ACTIVA Y SIENDO EL CASO ENTONCES ACTUALIZA LAS CREDENCIALES DEL SECURE STORAGE PARA EL USUARIO QUE CONFIGURÓ LA FUNCIONALIDAD
  Future<void> handleUpdateBiometricData(
    String currentUsername,
    String password,
  ) async {
    if (await hasEnabledBiometricAuth() == true) {
      String savedUsername = await getValueFromSecureStorage(usernameKey) ?? '';
      if (currentUsername == savedUsername) {
        String savedPassword =
            await getValueFromSecureStorage(passwordKey) ?? '';
        if (savedPassword != password) await updateBiometricData(password);
      }
    }
  }

  // ACTUALIZA LA CONTRASEÑA DEL ALMACENAMIENTO SEGURO
  Future<void> updateBiometricData(String password) async {
    try {
      await secureStorageUtil.setValue(passwordKey, password);
    } catch (e) {
      print(e);
    }
  }

  // OBTIENE UN VALOR DE ALMACENAMIENTO SEGURO A PARTIR DE UNA CLAVE
  Future<String?> getValueFromSecureStorage(String key) async {
    return await secureStorageUtil.getValue(key);
  }
}
