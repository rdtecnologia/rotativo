import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotativo/providers/login_screen_provider.dart';

void main() {
  group('LoginScreenProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have default values', () {
      final state = container.read(loginScreenProvider);

      expect(state.biometricEnabled, false);
      expect(state.showLoginCard, true);
      expect(state.isCheckingBiometric, false);
    });

    test('toggleLoginCard should change showLoginCard value', () {
      final notifier = container.read(loginScreenProvider.notifier);

      // Initial state
      expect(container.read(loginScreenProvider).showLoginCard, true);

      // Toggle to false
      notifier.toggleLoginCard();
      expect(container.read(loginScreenProvider).showLoginCard, false);

      // Toggle back to true
      notifier.toggleLoginCard();
      expect(container.read(loginScreenProvider).showLoginCard, true);
    });

    test('biometricEnabledProvider should return correct value', () {
      final notifier = container.read(loginScreenProvider.notifier);

      // Initial state
      expect(container.read(biometricEnabledProvider), false);

      // Simulate state change
      notifier.state = const LoginScreenState(
        biometricEnabled: true,
        showLoginCard: false,
        isCheckingBiometric: false,
      );

      expect(container.read(biometricEnabledProvider), true);
    });

    test('showLoginCardProvider should return correct value', () {
      final notifier = container.read(loginScreenProvider.notifier);

      // Initial state
      expect(container.read(showLoginCardProvider), true);

      // Simulate state change
      notifier.state = const LoginScreenState(
        biometricEnabled: true,
        showLoginCard: false,
        isCheckingBiometric: false,
      );

      expect(container.read(showLoginCardProvider), false);
    });

    test('isCheckingBiometricProvider should return correct value', () {
      final notifier = container.read(loginScreenProvider.notifier);

      // Initial state
      expect(container.read(isCheckingBiometricProvider), false);

      // Simulate state change
      notifier.state = const LoginScreenState(
        biometricEnabled: false,
        showLoginCard: true,
        isCheckingBiometric: true,
      );

      expect(container.read(isCheckingBiometricProvider), true);
    });
  });
}
