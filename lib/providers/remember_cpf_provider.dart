import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Estado para "Lembrar meu CPF"
class RememberCpfState {
  final bool rememberCpf;
  final String? savedCpf;

  const RememberCpfState({
    this.rememberCpf = false,
    this.savedCpf,
  });

  RememberCpfState copyWith({
    bool? rememberCpf,
    String? savedCpf,
  }) {
    return RememberCpfState(
      rememberCpf: rememberCpf ?? this.rememberCpf,
      savedCpf: savedCpf ?? this.savedCpf,
    );
  }
}

/// Provider para gerenciar o estado de "Lembrar meu CPF"
class RememberCpfNotifier extends StateNotifier<RememberCpfState> {
  RememberCpfNotifier() : super(const RememberCpfState());

  /// Inicializa o estado carregando as preferências salvas
  Future<void> initialize() async {
    final rememberCpf = await AuthService.getRememberCpfPreference();
    final savedCpf = rememberCpf ? await AuthService.getSavedCpf() : null;
    
    state = state.copyWith(
      rememberCpf: rememberCpf,
      savedCpf: savedCpf,
    );
  }

  /// Alterna o estado do checkbox
  Future<void> toggleRememberCpf(bool value) async {
    await AuthService.setRememberCpfPreference(value);
    state = state.copyWith(rememberCpf: value);
  }

  /// Salva o CPF no secure storage
  Future<void> saveCpf(String cpf) async {
    await AuthService.saveCpf(cpf);
    state = state.copyWith(savedCpf: cpf);
  }

  /// Limpa o CPF salvo (não usado por enquanto, mas útil para futuro)
  Future<void> clearCpf() async {
    await AuthService.clearSavedCpf();
    state = state.copyWith(savedCpf: null);
  }
}

/// Provider do notificador
final rememberCpfProvider =
    StateNotifierProvider<RememberCpfNotifier, RememberCpfState>((ref) {
  return RememberCpfNotifier();
});
