import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_activations_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/vehicle_provider.dart';

/// Provider para gerenciar o estado da tela home
class HomeScreenNotifier extends StateNotifier<HomeScreenState> {
  HomeScreenNotifier(this.ref) : super(HomeScreenState.initial());

  final Ref ref;

  /// Carrega todos os dados necessários para a tela home
  Future<void> loadAllData() async {
    if (state.isLoading) return; // Evita múltiplas chamadas simultâneas

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Carrega veículos primeiro
      await ref.read(vehicleProvider.notifier).loadVehicles();

      // Carrega saldo
      ref.read(balanceProvider.notifier).loadBalance();

      // Carrega ativações ativas para todos os veículos
      await _loadActiveActivations();

      state = state.copyWith(
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Atualiza apenas o saldo e ativações (sem recarregar veículos)
  Future<void> updateBalanceAndActivations() async {
    try {
      // Atualiza saldo
      ref.read(balanceProvider.notifier).loadBalance();

      // Atualiza ativações ativas
      await _loadActiveActivations();

      state = state.copyWith(
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  /// Carrega as ativações ativas para todos os veículos
  Future<void> _loadActiveActivations() async {
    final vehicleState = ref.read(vehicleProvider);
    if (vehicleState.vehicles.isNotEmpty) {
      await ref
          .read(activeActivationsProvider.notifier)
          .loadActiveActivationsForVehicles(vehicleState.vehicles);
    }
  }

  /// Limpa erros
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Força refresh completo
  Future<void> refresh() async {
    await loadAllData();
  }
}

/// Estado da tela home
class HomeScreenState {
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const HomeScreenState({
    required this.isLoading,
    this.error,
    this.lastUpdated,
  });

  factory HomeScreenState.initial() => const HomeScreenState(
        isLoading: false,
        error: null,
        lastUpdated: null,
      );

  HomeScreenState copyWith({
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return HomeScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeScreenState &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^ error.hashCode ^ lastUpdated.hashCode;
}

/// Provider principal da tela home
final homeScreenProvider =
    StateNotifierProvider<HomeScreenNotifier, HomeScreenState>(
  (ref) => HomeScreenNotifier(ref),
);

/// Provider para verificar se deve mostrar loading
final homeScreenLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeScreenProvider).isLoading;
});

/// Provider para verificar se há erro
final homeScreenErrorProvider = Provider<String?>((ref) {
  return ref.watch(homeScreenProvider).error;
});

/// Provider para verificar quando foi a última atualização
final homeScreenLastUpdatedProvider = Provider<DateTime?>((ref) {
  return ref.watch(homeScreenProvider).lastUpdated;
});
