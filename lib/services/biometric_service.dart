import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  static final _storage = FlutterSecureStorage();

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

  // METODO PARA HABILITAR LA AUTENTICACION BIOMETRICA
  static Future<void> enableBiometricAuth() async {
    await _storage.write(key: 'biometric_auth_enabled', value: 'true');
  }

  // METODO PARA DESHABILITAR LA AUTENTICACION BIOMETRICA
  static Future<void> disableBiometricAuth() async {
    await _storage.write(key: 'biometric_auth_enabled', value: 'false');
  }

  // METODO PARA VERIFICAR SI LA AUTENTICACION BIOMETRICA ESTA HABILITADA
  static Future<bool> isBiometricAuthEnabled() async {
    final value = await _storage.read(key: 'biometric_auth_enabled');
    return value == 'true';
  }

  static Future<String?> getBiometricAuthPreference() async {
    return await _storage.read(key: 'biometric_auth_enabled');
  }
}
