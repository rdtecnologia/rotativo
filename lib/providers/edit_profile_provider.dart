import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_models.dart';

// Estado da edição de perfil
class EditProfileState {
  final bool isLoading;
  final String? error;
  final bool isFormValid;
  final Map<String, dynamic> formData;
  final User? originalUser;

  const EditProfileState({
    this.isLoading = false,
    this.error,
    this.isFormValid = false,
    this.formData = const {},
    this.originalUser,
  });

  EditProfileState copyWith({
    bool? isLoading,
    String? error,
    bool? isFormValid,
    Map<String, dynamic>? formData,
    User? originalUser,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFormValid: isFormValid ?? this.isFormValid,
      formData: formData ?? this.formData,
      originalUser: originalUser ?? this.originalUser,
    );
  }
}

// Notifier para gerenciar o estado da edição de perfil
class EditProfileNotifier extends StateNotifier<EditProfileState> {
  EditProfileNotifier() : super(const EditProfileState());

  // Inicializa o estado com os dados do usuário
  void initializeWithUser(User user) {
    state = state.copyWith(
      originalUser: user,
      formData: {
        'name': user.name ?? '',
        'email': user.email ?? '',
        'cpf': user.cpf ?? '',
        'phone': user.phone ?? '',
      },
      isFormValid: true,
    );
  }

  // Atualiza um campo específico do formulário
  void updateField(String field, String value) {
    final newFormData = Map<String, dynamic>.from(state.formData);
    newFormData[field] = value;

    state = state.copyWith(
      formData: newFormData,
      error: null, // Limpa erro ao editar
    );
  }

  // Valida o formulário
  void validateForm() {
    final formData = state.formData;
    final isValid = formData['name']?.toString().trim().isNotEmpty == true &&
        formData['email']?.toString().trim().isNotEmpty == true &&
        formData['phone']?.toString().trim().isNotEmpty == true;

    state = state.copyWith(isFormValid: isValid);
  }

  // Define o estado de carregamento
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Define um erro
  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  // Limpa o erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reseta o estado para os valores originais
  void resetToOriginal() {
    if (state.originalUser != null) {
      initializeWithUser(state.originalUser!);
    }
  }

  // Obtém os dados do formulário para envio
  Map<String, dynamic> getFormDataForSubmission() {
    return {
      'name': state.formData['name']?.toString().trim(),
      'email': state.formData['email']?.toString().trim(),
      'phone': state.formData['phone']?.toString().trim(),
    };
  }
}

// Provider principal
final editProfileProvider =
    StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  return EditProfileNotifier();
});

// Providers específicos para otimizar rebuilds
final editProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(editProfileProvider).isLoading;
});

final editProfileErrorProvider = Provider<String?>((ref) {
  return ref.watch(editProfileProvider).error;
});

final editProfileFormDataProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(editProfileProvider).formData;
});

final editProfileFormValidProvider = Provider<bool>((ref) {
  return ref.watch(editProfileProvider).isFormValid;
});

final editProfileNotifierProvider = Provider<EditProfileNotifier>((ref) {
  return ref.read(editProfileProvider.notifier);
});
