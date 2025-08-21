import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado da tela de alterar senha
class ChangePasswordState {
  final bool isLoading;
  final bool obscureCurrentPassword;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final String? error;
  final String? currentPassword;
  final String? newPassword;
  final String? confirmPassword;

  const ChangePasswordState({
    this.isLoading = false,
    this.obscureCurrentPassword = true,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
    this.error,
    this.currentPassword,
    this.newPassword,
    this.confirmPassword,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? obscureCurrentPassword,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    String? error,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      obscureCurrentPassword:
          obscureCurrentPassword ?? this.obscureCurrentPassword,
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      error: clearError ? null : (error ?? this.error),
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

// Provider para o estado da tela de alterar senha
final changePasswordProvider =
    StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
  return ChangePasswordNotifier();
});

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  ChangePasswordNotifier() : super(const ChangePasswordState());

  // Alternar visibilidade da senha atual
  void toggleCurrentPasswordVisibility() {
    state = state.copyWith(
      obscureCurrentPassword: !state.obscureCurrentPassword,
    );
  }

  // Alternar visibilidade da nova senha
  void toggleNewPasswordVisibility() {
    state = state.copyWith(
      obscureNewPassword: !state.obscureNewPassword,
    );
  }

  // Alternar visibilidade da confirmação de senha
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  // Atualizar valores dos campos
  void updateCurrentPassword(String password) {
    state = state.copyWith(currentPassword: password);
  }

  void updateNewPassword(String password) {
    state = state.copyWith(newPassword: password);
  }

  void updateConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password);
  }

  // Definir estado de carregamento
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Definir erro
  void setError(String error) {
    state = state.copyWith(error: error);
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Resetar estado para valores padrão
  void reset() {
    state = const ChangePasswordState();
  }

  // Validar se as senhas coincidem
  bool get passwordsMatch => state.newPassword == state.confirmPassword;
}
