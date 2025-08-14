import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_models.dart';
import '../models/vehicle_models.dart';
import '../services/history_service.dart';

class ActiveActivationsNotifier extends StateNotifier<Map<String, ActivationHistory>> {
  Timer? _timer;
  
  ActiveActivationsNotifier() : super({}) {
    // Inicia o timer para atualizar a cada segundo
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Força rebuild para atualizar os timers
      state = Map.from(state);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Carrega as ativações ativas para um veículo específico
  Future<void> loadActiveActivationForVehicle(Vehicle vehicle) async {
    try {
      debugPrint('🅿️ ActiveActivationsProvider - Carregando ativações para ${vehicle.licensePlate}');
      
      // Busca ativações para o veículo específico (sem filtro de status)
      final activations = await HistoryService.getActivations(
        filters: {
          'licensePlate': vehicle.licensePlate,
        },
      );

      debugPrint('🅿️ ActiveActivationsProvider - Encontradas ${activations.length} ativações para ${vehicle.licensePlate}');

      // Filtra ativações que ainda estão ativas OU foram ativadas nas últimas 24 horas
      final activeActivations = activations.where((activation) {
        final isActive = activation.isActive;
        final isRecent = DateTime.now().difference(activation.activatedAt).inHours < 24;
        final shouldShow = isActive || isRecent;
        
        debugPrint('🅿️ ActiveActivationsProvider - Ativação ${activation.id}: isActive=$isActive, isRecent=$isRecent, shouldShow=$shouldShow, activatedAt=${activation.activatedAt}, parkingTime=${activation.parkingTime}');
        
        return shouldShow;
      }).toList();
      
      debugPrint('🅿️ ActiveActivationsProvider - ${activeActivations.length} ativações ativas para ${vehicle.licensePlate}');
      
      if (activeActivations.isNotEmpty) {
        // Pega a ativação mais recente (última ativada)
        final mostRecent = activeActivations.reduce((a, b) => 
          a.activatedAt.isAfter(b.activatedAt) ? a : b
        );
        
        debugPrint('🅿️ ActiveActivationsProvider - Ativação mais recente: ${mostRecent.id}, tempo restante: ${mostRecent.remainingMinutes}min');
        
        state = {
          ...state,
          vehicle.licensePlate: mostRecent,
        };
      } else {
        // Remove o veículo do estado se não há ativação ativa
        final newState = Map<String, ActivationHistory>.from(state);
        newState.remove(vehicle.licensePlate);
        state = newState;
        debugPrint('🅿️ ActiveActivationsProvider - Nenhuma ativação ativa para ${vehicle.licensePlate}, removido do estado');
      }
    } catch (e) {
      debugPrint('🚨 ActiveActivationsProvider - Erro ao carregar ativação ativa para ${vehicle.licensePlate}: $e');
    }
  }

  /// Carrega ativações ativas para todos os veículos
  Future<void> loadActiveActivationsForVehicles(List<Vehicle> vehicles) async {
    debugPrint('🅿️ ActiveActivationsProvider - Carregando ativações para ${vehicles.length} veículos');
    for (final vehicle in vehicles) {
      await loadActiveActivationForVehicle(vehicle);
    }
    debugPrint('🅿️ ActiveActivationsProvider - Finalizado carregamento para todos os veículos. Estado atual: ${state.keys.join(', ')}');
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

final activeActivationsProvider = StateNotifierProvider<ActiveActivationsNotifier, Map<String, ActivationHistory>>(
  (ref) => ActiveActivationsNotifier(),
);

/// Provider para obter a ativação ativa de um veículo específico
final vehicleActiveActivationProvider = Provider.family<ActivationHistory?, Vehicle>(
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
