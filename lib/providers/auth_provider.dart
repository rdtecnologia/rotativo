import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../config/environment.dart';
import '../services/biometric_service.dart';

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadStoredUser();
  }

  // Load stored user and biometric status on app start
  Future<void> _loadStoredUser() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await AuthService.getStoredUser();

      // Carrega o status da biometria
      final biometricEnabled = await AuthService.isBiometricEnabled();

      if (user != null && user.token != null) {
        // Verify if token is still valid by fetching current user
        try {
          final currentUser = await AuthService.getCurrentUser();
          state = state.copyWith(
            user: currentUser,
            biometricEnabled: biometricEnabled,
            isLoading: false,
          );
        } catch (e) {
          // Token invalid, clear stored data
          await AuthService.logout();
          state = state.copyWith(
            user: null,
            biometricEnabled: false,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          biometricEnabled: biometricEnabled,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Check CPF (mantido para compatibilidade, mas não usado no novo fluxo)
  Future<void> checkCPF(String cpf) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final checkResult = await AuthService.checkCPFExists(cpf);
      state = state.copyWith(
        checkCPF: checkResult,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Login
  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await AuthService.login(username, password);
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Register
  Future<void> register(RegisterRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await AuthService.register(request);
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Forgot password
  Future<void> forgotPassword(String cpf) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await AuthService.forgotPassword(cpf);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (kDebugMode) {
        // Log removed
      }

      // Clear stored data
      await AuthService.logout();

      // Clear state completely
      state = const AuthState();

      if (kDebugMode) {
        // Logs removed
      }
    } catch (e) {
      if (kDebugMode) {
        // Log removed
      }

      // Even if there's an error, clear the state
      state = const AuthState();

      if (kDebugMode) {
        // Log removed
      }
    }
  }

  // Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await AuthService.changePassword(oldPassword, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Habilita autenticação biométrica
  Future<bool> enableBiometricAuth() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await AuthService.enableBiometricAuth();

      if (success) {
        state = state.copyWith(
          biometricEnabled: true,
          isLoading: false,
        );
        // Log removed
      } else {
        state = state.copyWith(
          error:
              'Não foi possível habilitar a autenticação biométrica. Faça login primeiro.',
          isLoading: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Desabilita autenticação biométrica
  Future<bool> disableBiometricAuth() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await AuthService.disableBiometricAuth();

      if (success) {
        state = state.copyWith(
          biometricEnabled: false,
          isLoading: false,
        );
        // Log removed
      } else {
        state = state.copyWith(
          error: 'Não foi possível desabilitar a autenticação biométrica',
          isLoading: false,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Sincroniza o estado da biometria com o storage
  Future<void> syncBiometricStatus() async {
    try {
      final biometricEnabled = await AuthService.isBiometricEnabled();
      state = state.copyWith(biometricEnabled: biometricEnabled);
      // Log removed
    } catch (e) {
      // Log removed
    }
  }

  /// Login usando biometria
  Future<bool> loginWithBiometrics() async {
    // Log removed
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Log removed
      final biometricSuccess = await BiometricService.authenticate();

      if (!biometricSuccess) {
        // Log removed
        state = state.copyWith(
          error: 'Autenticação biométrica falhou',
          isLoading: false,
        );
        return false;
      }

      // Log removed
      final credentials = await AuthService.loginWithBiometrics();

      if (credentials == null) {
        // Log removed
        state = state.copyWith(
          error: 'Credenciais biométricas não encontradas',
          isLoading: false,
        );
        return false;
      }

      // Log removed
      final cpf = credentials['cpf'] as String;
      final password = credentials['password'] as String;

      // Usa o método de login existente
      final user = await AuthService.login(cpf, password);

      // Log removed

      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );

      // Log removed
      return true;
    } catch (e) {
      // Log removed
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Clear check CPF result
  void clearCheckCPF() {
    state = state.copyWith(clearCheckCPF: true);
  }

  // Change environment (for development/testing)
  void changeEnvironment(String environment) {
    Environment.setEnvironment(environment);
  }
}

// Helper providers for easier access
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.error;
});

final checkCPFProvider = Provider<CheckCPFResponse?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.checkCPF;
});
