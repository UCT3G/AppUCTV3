import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication localAuthentication = LocalAuthentication();

  // METODO QUE VERIFICA SI EL DISPOSITIVO SOPORTA AUTENTICACION BIOMETRICA
  Future<bool> isBiometricAvailable() async {
    return await localAuthentication.canCheckBiometrics ||
        await localAuthentication.isDeviceSupported();
  }

  // METODO QUE AUTENTICA AL USUARIO USANDO BIOMETRICOS
  Future<bool> authenticate() async {
    try {
      return await localAuthentication.authenticate(
        localizedReason: 'Por favor, autentícate para acceder',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      print('Error en autenticación biométrica: $e');
      return false;
    }
  }
}
