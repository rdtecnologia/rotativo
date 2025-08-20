import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Verifica se o dispositivo suporta biometria
  static Future<bool> isBiometricAvailable() async {
    print('🔍 BiometricService: Verificando se biometria está disponível...');
    try {
      // Verificação mais simples e direta
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      print('🔍 BiometricService: isDeviceSupported: $isDeviceSupported');

      if (!isDeviceSupported) {
        print('🔍 BiometricService: Dispositivo não suportado');
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      print(
          '🔍 BiometricService: Biometrias disponíveis: $availableBiometrics');

      // Verifica se há qualquer tipo de biometria disponível
      final hasAnyBiometric = availableBiometrics.isNotEmpty;
      print('🔍 BiometricService: Tem alguma biometria: $hasAnyBiometric');

      return hasAnyBiometric;
    } on PlatformException catch (e) {
      print('❌ BiometricService: Erro ao verificar biometria: $e');
      debugPrint('Erro ao verificar biometria: $e');
      return false;
    }
  }

  /// Obtém os tipos de biometria disponíveis
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      print('🔍 BiometricService: Biometrias disponíveis: $biometrics');
      return biometrics;
    } on PlatformException catch (e) {
      print('❌ BiometricService: Erro ao obter biometrias: $e');
      return [];
    }
  }

  /// Autentica usando biometria
  static Future<bool> authenticate() async {
    print('🔍 BiometricService: Iniciando autenticação biométrica...');
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Toque no sensor para fazer login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      print('🔍 BiometricService: Resultado da autenticação: $result');
      return result;
    } on PlatformException catch (e) {
      print('❌ BiometricService: Erro na autenticação: $e');
      return false;
    }
  }

  /// Verifica se o dispositivo tem impressão digital
  static Future<bool> hasFingerprint() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      final hasFingerprint = biometrics.contains(BiometricType.fingerprint);
      print('🔍 BiometricService: Tem impressão digital: $hasFingerprint');
      return hasFingerprint;
    } on PlatformException catch (e) {
      print('❌ BiometricService: Erro ao verificar impressão digital: $e');
      return false;
    }
  }
}
