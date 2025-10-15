import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_models.dart';
import '../models/vehicle_models.dart';
import '../services/history_service.dart';
import '../services/parking_notification_service.dart';
import 'alarm_settings_provider.dart';

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
  final Ref _ref;

  TimeUpdateNotifier(this._ref) : super(DateTime.now()) {
    _startTimer();
  }

  void _startTimer() {
    // Atualiza a cada minuto para sincronizar com as atualizações das ativações
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      state = DateTime.now();
      debugPrint(
          '🕐 TimeUpdateNotifier - Tempo atualizado: ${state.toString()}');

      // Executa verificação automática de notificações a cada minuto
      _checkAndScheduleNotificationsAutomatically();
    });
  }

  /// Verifica e agenda notificações automaticamente a cada minuto
  Future<void> _checkAndScheduleNotificationsAutomatically() async {
    try {
      debugPrint('🔔 === VERIFICAÇÃO AUTOMÁTICA A CADA MINUTO ===');

      // Obtém as ativações ativas e configurações de alarme
      final activeActivations = _ref.read(activeActivationsProvider);
      final alarmSettings = _ref.read(alarmSettingsProvider);

      // Log das configurações atuais
      debugPrint('📊 Configurações de Notificação:');
      debugPrint(
          '  - Notificações habilitadas: ${alarmSettings.localNotificationsEnabled}');
      debugPrint(
          '  - Vencimento de estacionamento: ${alarmSettings.parkingExpiration}');
      debugPrint(
          '  - Tempo de antecedência: ${alarmSettings.reminderMinutes} minutos');
      debugPrint('  - Som: ${alarmSettings.soundEnabled}');
      debugPrint('  - Vibração: ${alarmSettings.vibrationEnabled}');
      debugPrint('  - Luzes: ${alarmSettings.lightsEnabled}');

      // Log das ativações ativas
      debugPrint(
          '🚗 Veículos com Estacionamento Ativo (${activeActivations.length}):');

      if (activeActivations.isEmpty) {
        debugPrint('  - Nenhum veículo com estacionamento ativo');
        return;
      }

      // Verifica se as notificações estão habilitadas
      if (!alarmSettings.localNotificationsEnabled ||
          !alarmSettings.parkingExpiration) {
        debugPrint('⚠️ Notificações desabilitadas - pulando agendamento');
        return;
      }

      // Obtém o serviço de notificações
      final notificationService = _ref.read(parkingNotificationServiceProvider);

      // Para cada veículo ativo, mostra detalhes e agenda notificação
      for (final entry in activeActivations.entries) {
        final licensePlate = entry.key;
        final activation = entry.value;

        // Calcula tempos
        final expirationTime = activation.expiresAt ??
            activation.activatedAt
                .add(Duration(minutes: activation.parkingTime));
        final notificationTime = expirationTime
            .subtract(Duration(minutes: alarmSettings.reminderMinutes));
        final now = DateTime.now();

        debugPrint('  - $licensePlate:');
        debugPrint(
            '    - Status: ${activation.isActive ? "ativo" : "inativo"}');
        debugPrint(
            '    - Tempo de estacionamento: ${activation.parkingTime} minutos');
        debugPrint('    - Ativado em: ${activation.activatedAt}');
        debugPrint('    - Expira em: $expirationTime');
        debugPrint('    - Notificação agendada para: $notificationTime');
        debugPrint(
            '    - Tempo restante: ${activation.remainingMinutes} minutos');

        // Verifica se deve agendar notificação
        if (!activation.isActive) {
          debugPrint('    - ❌ Não agendando: estacionamento inativo');
          continue;
        }

        if (expirationTime.isBefore(now)) {
          debugPrint('    - ❌ Não agendando: estacionamento já expirou');
          continue;
        }

        if (notificationTime.isBefore(now)) {
          debugPrint('    - ❌ Não agendando: tempo de antecedência já passou');
          continue;
        }

        debugPrint(
            '    - ✅ Agendando notificação para ${alarmSettings.reminderMinutes} minutos antes da expiração');
      }

      // Executa o agendamento das notificações
      await notificationService.checkAndScheduleNotifications(
          activeActivations, alarmSettings);

      debugPrint('🔔 === FIM VERIFICAÇÃO AUTOMÁTICA ===');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro na verificação automática de notificações: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      // Não relança o erro para não quebrar o timer
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider global para atualizações de tempo
final timeUpdateProvider = StateNotifierProvider<TimeUpdateNotifier, DateTime>(
  (ref) => TimeUpdateNotifier(ref),
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
