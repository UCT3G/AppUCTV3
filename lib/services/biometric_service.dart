import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  // METODO QUE VERIFICA SI EL DISPOSITIVO SOPORTA AUTENTICACION BIOMETRICA
  Future<bool> isBiometricAvailable() async {
    try {
      bool canCheck = await _localAuthentication.canCheckBiometrics;
      List<BiometricType> availableBiometrics =
          await _localAuthentication.getAvailableBiometrics();
      return canCheck && availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error al verificar biométricos: $e');
      return false;
    }
  }

  // METODO PARA OBTENER LA LISTA DE TIPOS DE AUTENTICACION BIOMETRICA
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuthentication.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error al obtener biométricos: $e');
      return [];
    }
  }

  // Ejecuta autenticación con biométricos si están disponibles
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: 'Usa tu huella o rostro para ingresar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('Error en biométricos: $e');
      return false;
    }
  }

  // Autenticación con cualquier método seguro configurado en el dispositivo
  Future<bool> authenticateWithDeviceLock() async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason:
            'Autentícate con el método de seguridad del dispositivo',
        options: const AuthenticationOptions(
          biometricOnly:
              false, // Aquí se incluye el PIN/patrón si no hay biométricos
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('Error al autenticar con lock screen: $e');
      return false;
    }
  }

  // Verifica si el dispositivo tiene alguna forma de seguridad (lock o biométrico)
  Future<bool> isLockScreen() async {
    try {
      final isSupported = await _localAuthentication.isDeviceSupported();

      return isSupported;
    } catch (e) {
      debugPrint('Error al verificar seguridad del dispositivo: $e');
      return false;
    }
  }
}
