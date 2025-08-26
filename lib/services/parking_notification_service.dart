import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_models.dart';
import '../providers/active_activations_provider.dart';
import '../providers/alarm_settings_provider.dart';
import 'local_notification_service.dart';
import 'dart:async';

/// Serviço para gerenciar notificações de estacionamento
class ParkingNotificationService {
  static final ParkingNotificationService _instance =
      ParkingNotificationService._internal();
  factory ParkingNotificationService() => _instance;
  ParkingNotificationService._internal();

  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  /// Inicializa o serviço
  Future<void> initialize() async {
    await _localNotificationService.initialize();
  }

  /// Agenda notificações para todas as ativações ativas
  Future<void> scheduleNotificationsForActiveActivations(
    Map<String, ActivationHistory> activations,
    AlarmSettings settings,
  ) async {
    if (!settings.localNotificationsEnabled) {
      debugPrint('🔔 Notificações locais desabilitadas');
      return;
    }

    for (final entry in activations.entries) {
      final activation = entry.value;

      if (activation.isActive) {
        await _scheduleNotificationForActivation(activation, settings);
      }
    }
  }

  /// Agenda notificação para uma ativação específica
  Future<void> _scheduleNotificationForActivation(
    ActivationHistory activation,
    AlarmSettings settings,
  ) async {
    if (!settings.parkingExpiration) {
      debugPrint(
          '🔔 Notificações de vencimento desabilitadas para ${activation.licensePlate}');
      return;
    }

    // Calcula o horário de expiração
    final expirationTime = activation.expiresAt ??
        activation.activatedAt.add(Duration(minutes: activation.parkingTime));

    // Agenda a notificação
    await _localNotificationService.scheduleParkingExpirationNotification(
      licensePlate: activation.licensePlate,
      expirationTime: expirationTime,
      reminderMinutes: settings.reminderMinutes,
      location: activation.location,
      soundEnabled: settings.soundEnabled,
      vibrationEnabled: settings.vibrationEnabled,
      lightsEnabled: settings.lightsEnabled,
    );

    debugPrint(
        '🔔 Notificação agendada para ${activation.licensePlate} às ${expirationTime.toString()}');
  }

  /// Cancela notificações para um veículo específico
  Future<void> cancelNotificationsForVehicle(String licensePlate) async {
    await _localNotificationService.cancelVehicleNotifications(licensePlate);
    debugPrint('🔔 Notificações canceladas para $licensePlate');
  }

  /// Cancela todas as notificações de estacionamento
  Future<void> cancelAllParkingNotifications() async {
    await _localNotificationService.cancelAllNotifications();
    debugPrint('🔔 Todas as notificações de estacionamento foram canceladas');
  }

  /// Atualiza notificações quando as configurações mudam
  Future<void> updateNotificationsOnSettingsChange(
    Map<String, ActivationHistory> activations,
    AlarmSettings settings,
  ) async {
    // Cancela todas as notificações existentes
    await cancelAllParkingNotifications();

    // Agenda novas notificações com as configurações atualizadas
    await scheduleNotificationsForActiveActivations(activations, settings);
  }

  /// Verifica se há ativações próximas de expirar e agenda notificações
  Future<void> checkAndScheduleNotifications(
    Map<String, ActivationHistory> activations,
    AlarmSettings settings,
  ) async {
    if (!settings.localNotificationsEnabled || !settings.parkingExpiration) {
      debugPrint('🔔 Notificações desabilitadas ou configurações inválidas');
      return;
    }

    debugPrint(
        '🔔 Verificando ${activations.length} ativações para agendar notificações');

    for (final entry in activations.entries) {
      final activation = entry.value;

      if (!activation.isActive) {
        debugPrint(
            '🔔 Ativação ${activation.licensePlate} não está ativa, pulando...');
        continue;
      }

      // Agenda notificação imediatamente para ativações ativas
      await _scheduleNotificationForActivation(activation, settings);
    }
  }
}

/// Provider para o serviço de notificações de estacionamento
final parkingNotificationServiceProvider =
    Provider<ParkingNotificationService>((ref) {
  return ParkingNotificationService();
});

/// Widget para monitorar ativações e agendar notificações automaticamente
class ParkingNotificationMonitor extends ConsumerStatefulWidget {
  final Widget child;

  const ParkingNotificationMonitor({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ParkingNotificationMonitor> createState() =>
      _ParkingNotificationMonitorState();
}

class _ParkingNotificationMonitorState
    extends ConsumerState<ParkingNotificationMonitor> {
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    // Verifica a cada 5 minutos para garantir que notificações sejam agendadas
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAndScheduleNotifications();
    });
  }

  Future<void> _checkAndScheduleNotifications() async {
    final activeActivations = ref.read(activeActivationsProvider);
    final alarmSettings = ref.read(alarmSettingsProvider);

    if (mounted) {
      final notificationService = ref.read(parkingNotificationServiceProvider);
      await notificationService.checkAndScheduleNotifications(
          activeActivations, alarmSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa mudanças nas ativações ativas
    final activeActivations = ref.watch(activeActivationsProvider);

    // Observa mudanças nas configurações de alarme
    final alarmSettings = ref.watch(alarmSettingsProvider);

    // Agenda notificações quando há mudanças
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final notificationService =
            ref.read(parkingNotificationServiceProvider);
        await notificationService.checkAndScheduleNotifications(
            activeActivations, alarmSettings);
      }
    });

    return widget.child;
  }
}
