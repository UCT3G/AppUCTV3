import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  // METODO QUE VERIFICA SI EL DISPOSITIVO SOPORTA AUTENTICACION BIOMETRICA
  Future<bool> isBiometricAvailable() async {
    bool canCheck = await _localAuthentication.canCheckBiometrics;
    List<BiometricType> availableBiometrics =
        await _localAuthentication.getAvailableBiometrics();
    return canCheck && availableBiometrics.isNotEmpty;
  }

  // METODO QUE AUTENTICA AL USUARIO USANDO BIOMETRICOS
  Future<bool> authenticate() async {
    try {
      if (!await isBiometricAvailable()) {
        throw Exception('El dispositivo no tiene biometría configurada');
      }
      return await _localAuthentication.authenticate(
        localizedReason: 'Por favor, autentícate para acceder',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      debugPrint('Error en autenticación biométrica: $e');
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
}
