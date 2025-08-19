import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../config/environment.dart';

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadStoredUser();
  }

  // Load stored user on app start
  Future<void> _loadStoredUser() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await AuthService.getStoredUser();
      if (user != null && user.token != null) {
        // Verify if token is still valid by fetching current user
        try {
          final currentUser = await AuthService.getCurrentUser();
          state = state.copyWith(
            user: currentUser,
            isLoading: false,
          );
        } catch (e) {
          // Token invalid, clear stored data
          await AuthService.logout();
          state = state.copyWith(
            user: null,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
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
        print('🔄 AuthProvider: Starting logout process...');
      }
      
      // Clear stored data
      await AuthService.logout();
      
      // Clear state completely
      state = const AuthState();
      
      if (kDebugMode) {
        print('🔄 AuthProvider: Logout completed successfully');
        print('🔄 AuthProvider: Current state - user: ${state.user}, isAuthenticated: ${state.isAuthenticated}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthProvider: Error during logout: $e');
      }
      
      // Even if there's an error, clear the state
      state = const AuthState();
      
      if (kDebugMode) {
        print('🔄 AuthProvider: State cleared after error');
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