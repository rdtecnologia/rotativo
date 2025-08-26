import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';

// Estado específico da tela de login
class LoginScreenState {
  final bool biometricEnabled;
  final bool showLoginCard;
  final bool isCheckingBiometric;
  final bool isInitialized;

  const LoginScreenState({
    this.biometricEnabled = false,
    this.showLoginCard = true,
    this.isCheckingBiometric = false,
    this.isInitialized = false,
  });

  LoginScreenState copyWith({
    bool? biometricEnabled,
    bool? showLoginCard,
    bool? isCheckingBiometric,
    bool? isInitialized,
  }) {
    return LoginScreenState(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      showLoginCard: showLoginCard ?? this.showLoginCard,
      isCheckingBiometric: isCheckingBiometric ?? this.isCheckingBiometric,
      isInitialized: isInitialized ?? this.isInitialized,
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

      // Executar verificações em paralelo para maior velocidade
      final futures = await Future.wait([
        BiometricService.isBiometricAvailable(),
        AuthService.isBiometricEnabled(),
        AuthService.getStoredCredentials(),
      ]);

      final available = futures[0] as bool;
      final enabled = futures[1] as bool;
      final credentials = futures[2];

      // Só habilita biometria se tiver credenciais armazenadas E biometria estiver habilitada
      final finalEnabled = available && enabled && credentials != null;

      if (state.isCheckingBiometric) {
        // Verificar se ainda está no estado correto
        state = state.copyWith(
          biometricEnabled: finalEnabled,
          showLoginCard: !finalEnabled,
          isCheckingBiometric: false,
          isInitialized: true,
        );
      }
    } catch (e) {
      if (state.isCheckingBiometric) {
        // Verificar se ainda está no estado correto
        state = state.copyWith(
          biometricEnabled: false,
          isCheckingBiometric: false,
          isInitialized: true,
        );
      }
    }
  }

  void toggleLoginCard() {
    if (state.isInitialized) {
      // Só permitir toggle se estiver inicializado
      state = state.copyWith(
        showLoginCard: !state.showLoginCard,
      );
    }
  }

  Future<void> refreshBiometricStatus() async {
    if (state.isInitialized) {
      // Só permitir refresh se estiver inicializado
      await _checkBiometricStatus();
    }
  }

  // Método para inicializar o estado (chamado pela tela)
  Future<void> initialize() async {
    if (!state.isInitialized) {
      // Evitar inicialização múltipla
      // Inicializar imediatamente para evitar delay
      await _checkBiometricStatus();
    }
  }

  // Método para resetar o estado
  void reset() {
    state = const LoginScreenState();
  }
}

// Providers específicos para otimizar rebuilds
final biometricEnabledProvider = Provider<bool>((ref) {
  final state = ref.watch(loginScreenProvider);
  return state.isInitialized ? state.biometricEnabled : false;
});

final showLoginCardProvider = Provider<bool>((ref) {
  final state = ref.watch(loginScreenProvider);
  return state.isInitialized ? state.showLoginCard : true;
});

final isCheckingBiometricProvider = Provider<bool>((ref) {
  final state = ref.watch(loginScreenProvider);
  return state.isCheckingBiometric;
});

final isInitializedProvider = Provider<bool>((ref) {
  return ref.watch(loginScreenProvider).isInitialized;
});
