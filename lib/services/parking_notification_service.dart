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

    // Verifica se a ativação ainda não expirou
    if (expirationTime.isBefore(DateTime.now())) {
      debugPrint(
          '🔔 Ativação ${activation.licensePlate} já expirou, não agendando notificação');
      return;
    }

    // Verifica se o tempo de antecedência é válido
    final notificationTime =
        expirationTime.subtract(Duration(minutes: settings.reminderMinutes));
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint(
          '🔔 Tempo de antecedência (${settings.reminderMinutes}min) já passou para ${activation.licensePlate}, não agendando notificação');
      return;
    }

    // Agenda a notificação
    try {
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
          '✅ Notificação agendada com sucesso para ${activation.licensePlate} às ${expirationTime.toString()} (${settings.reminderMinutes}min antes)');
    } catch (e) {
      debugPrint(
          '❌ ERRO ao agendar notificação para ${activation.licensePlate}: $e');
      debugPrint(
          '💡 Detalhes: expirationTime=$expirationTime, reminderMinutes=${settings.reminderMinutes}');

      // Re-lança o erro para que possa ser tratado em nível superior se necessário
      rethrow;
    }
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

  /// Cancela apenas notificações de estacionamento real, preserva testes
  Future<void> cancelOnlyParkingNotifications() async {
    await _localNotificationService.cancelOnlyParkingNotifications();
    debugPrint(
        '🔔 Notificações de estacionamento real canceladas (testes preservados)');
  }

  /// Testa o agendamento de notificações com tempo específico
  Future<void> testNotificationTiming({
    required String licensePlate,
    required int minutesFromNow,
    required int reminderMinutes,
  }) async {
    debugPrint(
        '🧪 Testando notificação para $licensePlate em $minutesFromNow minutos');

    final testExpirationTime =
        DateTime.now().add(Duration(minutes: minutesFromNow));

    await _localNotificationService.scheduleParkingExpirationNotification(
      licensePlate: licensePlate,
      expirationTime: testExpirationTime,
      reminderMinutes: reminderMinutes,
      location: 'Local de Teste',
      soundEnabled: true,
      vibrationEnabled: true,
      lightsEnabled: true,
    );

    debugPrint('🧪 Notificação de teste agendada:');
    debugPrint('  - Placa: $licensePlate');
    debugPrint('  - Expira em: ${testExpirationTime.toString()}');
    debugPrint('  - Notificação em: $reminderMinutes minutos antes');
    debugPrint(
        '  - Horário da notificação: ${testExpirationTime.subtract(Duration(minutes: reminderMinutes)).toString()}');

    // Listar notificações pendentes após agendar
    await Future.delayed(const Duration(seconds: 1));
    await _localNotificationService.debugPendingNotifications();
  }

  /// Debug: Lista todas as notificações pendentes
  Future<void> debugAllPendingNotifications() async {
    await _localNotificationService.debugPendingNotifications();
  }

  /// Debug: Verifica o estado atual das ativações e configurações
  Future<void> debugCurrentState(
    Map<String, ActivationHistory> activations,
    AlarmSettings settings,
  ) async {
    debugPrint('🔍 === DEBUG ESTADO ATUAL ===');
    debugPrint('📊 Configurações:');
    debugPrint(
        '  - Notificações locais: ${settings.localNotificationsEnabled}');
    debugPrint(
        '  - Vencimento de estacionamento: ${settings.parkingExpiration}');
    debugPrint('  - Minutos de antecedência: ${settings.reminderMinutes}');
    debugPrint('  - Som: ${settings.soundEnabled}');
    debugPrint('  - Vibração: ${settings.vibrationEnabled}');
    debugPrint('  - Luzes: ${settings.lightsEnabled}');

    debugPrint('🚗 Ativações (${activations.length}):');
    for (final entry in activations.entries) {
      final activation = entry.value;
      final expirationTime = activation.expiresAt ??
          activation.activatedAt.add(Duration(minutes: activation.parkingTime));
      final notificationTime =
          expirationTime.subtract(Duration(minutes: settings.reminderMinutes));

      debugPrint('  - ${activation.licensePlate}:');
      debugPrint('    - Ativa: ${activation.isActive}');
      debugPrint('    - Expira em: $expirationTime');
      debugPrint('    - Notificação em: $notificationTime');
      debugPrint(
          '    - Já expirou: ${expirationTime.isBefore(DateTime.now())}');
      debugPrint(
          '    - Notificação já passou: ${notificationTime.isBefore(DateTime.now())}');
    }

    debugPrint('🔍 === FIM DEBUG ESTADO ===');
  }

  /// Atualiza notificações quando as configurações mudam
  Future<void> updateNotificationsOnSettingsChange(
    Map<String, ActivationHistory> activations,
    AlarmSettings settings,
  ) async {
    debugPrint('🔄 === REAGENDANDO POR MUDANÇA DE CONFIGURAÇÕES ===');
    debugPrint('🔄 Configurações atualizadas:');
    debugPrint('  - Antecedência: ${settings.reminderMinutes} minutos');
    debugPrint('  - Som: ${settings.soundEnabled}');
    debugPrint('  - Vibração: ${settings.vibrationEnabled}');
    debugPrint('  - Luzes: ${settings.lightsEnabled}');

    // ✅ CORREÇÃO: Cancela apenas notificações de estacionamento real, preserva testes
    await cancelOnlyParkingNotifications();

    // Agenda novas notificações com as configurações atualizadas
    await scheduleNotificationsForActiveActivations(activations, settings);

    debugPrint('🔄 === FIM REAGENDAMENTO ===');
  }

  /// Força reagendamento imediato (útil para testes)
  Future<void> forceRescheduleNotifications() async {
    debugPrint('🔄 === FORÇANDO REAGENDAMENTO IMEDIATO ===');
    // Este método pode ser chamado da UI para forçar reagendamento
    // Será implementado no provider se necessário
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

    // ✅ CORREÇÃO: Cancela apenas notificações de estacionamento real, preserva testes
    await cancelOnlyParkingNotifications();

    for (final entry in activations.entries) {
      final activation = entry.value;

      if (!activation.isActive) {
        debugPrint(
            '🔔 Ativação ${activation.licensePlate} não está ativa, pulando...');
        continue;
      }

      // Calcula o horário de expiração
      final expirationTime = activation.expiresAt ??
          activation.activatedAt.add(Duration(minutes: activation.parkingTime));

      // Só agenda notificação se ainda não expirou
      if (expirationTime.isAfter(DateTime.now())) {
        try {
          await _scheduleNotificationForActivation(activation, settings);
        } catch (e) {
          debugPrint(
              '❌ ERRO CRÍTICO ao agendar notificação para ${activation.licensePlate}: $e');
        }
      } else {
        debugPrint(
            '🔔 Ativação ${activation.licensePlate} já expirou, não agendando notificação');
      }
    }

    // Debug: Listar todas as notificações pendentes após processamento
    debugPrint('🔔 === RESUMO FINAL ===');
    await _localNotificationService.debugPendingNotifications();
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
  Map<String, ActivationHistory>? _lastScheduledActivations;
  AlarmSettings? _lastScheduledSettings;

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
    // Verifica a cada 5 minutos como backup do sistema principal
    // O TimeUpdateNotifier já faz verificação a cada minuto
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAndScheduleNotifications();
    });
  }

  Future<void> _checkAndScheduleNotifications() async {
    try {
      if (!mounted) return;

      final activeActivations = ref.read(activeActivationsProvider);
      final alarmSettings = ref.read(alarmSettingsProvider);

      debugPrint(
          '🔔 Timer periódico (backup): Aplicando configurações atuais...');
      final notificationService = ref.read(parkingNotificationServiceProvider);
      await notificationService.checkAndScheduleNotifications(
          activeActivations, alarmSettings);

      // Atualiza o estado para refletir as configurações aplicadas
      _lastScheduledActivations = Map.from(activeActivations);
      _lastScheduledSettings = alarmSettings;
    } catch (e, stackTrace) {
      debugPrint('❌ Erro no timer periódico de backup: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      // Não relança o erro para não quebrar o timer
    }
  }

  /// Verifica se as ativações ou configurações mudaram significativamente
  bool _hasSignificantChanges(
    Map<String, ActivationHistory> currentActivations,
    AlarmSettings currentSettings,
  ) {
    // Se é a primeira vez, sempre agenda
    if (_lastScheduledActivations == null || _lastScheduledSettings == null) {
      return true;
    }

    // Verifica se o número de ativações mudou
    if (currentActivations.length != _lastScheduledActivations!.length) {
      return true;
    }

    // ✅ CORREÇÃO: Reagir a mudanças críticas de configuração
    // Verifica se as notificações foram desabilitadas
    if (!currentSettings.localNotificationsEnabled ||
        !currentSettings.parkingExpiration) {
      // Se as notificações foram desabilitadas, cancela todas
      return true;
    }

    // ✅ NOVA FUNCIONALIDADE: Reagir a mudanças no tempo de antecedência
    if (_lastScheduledSettings!.reminderMinutes !=
        currentSettings.reminderMinutes) {
      debugPrint(
          '🔔 Mudança detectada no tempo de antecedência: ${_lastScheduledSettings!.reminderMinutes}min → ${currentSettings.reminderMinutes}min');
      return true;
    }

    // Reagir a mudanças em configurações de som/vibração/luzes
    if (_lastScheduledSettings!.soundEnabled != currentSettings.soundEnabled ||
        _lastScheduledSettings!.vibrationEnabled !=
            currentSettings.vibrationEnabled ||
        _lastScheduledSettings!.lightsEnabled !=
            currentSettings.lightsEnabled) {
      debugPrint(
          '🔔 Mudança detectada nas configurações de som/vibração/luzes');
      return true;
    }

    // Verifica se alguma ativação mudou de estado ou tempo
    for (final entry in currentActivations.entries) {
      final current = entry.value;
      final last = _lastScheduledActivations![entry.key];

      if (last == null ||
          current.isActive != last.isActive ||
          current.expiresAt != last.expiresAt ||
          current.parkingTime != last.parkingTime) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Observa mudanças nas ativações ativas
    final activeActivations = ref.watch(activeActivationsProvider);

    // Observa mudanças nas configurações de alarme
    final alarmSettings = ref.watch(alarmSettingsProvider);

    // ✅ Agenda notificações quando há mudanças significativas nas ATIVAÇÕES ou CONFIGURAÇÕES
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (mounted &&
            _hasSignificantChanges(activeActivations, alarmSettings)) {
          debugPrint(
              '🔔 Mudanças significativas detectadas, reagendando notificações...');

          final notificationService =
              ref.read(parkingNotificationServiceProvider);
          await notificationService.checkAndScheduleNotifications(
              activeActivations, alarmSettings);

          // Atualiza o estado para evitar agendamento duplicado
          _lastScheduledActivations = Map.from(activeActivations);
          _lastScheduledSettings = alarmSettings;
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Erro no callback de mudanças: $e');
        debugPrint('📍 Stack trace: $stackTrace');
        // Não relança o erro para não quebrar a UI
      }
    });

    return widget.child;
  }
}
