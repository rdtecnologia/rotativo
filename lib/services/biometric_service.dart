import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Verifica se o dispositivo suporta biometria
  static Future<bool> isBiometricAvailable() async {
    try {
      // Verificação mais simples e direta
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isDeviceSupported) {
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      // Verifica se há qualquer tipo de biometria disponível
      final hasAnyBiometric = availableBiometrics.isNotEmpty;

      return hasAnyBiometric;
    } on PlatformException catch (e) {
      debugPrint('Erro ao verificar biometria: $e');
      return false;
    }
  }

  /// Obtém os tipos de biometria disponíveis
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics;
    } on PlatformException catch (e) {
      return [];
    }
  }

  /// Autentica usando biometria
  static Future<bool> authenticate() async {
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Toque no sensor para fazer login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return result;
    } on PlatformException catch (e) {
      return false;
    }
  }

  /// Verifica se o dispositivo tem impressão digital
  static Future<bool> hasFingerprint() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      final hasFingerprint = biometrics.contains(BiometricType.fingerprint);
      return hasFingerprint;
    } on PlatformException catch (e) {
      return false;
    }
  }
}
