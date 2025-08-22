import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';

// Estado específico da tela de login
class LoginScreenState {
  final bool biometricEnabled;
  final bool showLoginCard;
  final bool isCheckingBiometric;

  const LoginScreenState({
    this.biometricEnabled = false,
    this.showLoginCard = true,
    this.isCheckingBiometric = false,
  });

  LoginScreenState copyWith({
    bool? biometricEnabled,
    bool? showLoginCard,
    bool? isCheckingBiometric,
  }) {
    return LoginScreenState(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      showLoginCard: showLoginCard ?? this.showLoginCard,
      isCheckingBiometric: isCheckingBiometric ?? this.isCheckingBiometric,
    );
  }
}

// Provider para o estado da tela de login
final loginScreenProvider =
    StateNotifierProvider<LoginScreenNotifier, LoginScreenState>((ref) {
  return LoginScreenNotifier();
});

class LoginScreenNotifier extends StateNotifier<LoginScreenState> {
  LoginScreenNotifier() : super(const LoginScreenState());

  Future<void> _checkBiometricStatus() async {
    try {
      state = state.copyWith(isCheckingBiometric: true);

      final available = await BiometricService.isBiometricAvailable();
      final enabled = await AuthService.isBiometricEnabled();
      final credentials = await AuthService.getStoredCredentials();

      // Só habilita biometria se tiver credenciais armazenadas E biometria estiver habilitada
      final finalEnabled = available && enabled && credentials != null;

      state = state.copyWith(
        biometricEnabled: finalEnabled,
        showLoginCard: !finalEnabled,
        isCheckingBiometric: false,
      );
    } catch (e) {
      state = state.copyWith(
        biometricEnabled: false,
        isCheckingBiometric: false,
      );
    }
  }

  void toggleLoginCard() {
    state = state.copyWith(
      showLoginCard: !state.showLoginCard,
    );
  }

  Future<void> refreshBiometricStatus() async {
    await _checkBiometricStatus();
  }

  // Método para inicializar o estado (chamado pela tela)
  Future<void> initialize() async {
    await _checkBiometricStatus();
  }
}

// Providers específicos para otimizar rebuilds
final biometricEnabledProvider = Provider<bool>((ref) {
  return ref.watch(loginScreenProvider).biometricEnabled;
});

final showLoginCardProvider = Provider<bool>((ref) {
  return ref.watch(loginScreenProvider).showLoginCard;
});

final isCheckingBiometricProvider = Provider<bool>((ref) {
  return ref.watch(loginScreenProvider).isCheckingBiometric;
});
