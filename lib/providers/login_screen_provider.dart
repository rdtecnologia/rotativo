import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
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

      debugPrint('=== Verificando status biométrico ===');
      debugPrint(
          'Estado atual - isInitialized: ${state.isInitialized}, showLoginCard: ${state.showLoginCard}');

      // Executar verificações em paralelo para maior velocidade
      final futures = await Future.wait([
        BiometricService.isBiometricAvailable(),
        AuthService.isBiometricEnabled(),
        AuthService.getStoredCredentials(),
      ]);

      final available = futures[0] as bool;
      final enabled = futures[1] as bool;
      final credentials = futures[2];

      debugPrint('BiometricService.isBiometricAvailable(): $available');
      debugPrint('AuthService.isBiometricEnabled(): $enabled');
      debugPrint('AuthService.getStoredCredentials(): ${credentials != null}');

      // Só habilita biometria se tiver credenciais armazenadas E biometria estiver habilitada
      final finalEnabled = available && enabled && credentials != null;

      debugPrint(
          'Resultado final: $finalEnabled (available: $available, enabled: $enabled, credentials: ${credentials != null})');

      if (state.isCheckingBiometric) {
        // Verificar se ainda está no estado correto
        // Sempre usar a mesma lógica: mostrar formulário se não há biometria
        final newShowLoginCard = !finalEnabled;

        debugPrint(
            'Definindo showLoginCard: $newShowLoginCard (finalEnabled: $finalEnabled)');

        state = state.copyWith(
          biometricEnabled: finalEnabled,
          showLoginCard: newShowLoginCard,
          isCheckingBiometric: false,
          isInitialized: true,
        );

        debugPrint(
            'Estado atualizado - biometricEnabled: $finalEnabled, showLoginCard: $newShowLoginCard');
      }
    } catch (e) {
      debugPrint('Erro ao verificar status biométrico: $e');
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
      final newShowLoginCard = !state.showLoginCard;
      debugPrint(
          'Toggle login card: ${state.showLoginCard} -> $newShowLoginCard');

      state = state.copyWith(
        showLoginCard: newShowLoginCard,
      );
    } else {
      debugPrint('Tentativa de toggle antes da inicialização');
    }
  }

  Future<void> refreshBiometricStatus() async {
    if (state.isInitialized) {
      // Só permitir refresh se estiver inicializado
      debugPrint(
          'Refresh biométrico solicitado - estado atual: showLoginCard=${state.showLoginCard}');
      await _checkBiometricStatus();
    } else {
      debugPrint('Refresh biométrico solicitado antes da inicialização');
    }
  }

  // Método para inicializar o estado (chamado pela tela)
  Future<void> initialize() async {
    if (!state.isInitialized) {
      // Evitar inicialização múltipla
      // Inicializar imediatamente para evitar delay
      debugPrint('Inicializando tela de login - resetando estado');
      await _checkBiometricStatus();
    } else {
      debugPrint('Tela de login já inicializada');
    }
  }

  // Método para resetar o estado
  void reset() {
    debugPrint('Resetando estado da tela de login');
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
