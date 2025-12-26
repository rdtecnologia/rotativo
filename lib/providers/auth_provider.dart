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
  AuthNotifier() : super(const AuthState(isLoading: true)) {
    // Inicializar com loading true para evitar mudanças rápidas de estado
    _loadStoredUser();
  }

  // Load stored user and biometric status on app start - OPTIMIZED
  Future<void> _loadStoredUser() async {
    final startTime = DateTime.now();

    if (kDebugMode) {
      print('🔄 AuthProvider: Iniciando carregamento de usuário armazenado');
    }

    try {
      // Manter loading true durante todo o processo para evitar flash
      state = state.copyWith(isLoading: true);

      if (kDebugMode) {
        print('🔄 AuthProvider: Estado definido como loading');
      }

      // Carregar dados locais primeiro (muito rápido)
      final user = await AuthService.getStoredUser();
      final biometricEnabled = await AuthService.isBiometricEnabled();

      if (kDebugMode) {
        print(
            '🔄 AuthProvider: Dados locais carregados - user: ${user != null}, biometric: $biometricEnabled');
      }

      // Se não há usuário, não precisa validar token
      if (user == null || user.token == null) {
        if (kDebugMode) {
          print(
              '🔄 AuthProvider: Nenhum usuário encontrado, finalizando sem validação');
        }

        // Garantir tempo mínimo de carregamento para UX
        await _ensureMinimumLoadingTime(
            startTime, const Duration(milliseconds: 1200));

        state = state.copyWith(
          user: null,
          biometricEnabled: biometricEnabled,
          isLoading: false,
        );

        if (kDebugMode) {
          print('🔄 AuthProvider: Estado finalizado - usuário não autenticado');
        }
        return;
      }

      // Validar token com timeout para não travar o app
      try {
        if (kDebugMode) {
          print('🔄 AuthProvider: Validando token do usuário');
        }

        final currentUser = await AuthService.getCurrentUserWithTimeout(
          timeout: const Duration(seconds: 3),
        );

        // Garantir tempo mínimo de carregamento para UX
        await _ensureMinimumLoadingTime(
            startTime, const Duration(milliseconds: 1500));

        state = state.copyWith(
          user: currentUser,
          biometricEnabled: biometricEnabled,
          isLoading: false,
        );

        if (kDebugMode) {
          print('🔄 AuthProvider: Estado finalizado - usuário autenticado');
        }
      } catch (e) {
        // Token inválido, timeout ou erro de conexão - limpar dados
        if (kDebugMode) {
          print('🔄 AuthProvider: Token validation failed: $e');
        }

        // Se for erro de conexão, não limpar dados automaticamente
        if (e.toString().contains('connection') ||
            e.toString().contains('host lookup') ||
            e.toString().contains('Failed host lookup')) {
          if (kDebugMode) {
            print(
                '🔄 AuthProvider: Connection error detected - keeping stored data');
          }

          // Garantir tempo mínimo de carregamento para UX
          await _ensureMinimumLoadingTime(
              startTime, const Duration(milliseconds: 1300));

          state = state.copyWith(
            user: user, // Manter usuário armazenado
            biometricEnabled: biometricEnabled,
            isLoading: false,
            error: 'Erro de conexão. Verifique sua internet.',
          );

          if (kDebugMode) {
            print(
                '🔄 AuthProvider: Estado finalizado - usuário mantido por erro de conexão');
          }
        } else {
          // Outros erros - limpar dados
          if (kDebugMode) {
            print('🔄 AuthProvider: Limpando dados por erro de validação');
          }

          await AuthService.logout();

          // Garantir tempo mínimo de carregamento para UX
          await _ensureMinimumLoadingTime(
              startTime, const Duration(milliseconds: 1300));

          state = state.copyWith(
            user: null,
            biometricEnabled: false,
            isLoading: false,
          );

          if (kDebugMode) {
            print('🔄 AuthProvider: Estado finalizado - dados limpos');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔄 AuthProvider: Error loading stored user: $e');
      }

      // Garantir tempo mínimo de carregamento para UX
      await _ensureMinimumLoadingTime(
          startTime, const Duration(milliseconds: 1200));

      state = state.copyWith(
        user: null,
        isLoading: false,
        error: e.toString(),
      );

      if (kDebugMode) {
        print('🔄 AuthProvider: Estado finalizado - erro geral');
      }
    }
  }

  // Garantir tempo mínimo de carregamento para melhor UX
  Future<void> _ensureMinimumLoadingTime(
      DateTime startTime, Duration minimumTime) async {
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < minimumTime) {
      final remaining = minimumTime - elapsed;
      if (kDebugMode) {
        print(
            '🔄 AuthProvider: Aguardando tempo mínimo - restante: ${remaining.inMilliseconds}ms');
      }
      await Future.delayed(remaining);
    }

    // Adicionar delay adicional para garantir estado estável
    await Future.delayed(const Duration(milliseconds: 200));
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
        // Logs removed
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

  // Update user profile
  Future<void> updateUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedUser = await AuthService.updateUser(
        name: name,
        email: email,
        phone: phone,
      );
      state = state.copyWith(
        user: updatedUser,
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
      // Força uma verificação completa do status biométrico
      final biometricEnabled = await AuthService.isBiometricEnabled();

      // Atualiza o estado apenas se houver mudança
      if (state.biometricEnabled != biometricEnabled) {
        state = state.copyWith(biometricEnabled: biometricEnabled);
        if (kDebugMode) {
          print('Biometric status synced: $biometricEnabled');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing biometric status: $e');
      }
      // Em caso de erro, assume que a biometria está desabilitada
      if (state.biometricEnabled) {
        state = state.copyWith(biometricEnabled: false);
      }
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
