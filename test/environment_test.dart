import 'package:flutter_test/flutter_test.dart';
import 'package:rotativo/config/environment.dart';

void main() {
  group('Environment Configuration Tests', () {
    test('should default to dev environment', () {
      // Reset environment to default
      Environment.setEnvironment('dev');

      expect(Environment.currentEnvironment, equals('dev'));
      expect(Environment.registerApi, contains('cadastrah.timob.com.br'));
      expect(Environment.autenticaApi, contains('autenticah.timob.com.br'));
      expect(Environment.transacionaApi, contains('transacionah.timob.com.br'));
      expect(Environment.voucherApi, contains('voucherh.timob.com.br'));
    });

    test('should switch to prod environment', () {
      Environment.setEnvironment('prod');

      expect(Environment.currentEnvironment, equals('prod'));
      expect(Environment.registerApi, contains('cadastra.timob.com.br'));
      expect(Environment.autenticaApi, contains('autentica.timob.com.br'));
      expect(Environment.transacionaApi, contains('transaciona.timob.com.br'));
      expect(Environment.voucherApi, contains('voucher.timob.com.br'));
    });

    test('should switch back to dev environment', () {
      Environment.setEnvironment('dev');

      expect(Environment.currentEnvironment, equals('dev'));
      expect(Environment.registerApi, contains('cadastrah.timob.com.br'));
      expect(Environment.autenticaApi, contains('autenticah.timob.com.br'));
      expect(Environment.transacionaApi, contains('transacionah.timob.com.br'));
      expect(Environment.voucherApi, contains('voucherh.timob.com.br'));
    });

    test('should print current configuration', () {
      Environment.setEnvironment('dev');
      expect(() => Environment.printCurrentConfig(), returnsNormally);
    });
  });
}
