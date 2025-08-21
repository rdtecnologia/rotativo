import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

// Provider para o estado do formulário de registro
final registerFormProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>((ref) {
  return RegisterFormNotifier();
});

// Provider para a chave do formulário
final registerFormKeyProvider = Provider<GlobalKey<FormBuilderState>>((ref) {
  return GlobalKey<FormBuilderState>();
});

// Provider para acessar o notifier diretamente
final registerFormNotifierProvider = Provider<RegisterFormNotifier>((ref) {
  return ref.read(registerFormProvider.notifier);
});

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  RegisterFormNotifier() : super(const RegisterFormState());

  // Atualiza o estado de aceitação dos termos
  void setAcceptTerms(bool value) {
    state = state.copyWith(acceptTerms: value);
  }

  // Alterna o estado de aceitação dos termos
  void toggleAcceptTerms() {
    state = state.copyWith(acceptTerms: !state.acceptTerms);
  }

  // Valida se os termos foram aceitos
  bool validateTerms() {
    return state.acceptTerms;
  }

  // Limpa o estado do formulário
  void reset() {
    state = const RegisterFormState();
  }

  // Atualiza o estado de validação
  void setValidationError(String? error) {
    state = state.copyWith(validationError: error);
  }

  // Limpa o erro de validação
  void clearValidationError() {
    state = state.copyWith(validationError: null);
  }

  // Valida o formulário completo
  bool validateForm(GlobalKey<FormBuilderState> formKey) {
    if (!validateTerms()) {
      setValidationError('Você deve aceitar os termos de uso');
      return false;
    }

    if (formKey.currentState?.saveAndValidate() == true) {
      clearValidationError();
      return true;
    }

    return false;
  }
}

class RegisterFormState {
  final bool acceptTerms;
  final String? validationError;

  const RegisterFormState({
    this.acceptTerms = false,
    this.validationError,
  });

  RegisterFormState copyWith({
    bool? acceptTerms,
    String? validationError,
  }) {
    return RegisterFormState(
      acceptTerms: acceptTerms ?? this.acceptTerms,
      validationError: validationError ?? this.validationError,
    );
  }

  // Getter para verificar se há erro de validação
  bool get hasValidationError => validationError != null;

  // Getter para verificar se o formulário está válido
  bool get isFormValid => acceptTerms;
}
