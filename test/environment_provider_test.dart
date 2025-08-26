import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotativo/providers/environment_provider.dart';
import 'package:rotativo/config/environment.dart';

void main() {
  group('EnvironmentProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with current environment', () {
      final envState = container.read(environmentProvider);
      expect(
          envState.currentEnvironment, equals(Environment.currentEnvironment));
      expect(envState.isDebugMode, isTrue);
    });

    test('should change environment when setEnvironment is called', () {
      final envNotifier = container.read(environmentProvider.notifier);

      // Change to prod
      envNotifier.setEnvironment('prod');
      expect(envNotifier.currentEnvironment, equals('prod'));

      // Change to dev
      envNotifier.setEnvironment('dev');
      expect(envNotifier.currentEnvironment, equals('dev'));

      // Change to offline
      envNotifier.setEnvironment('offline');
      expect(envNotifier.currentEnvironment, equals('offline'));
    });

    test('should return correct environment colors', () {
      final envNotifier = container.read(environmentProvider.notifier);

      // Test dev color (orange)
      envNotifier.setEnvironment('dev');
      expect(envNotifier.environmentColor, equals(0xFFFF9800));

      // Test prod color (green)
      envNotifier.setEnvironment('prod');
      expect(envNotifier.environmentColor, equals(0xFF4CAF50));

      // Test offline color (gray)
      envNotifier.setEnvironment('offline');
      expect(envNotifier.environmentColor, equals(0xFF9E9E9E));
    });

    test('should return correct environment display names', () {
      final envNotifier = container.read(environmentProvider.notifier);

      // Primeiro define o ambiente para dev para garantir o teste
      envNotifier.setEnvironment('dev');
      expect(envNotifier.environmentDisplayName, equals('DEV'));

      envNotifier.setEnvironment('prod');
      expect(envNotifier.environmentDisplayName, equals('PROD'));

      envNotifier.setEnvironment('offline');
      expect(envNotifier.environmentDisplayName, equals('OFFLINE'));
    });

    test('should return correct environment checks', () {
      final envNotifier = container.read(environmentProvider.notifier);

      envNotifier.setEnvironment('dev');
      expect(envNotifier.isDev, isTrue);
      expect(envNotifier.isProd, isFalse);
      expect(envNotifier.isOffline, isFalse);

      envNotifier.setEnvironment('prod');
      expect(envNotifier.isDev, isFalse);
      expect(envNotifier.isProd, isTrue);
      expect(envNotifier.isOffline, isFalse);

      envNotifier.setEnvironment('offline');
      expect(envNotifier.isDev, isFalse);
      expect(envNotifier.isProd, isFalse);
      expect(envNotifier.isOffline, isTrue);
    });

    test('should return available environments', () {
      final envNotifier = container.read(environmentProvider.notifier);
      final availableEnvs = envNotifier.availableEnvironments;

      expect(availableEnvs, contains('dev'));
      expect(availableEnvs, contains('prod'));
      expect(availableEnvs, contains('offline'));
      expect(availableEnvs.length, equals(3));
    });
  });
}
