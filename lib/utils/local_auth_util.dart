import 'package:local_auth/local_auth.dart';

class LocalAuthUtil {
  final LocalAuthentication authentication = LocalAuthentication();

  // VERIFICA SI EL DISPOSITIVO SOPORTA BIOMETRIA
  Future<bool> deviceSupportBiometric() async {
    return await authentication.isDeviceSupported();
  }

  // VERIFICA SI EL DISPOSITIVO TIENE CONFIGURADO INFORMACIÓN BIOMÉTRICA
  Future<bool> canCheckBiometrics() async {
    return await authentication.canCheckBiometrics;
  }

  // OBTIENE LA LISTA DE OPCIONES BIOMETRICAS PARA USAR (Facial, dactilar, iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await authentication.getAvailableBiometrics();
  }

  // AUTENTICACIÓN, VALIDA LA INFORMACIÓN BIOMÉTRICA CON LA CONFIGURADA DEL DISPOSITIVO.
  Future<bool> authenticate() async {
    try {
      return await authentication.authenticate(
        localizedReason: 'Usa tus datos biométricos para iniciar sesión',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
