import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_models.dart';
import '../models/vehicle_models.dart';
import '../services/history_service.dart';

class ActiveActivationsNotifier
    extends StateNotifier<Map<String, ActivationHistory>> {
  Timer? _dataUpdateTimer;

  ActiveActivationsNotifier() : super({}) {
    // Inicia o timer para atualizar dados a cada minuto
    _startDataUpdateTimer();
  }

  void _startDataUpdateTimer() {
    _dataUpdateTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) async {
      // Atualiza os dados das ativações a cada minuto
      await _updateActiveActivationsData();
    });
  }

  /// Atualiza os dados das ativações ativas
  Future<void> _updateActiveActivationsData() async {
    try {
      debugPrint(
          '🔄 ActiveActivationsProvider - Atualizando dados das ativações a cada minuto');

      // Se não há ativações no estado, não precisa atualizar
      if (state.isEmpty) return;

      // Para cada ativação ativa, verifica se ainda está válida
      final currentState = Map<String, ActivationHistory>.from(state);
      final updatedState = <String, ActivationHistory>{};
      bool hasChanges = false;

      for (final entry in currentState.entries) {
        final licensePlate = entry.key;
        final activation = entry.value;

        // Se a ativação expirou, remove do estado
        if (!activation.isActive) {
          hasChanges = true;
          debugPrint(
              '🔄 ActiveActivationsProvider - Removendo ativação expirada para $licensePlate');
          continue;
        }

        // Se ainda está ativa, mantém no estado
        updatedState[licensePlate] = activation;
      }

      // Se houve mudanças, atualiza o estado
      if (hasChanges || updatedState.length != currentState.length) {
        state = updatedState;
        debugPrint(
            '🔄 ActiveActivationsProvider - Estado atualizado: ${updatedState.keys.join(', ')}');
      }
    } catch (e) {
      debugPrint(
          '🚨 ActiveActivationsProvider - Erro ao atualizar dados das ativações: $e');
    }
  }

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  /// Carrega as ativações ativas para um veículo específico
  Future<void> loadActiveActivationForVehicle(Vehicle vehicle) async {
    try {
      debugPrint(
          '🅿️ ActiveActivationsProvider - Carregando ativações para ${vehicle.licensePlate}');

      // Busca ativações para o veículo específico (sem filtro de status)
      final activations = await HistoryService.getActivations(
        filters: {
          'licensePlate': vehicle.licensePlate,
        },
      );

      debugPrint(
          '🅿️ ActiveActivationsProvider - Encontradas ${activations.length} ativações para ${vehicle.licensePlate}');

      if (activations.isNotEmpty) {
        // SEMPRE pega a ativação mais recente, independentemente do status
        final mostRecent = activations
            .reduce((a, b) => a.activatedAt.isAfter(b.activatedAt) ? a : b);

        debugPrint(
            '🅿️ ActiveActivationsProvider - Ativação mais recente: ${mostRecent.id}, tempo restante: ${mostRecent.remainingMinutes}min, isActive: ${mostRecent.isActive}');

        state = {
          ...state,
          vehicle.licensePlate: mostRecent,
        };
      } else {
        // Remove o veículo do estado se não há ativação
        final newState = Map<String, ActivationHistory>.from(state);
        newState.remove(vehicle.licensePlate);
        state = newState;
        debugPrint(
            '🅿️ ActiveActivationsProvider - Nenhuma ativação para ${vehicle.licensePlate}, removido do estado');
      }
    } catch (e) {
      debugPrint(
          '🚨 ActiveActivationsProvider - Erro ao carregar ativação ativa para ${vehicle.licensePlate}: $e');
    }
  }

  /// Carrega ativações ativas para todos os veículos
  Future<void> loadActiveActivationsForVehicles(List<Vehicle> vehicles) async {
    debugPrint(
        '🅿️ ActiveActivationsProvider - Carregando ativações para ${vehicles.length} veículos');
    for (final vehicle in vehicles) {
      await loadActiveActivationForVehicle(vehicle);
    }
    debugPrint(
        '🅿️ ActiveActivationsProvider - Finalizado carregamento para todos os veículos. Estado atual: ${state.keys.join(', ')}');
  }

  /// Remove uma ativação quando ela expira
  void removeExpiredActivation(String licensePlate) {
    final newState = Map<String, ActivationHistory>.from(state);
    newState.remove(licensePlate);
    state = newState;
  }

  /// Atualiza uma ativação específica
  void updateActivation(String licensePlate, ActivationHistory activation) {
    state = {
      ...state,
      licensePlate: activation,
    };
  }

  /// Limpa todas as ativações
  void clearAll() {
    state = {};
  }
}

final activeActivationsProvider = StateNotifierProvider<
    ActiveActivationsNotifier, Map<String, ActivationHistory>>(
  (ref) => ActiveActivationsNotifier(),
);

/// Provider para obter a ativação ativa de um veículo específico
final vehicleActiveActivationProvider =
    Provider.family<ActivationHistory?, Vehicle>(
  (ref, vehicle) {
    final activeActivations = ref.watch(activeActivationsProvider);
    return activeActivations[vehicle.licensePlate];
  },
);

/// Provider para verificar se um veículo tem estacionamento ativo
final hasActiveParkingProvider = Provider.family<bool, Vehicle>(
  (ref, vehicle) {
    final activeActivations = ref.watch(activeActivationsProvider);
    return activeActivations.containsKey(vehicle.licensePlate);
  },
);

/// Provider global para gerenciar atualizações de tempo
/// Este provider pode ser usado por todo o app para notificações e outras funcionalidades
class TimeUpdateNotifier extends StateNotifier<DateTime> {
  Timer? _timer;

  TimeUpdateNotifier() : super(DateTime.now()) {
    _startTimer();
  }

  void _startTimer() {
    // Atualiza a cada minuto para sincronizar com as atualizações das ativações
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      state = DateTime.now();
      debugPrint(
          '🕐 TimeUpdateNotifier - Tempo atualizado: ${state.toString()}');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider global para atualizações de tempo
final timeUpdateProvider = StateNotifierProvider<TimeUpdateNotifier, DateTime>(
  (ref) => TimeUpdateNotifier(),
);

/// Provider para obter ativações que estão próximas de expirar (últimos 15 minutos)
final expiringSoonActivationsProvider =
    Provider<List<ActivationHistory>>((ref) {
  final activeActivations = ref.watch(activeActivationsProvider);

  return activeActivations.values.where((activation) {
    if (!activation.isActive) return false;

    final remainingMinutes = activation.remainingMinutes;
    // Retorna ativações que expiram em 15 minutos ou menos
    return remainingMinutes <= 15 && remainingMinutes > 0;
  }).toList();
});

/// Provider para obter ativações que expiraram recentemente (últimos 5 minutos)
final recentlyExpiredActivationsProvider =
    Provider<List<ActivationHistory>>((ref) {
  final activeActivations = ref.watch(activeActivationsProvider);

  return activeActivations.values.where((activation) {
    if (activation.isActive) return false;

    final expirationTime = activation.expiresAt ??
        activation.activatedAt.add(Duration(minutes: activation.parkingTime));
    final minutesSinceExpiration =
        DateTime.now().difference(expirationTime).inMinutes;

    // Retorna ativações que expiraram há 5 minutos ou menos
    return minutesSinceExpiration <= 5 && minutesSinceExpiration >= 0;
  }).toList();
});
