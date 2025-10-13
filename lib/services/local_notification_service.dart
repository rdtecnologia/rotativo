import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Serviço para gerenciar notificações locais
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    try {
      // Inicializa timezone
      tz.initializeTimeZones();

      // Aguarda um momento para garantir que o banco de dados seja carregado
      await Future.delayed(const Duration(milliseconds: 500));

      // Define timezone padrão para Brasil
      try {
        final location = tz.getLocation('America/Sao_Paulo');
        tz.setLocalLocation(location);
      } catch (e) {
        tz.setLocalLocation(tz.UTC);
      }

      // Configuração para Android
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuração para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        // ✅ Configurações adicionais para iOS
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        // ✅ Configurações para emulador
        notificationCategories: [],
      );

      // Configuração inicial
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializa o plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Solicita permissões
      await _requestPermissions();

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Garante que o serviço está inicializado antes do uso
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Serviço não inicializado, inicializando agora...');
      await initialize();
    }
  }

  /// Solicita permissões necessárias
  Future<void> _requestPermissions() async {
    try {
      // Para Android 13+ (API 33+)
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        debugPrint('🔔 Permissão de notificação: $status');
      }

      // Para Android 12+ (API 31+): Verifica permissão de alarmes exatos
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        debugPrint('🔔 Permissão de alarme exato: $status');
      }

      // ✅ CORREÇÃO CRÍTICA: Verificar otimizações de bateria no Android
      if (Platform.isAndroid) {
        try {
          final batteryOptimization =
              await Permission.ignoreBatteryOptimizations.status;
          debugPrint('🔋 Status otimização de bateria: $batteryOptimization');

          if (batteryOptimization.isDenied) {
            debugPrint(
                '⚠️ IMPORTANTE: App está sujeito a otimizações de bateria');
            debugPrint(
                '⚠️ Isso pode impedir notificações agendadas de funcionarem');
            debugPrint('💡 Solicitando permissão para ignorar otimizações...');

            final result =
                await Permission.ignoreBatteryOptimizations.request();
            debugPrint('🔋 Resultado da permissão de bateria: $result');

            if (result.isDenied) {
              debugPrint(
                  '⚠️ ATENÇÃO: Notificações agendadas podem não funcionar corretamente');
              debugPrint(
                  '💡 Recomendação: Desabilite manualmente as otimizações de bateria para este app');
            }
          } else {
            debugPrint('✅ App não está sujeito a otimizações de bateria');
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao verificar otimizações de bateria: $e');
        }
      }

      debugPrint('🔔 Status das permissões:');
      debugPrint('  - Notificação: ${await Permission.notification.status}');
      debugPrint(
          '  - Alarme Exato: ${await Permission.scheduleExactAlarm.status}');
      if (Platform.isAndroid) {
        debugPrint(
            '  - Ignorar otimização de bateria: ${await Permission.ignoreBatteryOptimizations.status}');
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao solicitar permissões: $e');
    }
  }

  /// Callback quando uma notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificação tocada: ${response.payload}');
  }

  /// Agenda uma notificação de vencimento de estacionamento
  Future<void> scheduleParkingExpirationNotification({
    required String licensePlate,
    required DateTime expirationTime,
    required int reminderMinutes,
    String? location,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? lightsEnabled,
  }) async {
    // Garante que o serviço está inicializado
    await _ensureInitialized();

    // Verifica permissões antes de agendar
    final notificationPermission = await Permission.notification.status;
    final exactAlarmPermission = await Permission.scheduleExactAlarm.status;

    debugPrint('🔔 Verificando permissões antes do agendamento:');
    debugPrint('  - Notificação: $notificationPermission');
    debugPrint('  - Alarme Exato: $exactAlarmPermission');

    // Para Android, verifica se precisa solicitar permissão de alarme exato
    bool canScheduleExact = true;
    if (Platform.isAndroid) {
      debugPrint(
          '🤖 === VERIFICAÇÕES ESPECÍFICAS ANDROID PARA ESTACIONAMENTO ===');

      // Verifica otimizações de bateria
      try {
        final batteryOptimized = await checkBatteryOptimizations();
        debugPrint(
            '🔋 Otimizações de bateria: ${batteryOptimized ? "OK" : "PROBLEMA"}');

        if (!batteryOptimized) {
          debugPrint('⚠️ CRÍTICO: App sujeito a otimizações de bateria!');
          debugPrint(
              '💡 Isso IMPEDE notificações agendadas de funcionarem no Android');
          debugPrint(
              '💡 SOLUÇÃO: Desabilite otimizações de bateria para este app');
          debugPrint(
              '💡 Caminho: Configurações > Apps > Rotativo > Bateria > Não otimizar');
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao verificar otimizações de bateria: $e');
      }

      if (exactAlarmPermission.isDenied) {
        debugPrint('⚠️ Android: Solicitando permissão de alarme exato...');
        final result = await Permission.scheduleExactAlarm.request();
        debugPrint('🔔 Resultado da permissão de alarme exato: $result');
        canScheduleExact = result.isGranted;
      } else {
        canScheduleExact = exactAlarmPermission.isGranted;
      }

      if (!canScheduleExact) {
        debugPrint(
            '⚠️ Android: Alarmes exatos não permitidos, usando modo normal');
      }

      debugPrint('🤖 === FIM VERIFICAÇÕES ANDROID ===');
    }

    // Calcula o horário da notificação
    final notificationTime =
        expirationTime.subtract(Duration(minutes: reminderMinutes));

    // Se o horário já passou, não agenda
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('⏰ Horário de notificação já passou para $licensePlate');
      return;
    }

    // ✅ CORREÇÃO: Usar o mesmo canal que funciona para notificações de 10s
    await _createOrUpdateNotificationChannel(
      'immediate',
      'Notificações Imediatas',
      'Notificações que aparecem imediatamente',
      soundEnabled: soundEnabled ?? true,
      vibrationEnabled: vibrationEnabled ?? true,
      lightsEnabled: lightsEnabled ?? true,
    );

    // ID único para a notificação
    final notificationId =
        _generateNotificationId(licensePlate, reminderMinutes);

    debugPrint('🔔 === AGENDANDO NOTIFICAÇÃO DE ESTACIONAMENTO ===');
    debugPrint('  - Placa: $licensePlate');
    debugPrint('  - Expira às: ${expirationTime.toString()}');
    debugPrint('  - Antecedência: $reminderMinutes minutos');
    debugPrint('  - Horário da notificação: ${notificationTime.toString()}');
    debugPrint('  - Plataforma: ${Platform.isAndroid ? "Android" : "iOS"}');
    debugPrint(
        '  - Som: $soundEnabled, Vibração: $vibrationEnabled, Luzes: $lightsEnabled');
    debugPrint('  - Local: ${location ?? "Não informado"}');

    if (Platform.isAndroid) {
      debugPrint(
          '🤖 === VERIFICAÇÕES ESPECÍFICAS ANDROID PARA ESTACIONAMENTO ===');

      // Verifica otimizações de bateria
      try {
        final batteryOptimized = await checkBatteryOptimizations();
        debugPrint(
            '🔋 Otimizações de bateria: ${batteryOptimized ? "OK" : "PROBLEMA"}');

        if (!batteryOptimized) {
          debugPrint('⚠️ CRÍTICO: App sujeito a otimizações de bateria!');
          debugPrint(
              '💡 Isso IMPEDE notificações agendadas de funcionarem no Android');
          debugPrint(
              '💡 SOLUÇÃO: Desabilite otimizações de bateria para este app');
          debugPrint(
              '💡 Caminho: Configurações > Apps > Rotativo > Bateria > Não otimizar');
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao verificar otimizações de bateria: $e');
      }

      debugPrint('🤖 === FIM VERIFICAÇÕES ANDROID ===');
    }

    try {
      debugPrint('🔔 Tentando agendar notificação:');
      debugPrint('  - ID: $notificationId');
      debugPrint('  - Placa: $licensePlate');
      debugPrint('  - Horário atual: ${DateTime.now()}');
      debugPrint('  - Horário da notificação: $notificationTime');
      debugPrint('  - Timezone local: ${tz.local}');
      debugPrint(
          '  - TZDateTime: ${tz.TZDateTime.from(notificationTime, tz.local)}');
      debugPrint(
          '  - Diferença até notificação: ${notificationTime.difference(DateTime.now()).inMinutes} minutos');
      debugPrint('  - Modo Android: ${canScheduleExact ? "exact" : "inexact"}');

      // ✅ CORREÇÃO: Usar a mesma abordagem de timezone que funciona nos testes
      final now = tz.TZDateTime.now(tz.local);
      final minutesUntilNotification =
          notificationTime.difference(DateTime.now()).inMinutes;
      final tzNotificationTime =
          now.add(Duration(minutes: minutesUntilNotification));

      debugPrint('🔧 === CORREÇÃO TIMEZONE ===');
      debugPrint('  - DateTime notificationTime: $notificationTime');
      debugPrint('  - TZDateTime.now(): $now');
      debugPrint('  - Minutos até notificação: $minutesUntilNotification');
      debugPrint('  - TZDateTime target: $tzNotificationTime');
      debugPrint('🔧 === FIM CORREÇÃO ===');

      // ✅ Usar a API correta para agendar notificações
      await _notifications.zonedSchedule(
        notificationId,
        'Estacionamento expirando',
        'O estacionamento do veículo $licensePlate expira em $reminderMinutes minutos${location != null ? ' em $location' : ''}',
        tzNotificationTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'immediate',
            'Notificações Imediatas',
            channelDescription: 'Notificações que aparecem imediatamente',
            importance: Importance.max,
            priority: Priority.max,
            color: Colors.orange,
            icon: '@mipmap/ic_launcher',
            // Configurações específicas para garantir som e vibração
            enableVibration: vibrationEnabled ?? true,
            enableLights: lightsEnabled ?? true,
            playSound: soundEnabled ?? true,
            // Configurações adicionais para garantir funcionamento
            vibrationPattern: vibrationEnabled == true
                ? Int64List.fromList([0, 250, 250, 250])
                : null,
            ledColor: lightsEnabled == true ? Colors.blue : null,
            ledOnMs: lightsEnabled == true ? 1000 : null,
            ledOffMs: lightsEnabled == true ? 1000 : null,
            // ✅ Configurações adicionais para Android agendadas
            showWhen: true,
            when: notificationTime.millisecondsSinceEpoch,
            usesChronometer: false,
            chronometerCountDown: false,
            category: AndroidNotificationCategory
                .alarm, // ✅ Categoria de alarme para maior prioridade
            visibility: NotificationVisibility.public,
            autoCancel: true, // ✅ Remove a notificação quando tocada
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // ✅ Configurações adicionais para iOS
            badgeNumber: 1,
            threadIdentifier: 'parking_notifications',
            categoryIdentifier: 'parking_expiration',
            // ✅ Configurações para emulador
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload:
            'parking_expiration:$licensePlate:${expirationTime.toIso8601String()}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // ✅ CORREÇÃO CRÍTICA: Usar allowWhileIdle para funcionar mesmo com otimizações de bateria
        // ✅ CORREÇÃO: Remover matchDateTimeComponents para agendar apenas uma vez
        // matchDateTimeComponents: DateTimeComponents.time, // ❌ Isso fazia repetir diariamente
      );

      debugPrint('✅ Notificação de estacionamento agendada com sucesso!');

      // ✅ FALLBACK: Timer para garantir que funcione no Android
      if (Platform.isAndroid && minutesUntilNotification > 0) {
        Timer(Duration(minutes: minutesUntilNotification), () async {
          debugPrint('⏰ Timer estacionamento disparado para $licensePlate!');
          try {
            await _notifications.show(
              notificationId + 100000, // ID diferente para fallback
              'Estacionamento expirando',
              'O estacionamento do veículo $licensePlate expira em $reminderMinutes minutos${location != null ? ' em $location' : ''}',
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'immediate',
                  'Notificações Imediatas',
                  channelDescription: 'Notificações que aparecem imediatamente',
                  importance: Importance.max,
                  priority: Priority.max,
                  color: Colors.orange,
                  icon: '@mipmap/ic_launcher',
                  enableVibration: vibrationEnabled ?? true,
                  enableLights: lightsEnabled ?? true,
                  playSound: soundEnabled ?? true,
                  category: AndroidNotificationCategory.alarm,
                  visibility: NotificationVisibility.public,
                ),
              ),
              payload: 'parking_timer:$licensePlate',
            );
            debugPrint(
                '✅ Notificação de estacionamento enviada para $licensePlate!');
          } catch (e) {
            debugPrint('❌ Erro na notificação de estacionamento: $e');
          }
        });
      }

      // Verificar se a notificação foi realmente agendada
      await Future.delayed(const Duration(milliseconds: 500));
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      final scheduledNotification =
          pendingNotifications.where((n) => n.id == notificationId).isNotEmpty
              ? pendingNotifications.where((n) => n.id == notificationId).first
              : null;

      debugPrint('🔍 === VERIFICAÇÃO PÓS-AGENDAMENTO ===');
      debugPrint(
          '  - Total notificações pendentes: ${pendingNotifications.length}');
      debugPrint('  - Procurando ID: $notificationId');

      if (scheduledNotification != null) {
        debugPrint('✅ CONFIRMADO: Notificação está na lista de pendentes');
        debugPrint('  - ID: ${scheduledNotification.id}');
        debugPrint('  - Título: ${scheduledNotification.title}');
        debugPrint('  - Corpo: ${scheduledNotification.body}');

        if (Platform.isAndroid) {
          final timeUntilNotification =
              notificationTime.difference(DateTime.now());
          debugPrint(
              '🤖 Android - Tempo até notificação: ${timeUntilNotification.inSeconds}s');
          debugPrint(
              '🤖 Android - Modo: ${canScheduleExact ? "exactAllowWhileIdle" : "inexactAllowWhileIdle"}');
        }
      } else {
        debugPrint(
            '❌ PROBLEMA CRÍTICO: Notificação NÃO foi encontrada na lista de pendentes!');
        debugPrint('📋 Todas as notificações pendentes:');
        for (final notification in pendingNotifications) {
          debugPrint(
              '  - ID: ${notification.id}, Título: ${notification.title}');
        }
      }
    } catch (e) {
      debugPrint('❌ ERRO CRÍTICO ao agendar notificação para $licensePlate:');
      debugPrint('  - Tipo do erro: ${e.runtimeType}');
      debugPrint('  - Mensagem: ${e.toString()}');
      debugPrint('  - Stack trace: ${StackTrace.current}');

      // Não fazer fallback - mas vamos investigar o erro
      rethrow; // Re-lança o erro para que possa ser capturado em níveis superiores
    }
  }

  /// Cancela todas as notificações de um veículo específico
  Future<void> cancelVehicleNotifications(String licensePlate) async {
    // Cancela notificações com IDs que contêm a placa
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();

    for (final notification in pendingNotifications) {
      if (notification.payload?.contains(licensePlate) == true) {
        await _notifications.cancel(notification.id);
        debugPrint(
            '🔔 Notificação cancelada para $licensePlate (ID: ${notification.id})');
      }
    }
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🔔 Todas as notificações foram canceladas');
  }

  /// Cancela apenas notificações de estacionamento real, preserva testes
  Future<void> cancelOnlyParkingNotifications() async {
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();

    for (final notification in pendingNotifications) {
      // Preserva notificações de teste (IDs específicos e payloads de teste)
      if (_isTestNotification(notification)) {
        debugPrint(
            '🔔 Preservando notificação de teste: ${notification.title} (ID: ${notification.id})');
        continue;
      }

      // Cancela notificações de estacionamento real
      if (_isParkingNotification(notification)) {
        await _notifications.cancel(notification.id);
        debugPrint(
            '🔔 Cancelada notificação de estacionamento: ${notification.title} (ID: ${notification.id})');
      }
    }
  }

  /// Verifica se é uma notificação de teste
  bool _isTestNotification(PendingNotificationRequest notification) {
    // IDs de teste conhecidos
    const testIds = {999999, 888888, 777777, 666666, 111111, 222222};
    if (testIds.contains(notification.id)) return true;

    // Payloads de teste
    final payload = notification.payload ?? '';
    if (payload.contains('test') ||
        payload.contains('android_10s') ||
        payload.contains('android_parking_2min') ||
        payload.contains('timer_test') ||
        payload.contains('simple_test') ||
        payload.contains('comparison')) {
      return true;
    }

    // Títulos de teste
    final title = notification.title ?? '';
    if (title.contains('TESTE') ||
        title.contains('🤖') ||
        title.contains('🚗') ||
        title.contains('⏱️') ||
        title.contains('🔍')) {
      return true;
    }

    return false;
  }

  /// Verifica se é uma notificação de estacionamento real
  bool _isParkingNotification(PendingNotificationRequest notification) {
    final payload = notification.payload ?? '';
    return payload.startsWith('parking_expiration:');
  }

  /// Mostra uma notificação imediata (para testes)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? lightsEnabled,
  }) async {
    print('🔔 [RELEASE] Iniciando notificação imediata: $title');

    // Garante que o serviço está inicializado
    await _ensureInitialized();

    try {
      // ✅ Verificação específica para iOS
      if (Platform.isIOS) {
        // Para iOS, vamos usar configurações mais simples
        await _notifications.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title,
          body,
          NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              // ✅ Configurações específicas para iOS
              badgeNumber: 1,
              threadIdentifier: 'immediate_notifications',
              categoryIdentifier: 'immediate',
              // ✅ Configurações para emulador
              interruptionLevel: InterruptionLevel.active,
            ),
          ),
          payload: payload,
        );

        await Future.delayed(const Duration(seconds: 2));

        return;
      }

      // Cria ou atualiza o canal de notificação com as configurações
      await _createOrUpdateNotificationChannel(
        'immediate',
        'Notificações Imediatas',
        'Notificações que aparecem imediatamente',
        soundEnabled: soundEnabled ?? true,
        vibrationEnabled: vibrationEnabled ?? true,
        lightsEnabled: lightsEnabled ?? true,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'immediate',
            'Notificações Imediatas',
            channelDescription: 'Notificações que aparecem imediatamente',
            importance: Importance.max, // ✅ Importância máxima
            priority: Priority.max, // ✅ Prioridade máxima
            // Configura ícone explícito para evitar NullPointerException
            icon: '@mipmap/ic_launcher',
            // ✅ Configurações específicas da notificação
            enableVibration: vibrationEnabled ?? true,
            enableLights: lightsEnabled ?? true,
            playSound: soundEnabled ?? true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // ✅ Configurações adicionais para iOS
            badgeNumber: 1,
            threadIdentifier: 'immediate_notifications',
            categoryIdentifier: 'immediate',
            // ✅ Configurações para emulador
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: payload,
      );

      // Verificar se a notificação foi realmente processada
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
    } catch (e) {
      //
    }
  }

  /// Lista todas as notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Lista e exibe todas as notificações pendentes para debug
  Future<void> debugPendingNotifications() async {
    try {
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      debugPrint('🔔 === NOTIFICAÇÕES PENDENTES ===');
      debugPrint('📊 Total: ${pendingNotifications.length}');

      if (pendingNotifications.isEmpty) {
        debugPrint('❌ Nenhuma notificação pendente encontrada!');
      } else {
        for (final notification in pendingNotifications) {
          debugPrint('📋 ID: ${notification.id}');
          debugPrint('   Título: ${notification.title}');
          debugPrint('   Corpo: ${notification.body}');
          debugPrint('   Payload: ${notification.payload}');
          debugPrint('   ---');
        }
      }
      debugPrint('🔔 === FIM DA LISTA ===');
    } catch (e) {
      debugPrint('❌ Erro ao listar notificações pendentes: $e');
    }
  }

  /// Verifica se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    final androidEnabled = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    // Para iOS, assume que está habilitado se não há erro
    const iosEnabled = true;

    return androidEnabled ?? iosEnabled;
  }

  /// Verifica e exibe o status completo das notificações e permissões
  Future<void> debugSystemStatus() async {
    debugPrint('🔍 === STATUS COMPLETO DO SISTEMA ===');

    try {
      // Plataforma
      debugPrint('📱 Plataforma: ${Platform.operatingSystem}');
      debugPrint('📱 Versão: ${Platform.operatingSystemVersion}');

      // Timezone
      debugPrint('🌍 Timezone local: ${tz.local}');
      debugPrint('🌍 Timezone atual: ${DateTime.now().timeZoneName}');
      debugPrint('🌍 Offset: ${DateTime.now().timeZoneOffset}');

      // Permissões
      if (Platform.isAndroid) {
        final notificationStatus = await Permission.notification.status;
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        debugPrint(
            '🔔 Permissão de notificação (Android): $notificationStatus');
        debugPrint('⏰ Permissão de alarme exato (Android): $exactAlarmStatus');
      }

      // Status das notificações
      final enabled = await areNotificationsEnabled();
      debugPrint('🔔 Notificações habilitadas: $enabled');

      // Notificações pendentes
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📊 Total de notificações pendentes: ${pending.length}');

      if (pending.isNotEmpty) {
        debugPrint('📋 Notificações pendentes:');
        for (final notification in pending) {
          debugPrint(
              '  - ID: ${notification.id}, Título: ${notification.title}');
        }
      }

      // Teste de inicialização
      debugPrint('🔧 Testando inicialização...');
      await initialize();
      debugPrint('✅ Inicialização OK');
    } catch (e) {
      debugPrint('❌ Erro ao verificar status: $e');
    }

    debugPrint('🔍 === FIM DO STATUS ===');
  }

  /// Gera um ID único para a notificação
  int _generateNotificationId(String licensePlate, int reminderMinutes) {
    // Combina hash da placa com os minutos para criar um ID único
    final hash = licensePlate.hashCode;
    final minutesHash = reminderMinutes.hashCode;
    return (hash + minutesHash).abs() % 2147483647; // Max int32
  }

  /// Agenda notificação de teste
  Future<void> scheduleTestNotification({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? lightsEnabled,
  }) async {
    // Garante que o serviço está inicializado
    await _ensureInitialized();

    // Verifica permissões antes de agendar
    final notificationPermission = await Permission.notification.status;
    final exactAlarmPermission = await Permission.scheduleExactAlarm.status;

    debugPrint('🔔 Verificando permissões antes do teste:');
    debugPrint('  - Notificação: $notificationPermission');
    debugPrint('  - Alarme Exato: $exactAlarmPermission');

    // Para Android, verifica se precisa solicitar permissão de alarme exato
    bool canScheduleExact = true;
    if (Platform.isAndroid) {
      if (exactAlarmPermission.isDenied) {
        debugPrint('⚠️ Android: Solicitando permissão de alarme exato...');
        final result = await Permission.scheduleExactAlarm.request();
        debugPrint('🔔 Resultado da permissão de alarme exato: $result');
        canScheduleExact = result.isGranted;
      } else {
        canScheduleExact = exactAlarmPermission.isGranted;
      }

      if (!canScheduleExact) {
        debugPrint(
            '⚠️ Android: Alarmes exatos não permitidos, usando modo normal');
      }
    }

    // Cria ou atualiza o canal de notificação com as configurações
    await _createOrUpdateNotificationChannel(
      'test',
      'Teste',
      'Notificações de teste',
      soundEnabled: soundEnabled ?? true,
      vibrationEnabled: vibrationEnabled ?? true,
      lightsEnabled: lightsEnabled ?? true,
    );

    debugPrint('🧪 Agendando notificação de teste para 5 segundos...');
    debugPrint(
        '🧪 Configurações: Som=$soundEnabled, Vibração=$vibrationEnabled, Luzes=$lightsEnabled');

    try {
      // ✅ Usar a API correta para agendar notificações
      final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
      final notificationId = 999999; // ID de teste

      debugPrint('🧪 === DETALHES DO TESTE DE 5 SEGUNDOS ===');
      debugPrint('  - ID: $notificationId');
      debugPrint('  - Horário atual: ${DateTime.now()}');
      debugPrint('  - Horário agendado: $scheduledTime');
      debugPrint('  - Timezone local: ${tz.local}');
      debugPrint(
          '  - TZDateTime: ${tz.TZDateTime.from(scheduledTime, tz.local)}');
      debugPrint(
          '  - Configurações: Som=$soundEnabled, Vibração=$vibrationEnabled, Luzes=$lightsEnabled');

      await _notifications.zonedSchedule(
        notificationId,
        'Teste de Notificação',
        'Esta é uma notificação de teste!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test',
            'Teste',
            channelDescription: 'Notificações de teste',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            // ✅ Configurações específicas para garantir som e vibração
            enableVibration: vibrationEnabled ?? true,
            enableLights: lightsEnabled ?? true,
            playSound: soundEnabled ?? true,
            // ✅ Configurações adicionais para garantir funcionamento
            vibrationPattern: vibrationEnabled == true
                ? Int64List.fromList([0, 250, 250, 250])
                : null,
            ledColor: lightsEnabled == true ? Colors.blue : null,
            ledOnMs: lightsEnabled == true ? 1000 : null,
            ledOffMs: lightsEnabled == true ? 1000 : null,
            // ✅ Configurações adicionais para forçar som e vibração
            showWhen: true,
            when: DateTime.now().millisecondsSinceEpoch,
            usesChronometer: false,
            chronometerCountDown: false,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // ✅ Configurações adicionais para iOS
            badgeNumber: 1,
            threadIdentifier: 'test_notifications',
            categoryIdentifier: 'test',
            // ✅ Configurações para emulador
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'test',
        androidScheduleMode: canScheduleExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        // ✅ CORREÇÃO CRÍTICA: Usar allowWhileIdle para funcionar mesmo com otimizações de bateria
        // ✅ CORREÇÃO: Remover matchDateTimeComponents para agendar apenas uma vez
        // matchDateTimeComponents: DateTimeComponents.time, // ❌ Isso fazia repetir diariamente
      );

      debugPrint('✅ Notificação de teste agendada com sucesso!');

      // Verificar se foi realmente agendada
      await Future.delayed(const Duration(milliseconds: 500));
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      final found =
          pendingNotifications.where((n) => n.id == notificationId).isNotEmpty
              ? pendingNotifications.where((n) => n.id == notificationId).first
              : null;

      if (found != null) {
        debugPrint('✅ CONFIRMADO: Teste está na lista de pendentes!');
        debugPrint('  - Título: ${found.title}');
        debugPrint('  - Corpo: ${found.body}');
        debugPrint('  - Canal: ${found.payload}');
        debugPrint(
            '  - Modo Android: ${canScheduleExact ? "exact" : "inexact"}');
      } else {
        debugPrint(
            '❌ PROBLEMA CRÍTICO: Teste NÃO foi encontrado na lista de pendentes!');
        debugPrint(
            '📊 Total de notificações pendentes: ${pendingNotifications.length}');

        // Listar todas as pendentes para debug
        for (final notification in pendingNotifications) {
          debugPrint(
              '📋 Pendente: ID=${notification.id}, Título=${notification.title}');
        }
      }

      // Debug adicional para Android
      if (Platform.isAndroid) {
        debugPrint('🤖 === DEBUG ANDROID ESPECÍFICO ===');
        debugPrint(
            '  - Modo de agendamento: ${canScheduleExact ? "exact" : "inexact"}');
        debugPrint('  - Permissão de notificação: $notificationPermission');
        debugPrint('  - Permissão de alarme exato: $exactAlarmPermission');
        debugPrint('  - Canal criado: test');
        debugPrint('🤖 === FIM DEBUG ANDROID ===');
      }

      debugPrint('🧪 === FIM DOS DETALHES DO TESTE ===');

      // Teste adicional para Android: notificação imediata para comparar
      if (Platform.isAndroid) {
        debugPrint(
            '🤖 Testando notificação imediata no Android para comparação...');
        await Future.delayed(const Duration(seconds: 1));
        await showImmediateNotification(
          title: 'Teste Imediato Android',
          body:
              'Esta é uma notificação imediata para testar se o canal funciona',
          soundEnabled: soundEnabled,
          vibrationEnabled: vibrationEnabled,
          lightsEnabled: lightsEnabled,
        );
      }
    } catch (e) {
      debugPrint('❌ ERRO CRÍTICO no teste de 5 segundos:');
      debugPrint('  - Tipo do erro: ${e.runtimeType}');
      debugPrint('  - Mensagem: ${e.toString()}');
      debugPrint('  - Stack trace: ${StackTrace.current}');

      // Re-lança o erro para que possa ser investigado
      rethrow;
    }
  }

  /// Testa notificações específicas para iOS
  Future<void> testIOSNotification() async {
    if (!Platform.isIOS) return;

    debugPrint('🍎 Testando notificação específica para iOS...');

    try {
      // ✅ Configuração específica para iOS
      await _notifications.show(
        999, // ID fixo para teste
        '🍎 Teste iOS',
        'Esta é uma notificação de teste específica para iOS',
        NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 999,
            threadIdentifier: 'ios_test',
            categoryIdentifier: 'test',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'ios_test_notification',
      );

      debugPrint('🍎 Notificação de teste iOS enviada com sucesso');
      debugPrint(
          '🍎 Verifique o Centro de Notificações (puxe para baixo no topo)');
    } catch (e) {
      debugPrint('❌ Erro ao enviar notificação de teste iOS: $e');
    }
  }

  /// Testa notificação agendada específica para iOS
  Future<void> testIOScheduledNotification() async {
    if (!Platform.isIOS) return;

    debugPrint('🍎 Testando notificação agendada específica para iOS...');

    try {
      // Agendar notificação para 10 segundos no futuro
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

      await _notifications.zonedSchedule(
        888, // ID fixo para teste
        '🍎 Teste iOS Agendado',
        'Esta é uma notificação agendada específica para iOS',
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 888,
            threadIdentifier: 'ios_scheduled_test',
            categoryIdentifier: 'test',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'ios_scheduled_test_notification',
        androidScheduleMode: AndroidScheduleMode.inexact,
        // ✅ CORREÇÃO: Remover matchDateTimeComponents para agendar apenas uma vez
        // matchDateTimeComponents: DateTimeComponents.time, // ❌ Isso fazia repetir diariamente
      );

      debugPrint('🍎 Notificação agendada iOS configurada com sucesso');
      debugPrint('🍎 Notificação aparecerá em 10 segundos');
      debugPrint(
          '🍎 Verifique o Centro de Notificações (puxe para baixo no topo)');
    } catch (e) {
      debugPrint('❌ Erro ao agendar notificação de teste iOS: $e');
    }
  }

  /// Testa notificações específicas para Android
  Future<void> testAndroidNotification() async {
    if (!Platform.isAndroid) return;

    debugPrint('🤖 Testando notificação específica para Android...');

    try {
      // ✅ Configuração específica para Android
      await _notifications.show(
        888, // ID fixo para teste
        '🤖 Teste Android',
        'Esta é uma notificação de teste específica para Android',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'android_test',
            'Teste Android',
            channelDescription: 'Notificações de teste para Android',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
            playSound: true,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
            autoCancel: true,
            showWhen: true,
            when: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
        payload: 'android_test_notification',
      );

      debugPrint('🤖 Notificação de teste Android enviada com sucesso');
      debugPrint('🤖 Verifique a barra de notificações');
    } catch (e) {
      debugPrint('❌ Erro ao enviar notificação de teste Android: $e');
    }
  }

  /// Testa notificação agendada específica para Android
  Future<void> testAndroidScheduledNotification() async {
    if (!Platform.isAndroid) return;

    debugPrint('🤖 Testando notificação agendada específica para Android...');

    try {
      // Verifica permissões específicas do Android
      final notificationPermission = await Permission.notification.status;
      final exactAlarmPermission = await Permission.scheduleExactAlarm.status;

      debugPrint('🤖 Permissões Android:');
      debugPrint('  - Notificação: $notificationPermission');
      debugPrint('  - Alarme Exato: $exactAlarmPermission');

      // Solicita permissões se necessário
      bool canScheduleExact = true;
      if (exactAlarmPermission.isDenied) {
        debugPrint('🤖 Solicitando permissão de alarme exato...');
        final result = await Permission.scheduleExactAlarm.request();
        debugPrint('🤖 Resultado: $result');
        canScheduleExact = result.isGranted;
      } else {
        canScheduleExact = exactAlarmPermission.isGranted;
      }

      // Agendar notificação para 10 segundos no futuro
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

      debugPrint('🤖 Agendando para: $scheduledTime');
      debugPrint('🤖 Modo: ${canScheduleExact ? "exact" : "inexact"}');

      await _notifications.zonedSchedule(
        777, // ID fixo para teste
        '🤖 Teste Android Agendado',
        'Esta é uma notificação agendada específica para Android (10 segundos)',
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'android_scheduled_test',
            'Teste Android Agendado',
            channelDescription: 'Teste de notificação agendada para Android',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
            playSound: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            autoCancel: true,
            showWhen: true,
            when: scheduledTime.millisecondsSinceEpoch,
            usesChronometer: false,
            chronometerCountDown: false,
          ),
        ),
        payload: 'android_scheduled_test_notification',
        androidScheduleMode: canScheduleExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        // ✅ CORREÇÃO CRÍTICA: Usar allowWhileIdle para funcionar mesmo com otimizações de bateria
        // ✅ CORREÇÃO: Remover matchDateTimeComponents para agendar apenas uma vez
        // matchDateTimeComponents: DateTimeComponents.time, // ❌ Isso fazia repetir diariamente
      );

      debugPrint('🤖 Notificação agendada Android configurada com sucesso');
      debugPrint('🤖 Notificação aparecerá em 10 segundos');
      debugPrint('🤖 Verifique a barra de notificações');

      // Verificar se foi agendada
      await Future.delayed(const Duration(milliseconds: 500));
      final pending = await _notifications.pendingNotificationRequests();
      final found = pending.where((n) => n.id == 777).isNotEmpty
          ? pending.where((n) => n.id == 777).first
          : null;

      if (found != null) {
        debugPrint('🤖 ✅ Confirmado: Teste Android está na lista de pendentes');
        debugPrint('🤖   - Título: ${found.title}');
        debugPrint('🤖   - Corpo: ${found.body}');
      } else {
        debugPrint(
            '🤖 ❌ PROBLEMA: Teste Android NÃO foi encontrado na lista de pendentes!');
      }
    } catch (e) {
      debugPrint('❌ Erro ao agendar notificação de teste Android: $e');
      debugPrint('💡 Stack trace: ${StackTrace.current}');
    }
  }

  /// Debug específico para Android
  Future<void> debugAndroidSpecific() async {
    if (!Platform.isAndroid) return;

    debugPrint('🤖 === DEBUG ESPECÍFICO ANDROID ===');

    try {
      // Informações da plataforma
      debugPrint('📱 Android detectado');
      debugPrint('📱 Versão do SO: ${Platform.operatingSystemVersion}');

      // Permissões
      final notificationStatus = await Permission.notification.status;
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('🔔 Permissão de notificação: $notificationStatus');
      debugPrint('⏰ Permissão de alarme exato: $exactAlarmStatus');

      // Status das notificações
      final enabled = await areNotificationsEnabled();
      debugPrint('🔔 Notificações habilitadas: $enabled');

      // Timezone
      debugPrint('🌍 Timezone local: ${tz.local}');
      debugPrint('🌍 Offset atual: ${DateTime.now().timeZoneOffset}');

      // Canais de notificação existentes
      debugPrint('📺 Testando criação de canal...');
      await _createOrUpdateNotificationChannel(
        'debug_android',
        'Debug Android',
        'Canal de debug para Android',
      );
      debugPrint('📺 Canal de debug criado com sucesso');

      // Notificações pendentes
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📊 Total de notificações pendentes: ${pending.length}');

      if (pending.isNotEmpty) {
        debugPrint('📋 Notificações pendentes:');
        for (final notification in pending) {
          debugPrint(
              '  - ID: ${notification.id}, Título: ${notification.title}');
        }
      }

      // ✅ NOVA VERIFICAÇÃO: Otimizações de bateria
      try {
        final batteryOptimization =
            await Permission.ignoreBatteryOptimizations.status;
        debugPrint('🔋 Otimização de bateria: $batteryOptimization');

        if (batteryOptimization.isDenied) {
          debugPrint(
              '⚠️ PROBLEMA CRÍTICO: App está sujeito a otimizações de bateria!');
          debugPrint(
              '⚠️ Isso pode impedir notificações agendadas de funcionarem!');
          debugPrint(
              '💡 SOLUÇÃO: Desabilite as otimizações de bateria para este app');
          debugPrint(
              '💡 Caminho: Configurações > Apps > Rotativo > Bateria > Não otimizar');
        } else {
          debugPrint('✅ App não está sujeito a otimizações de bateria');
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao verificar otimizações de bateria: $e');
      }

      debugPrint('🤖 === FIM DEBUG ANDROID ===');
    } catch (e) {
      debugPrint('❌ Erro no debug específico Android: $e');
    }
  }

  /// Verifica se as otimizações de bateria estão impedindo notificações
  Future<bool> checkBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      debugPrint('🔋 Verificação de otimizações de bateria:');
      debugPrint('  - Status: $status');
      debugPrint('  - Permitido: ${status.isGranted}');

      if (status.isDenied) {
        debugPrint('⚠️ PROBLEMA: App está sujeito a otimizações de bateria');
        debugPrint(
            '💡 Isso pode impedir notificações agendadas de funcionarem');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao verificar otimizações de bateria: $e');
      return false;
    }
  }

  /// Solicita ao usuário para desabilitar otimizações de bateria
  Future<void> requestDisableBatteryOptimizations() async {
    if (!Platform.isAndroid) return;

    try {
      debugPrint(
          '🔋 Solicitando permissão para ignorar otimizações de bateria...');
      final result = await Permission.ignoreBatteryOptimizations.request();
      debugPrint('🔋 Resultado: $result');

      if (result.isGranted) {
        debugPrint('✅ Otimizações de bateria desabilitadas com sucesso!');
      } else {
        debugPrint(
            '⚠️ Usuário não permitiu desabilitar otimizações de bateria');
        debugPrint(
            '💡 Notificações agendadas podem não funcionar corretamente');
      }
    } catch (e) {
      debugPrint('❌ Erro ao solicitar desabilitação de otimizações: $e');
    }
  }

  /// Teste específico para notificações de longo prazo (como estacionamento real)
  Future<void> testLongTermNotification({int minutesFromNow = 2}) async {
    debugPrint('⏰ === TESTE DE NOTIFICAÇÃO DE LONGO PRAZO ===');
    debugPrint('⏰ Agendando notificação para $minutesFromNow minutos...');

    final scheduledTime = DateTime.now().add(Duration(minutes: minutesFromNow));
    final notificationId = 777777;

    debugPrint('📅 Horário atual: ${DateTime.now()}');
    debugPrint('📅 Horário agendado: $scheduledTime');
    debugPrint('🆔 ID da notificação: $notificationId');
    debugPrint(
        '⏰ Diferença: ${scheduledTime.difference(DateTime.now()).inMinutes} minutos');

    try {
      // Verifica permissões específicas
      final notificationPermission = await Permission.notification.status;
      final exactAlarmPermission = await Permission.scheduleExactAlarm.status;
      bool canScheduleExact = exactAlarmPermission.isGranted;

      debugPrint('🔔 Permissões para teste longo prazo:');
      debugPrint('  - Notificação: $notificationPermission');
      debugPrint('  - Alarme Exato: $exactAlarmPermission');
      debugPrint('  - Pode agendar exato: $canScheduleExact');

      await _notifications.zonedSchedule(
        notificationId,
        '⏰ Teste Longo Prazo',
        'Esta notificação foi agendada para aparecer em $minutesFromNow minutos! (${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')})',
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_long_term',
            'Teste Longo Prazo',
            channelDescription: 'Notificações de teste para longo prazo',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
            playSound: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            autoCancel: true,
            showWhen: true,
            when: scheduledTime.millisecondsSinceEpoch,
            usesChronometer: false,
            chronometerCountDown: false,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 777,
            threadIdentifier: 'long_term_test',
            categoryIdentifier: 'test',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'long_term_test_notification',
        androidScheduleMode: canScheduleExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        // ✅ SEM matchDateTimeComponents para evitar repetição
      );

      debugPrint('✅ Notificação de longo prazo agendada com sucesso!');

      // Verificar se foi agendada
      await Future.delayed(const Duration(milliseconds: 500));
      final pending = await _notifications.pendingNotificationRequests();
      final found = pending.where((n) => n.id == notificationId).isNotEmpty
          ? pending.where((n) => n.id == notificationId).first
          : null;

      if (found != null) {
        debugPrint(
            '✅ CONFIRMADO: Teste longo prazo está na lista de pendentes');
        debugPrint('  - Título: ${found.title}');
        debugPrint('  - Corpo: ${found.body}');
      } else {
        debugPrint(
            '❌ PROBLEMA: Teste longo prazo NÃO foi encontrado na lista de pendentes!');
      }

      debugPrint('⏰ Aguarde $minutesFromNow minutos para ver a notificação...');
      debugPrint(
          '⏰ Notificação deve aparecer às ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}');

      // Debug adicional para Android
      if (Platform.isAndroid) {
        debugPrint('🤖 === DEBUG LONGO PRAZO ANDROID ===');
        debugPrint('  - Timezone atual: ${DateTime.now().timeZoneName}');
        debugPrint('  - Offset: ${DateTime.now().timeZoneOffset}');
        debugPrint('  - TZ Local: ${tz.local.name}');
        debugPrint(
            '  - TZDateTime: ${tz.TZDateTime.from(scheduledTime, tz.local)}');
        debugPrint(
            '  - É no futuro: ${tz.TZDateTime.from(scheduledTime, tz.local).isAfter(tz.TZDateTime.now(tz.local))}');
        debugPrint('🤖 === FIM DEBUG LONGO PRAZO ===');
      }
    } catch (e) {
      debugPrint('❌ ERRO no teste de longo prazo: $e');
      debugPrint('💡 Stack trace: ${StackTrace.current}');
    }
  }

  /// Compara notificações de curto vs longo prazo para identificar diferenças
  Future<void> compareShortVsLongTerm() async {
    debugPrint('🔍 === COMPARAÇÃO CURTO VS LONGO PRAZO ===');

    try {
      // Teste curto prazo (30 segundos)
      debugPrint('🔍 Agendando teste CURTO PRAZO (30 segundos)...');
      final shortTime = DateTime.now().add(const Duration(seconds: 30));
      final shortId = 111111;

      await _notifications.zonedSchedule(
        shortId,
        '🔍 Curto Prazo',
        'Teste de 30 segundos - deve funcionar',
        tz.TZDateTime.from(shortTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'comparison_short',
            'Comparação Curto',
            channelDescription: 'Teste comparativo curto prazo',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
            playSound: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            autoCancel: true,
            showWhen: true,
            when: shortTime.millisecondsSinceEpoch,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 111,
            threadIdentifier: 'comparison_short',
            categoryIdentifier: 'test',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'comparison_short',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // Aguarda um pouco
      await Future.delayed(const Duration(milliseconds: 100));

      // Teste longo prazo (5 minutos)
      debugPrint('🔍 Agendando teste LONGO PRAZO (5 minutos)...');
      final longTime = DateTime.now().add(const Duration(minutes: 5));
      final longId = 222222;

      await _notifications.zonedSchedule(
        longId,
        '🔍 Longo Prazo',
        'Teste de 5 minutos - pode não funcionar no Android',
        tz.TZDateTime.from(longTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'comparison_long',
            'Comparação Longo',
            channelDescription: 'Teste comparativo longo prazo',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
            playSound: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            autoCancel: true,
            showWhen: true,
            when: longTime.millisecondsSinceEpoch,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 222,
            threadIdentifier: 'comparison_long',
            categoryIdentifier: 'test',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'comparison_long',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // Verificar se ambas foram agendadas
      await Future.delayed(const Duration(milliseconds: 500));
      final pending = await _notifications.pendingNotificationRequests();

      final shortFound = pending.where((n) => n.id == shortId).isNotEmpty;
      final longFound = pending.where((n) => n.id == longId).isNotEmpty;

      debugPrint('🔍 Resultados da comparação:');
      debugPrint('  - Curto prazo (30s) agendado: $shortFound');
      debugPrint('  - Longo prazo (5min) agendado: $longFound');

      if (shortFound && longFound) {
        debugPrint('✅ Ambas as notificações foram agendadas');
        debugPrint(
            '💡 Se apenas a de 30s funcionar, o problema é específico de longo prazo');
      } else {
        debugPrint('❌ Problema no agendamento:');
        if (!shortFound) debugPrint('  - Curto prazo NÃO foi agendado');
        if (!longFound) debugPrint('  - Longo prazo NÃO foi agendado');
      }

      debugPrint('🔍 Aguarde para comparar qual funciona...');
      debugPrint('  - 30 segundos: notificação curto prazo');
      debugPrint('  - 5 minutos: notificação longo prazo');
    } catch (e) {
      debugPrint('❌ Erro na comparação: $e');
    }
  }

  /// Teste simples de notificação agendada (funciona em iOS e Android)
  Future<void> testSimpleScheduledNotification(
      {int secondsFromNow = 30}) async {
    debugPrint('🧪 === TESTE SIMPLES DE NOTIFICAÇÃO AGENDADA ===');
    debugPrint('⏰ Agendando notificação para $secondsFromNow segundos...');

    final scheduledTime = DateTime.now().add(Duration(seconds: secondsFromNow));
    final notificationId = 999999;

    debugPrint('📅 Horário atual: ${DateTime.now()}');
    debugPrint('📅 Horário agendado: $scheduledTime');
    debugPrint('🆔 ID da notificação: $notificationId');

    try {
      await _notifications.zonedSchedule(
        notificationId,
        '🧪 Teste Simples',
        'Esta notificação foi agendada para aparecer em $secondsFromNow segundos!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_simple',
            'Teste Simples',
            channelDescription: 'Notificações de teste simples',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 999,
            threadIdentifier: 'simple_test',
            categoryIdentifier: 'test',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'simple_test_notification',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // ✅ CORREÇÃO CRÍTICA: Usar allowWhileIdle para funcionar mesmo com otimizações de bateria
        // ✅ CORREÇÃO: Remover matchDateTimeComponents para agendar apenas uma vez
        // matchDateTimeComponents: DateTimeComponents.time, // ❌ Isso fazia repetir diariamente
      );

      debugPrint('✅ Notificação agendada com sucesso!');

      // Verificar se foi agendada
      await Future.delayed(const Duration(milliseconds: 500));
      final pending = await _notifications.pendingNotificationRequests();
      final found = pending.where((n) => n.id == notificationId).isNotEmpty
          ? pending.where((n) => n.id == notificationId).first
          : null;

      if (found != null) {
        debugPrint('✅ Confirmado: Notificação está na lista de pendentes');
      } else {
        debugPrint(
            '❌ PROBLEMA: Notificação NÃO foi encontrada na lista de pendentes!');
      }

      debugPrint(
          '🔔 Aguarde $secondsFromNow segundos para ver a notificação...');
    } catch (e) {
      debugPrint('❌ ERRO ao agendar teste simples: $e');
      debugPrint('💡 Stack trace: ${StackTrace.current}');
    }
  }

  /// Testa notificação de 10 segundos específica para Android
  Future<void> testAndroid10SecondsNotification({
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool lightsEnabled = true,
  }) async {
    if (!Platform.isAndroid) {
      debugPrint('⚠️ Teste específico apenas para Android');
      return;
    }

    debugPrint('🤖 === TESTE ANDROID 10 SEGUNDOS - INÍCIO ===');

    try {
      // Garante inicialização
      await _ensureInitialized();

      // Verifica permissões críticas
      await _checkAndroidCriticalPermissions();

      // Usa o mesmo canal que funciona para notificações imediatas
      await _createOrUpdateNotificationChannel(
        'immediate',
        'Notificações Imediatas',
        'Notificações que aparecem imediatamente',
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        lightsEnabled: lightsEnabled,
      );

      // Calcula tempo exato com mais precisão
      final now = DateTime.now();
      final notificationTime = now.add(const Duration(seconds: 10));

      // Converte para timezone local com debug
      final tzNow = tz.TZDateTime.now(tz.local);
      final tzNotificationTime = tzNow.add(const Duration(seconds: 10));

      debugPrint('⏰ === DEBUG TIMING ===');
      debugPrint('⏰ DateTime.now(): ${now.hour}:${now.minute}:${now.second}');
      debugPrint(
          '⏰ TZDateTime.now(): ${tzNow.hour}:${tzNow.minute}:${tzNow.second}');
      debugPrint(
          '⏰ Agendando para: ${tzNotificationTime.hour}:${tzNotificationTime.minute}:${tzNotificationTime.second}');
      debugPrint(
          '⏰ Diferença em segundos: ${tzNotificationTime.difference(tzNow).inSeconds}');
      debugPrint('⏰ Timezone: ${tz.local}');

      // Agenda com ID único e configurações forçadas
      const testId = 999999;

      // Usa zonedSchedule com abordagem mais simples
      debugPrint('🔄 Usando zonedSchedule com DateTime convertido...');

      await _notifications.zonedSchedule(
        testId,
        '🤖 TESTE ANDROID 10s',
        'Se você está vendo isso, o Android está funcionando! 🎉',
        tz.TZDateTime.from(
            notificationTime, tz.local), // Converte DateTime para TZDateTime
        NotificationDetails(
          android: AndroidNotificationDetails(
            'immediate',
            'Notificações Imediatas',
            channelDescription: 'Notificações que aparecem imediatamente',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: vibrationEnabled,
            enableLights: lightsEnabled,
            playSound: soundEnabled,
            // Configurações extras para forçar funcionamento
            vibrationPattern: vibrationEnabled
                ? Int64List.fromList([0, 1000, 500, 1000])
                : null,
            ledColor: lightsEnabled ? Colors.red : null,
            ledOnMs: lightsEnabled ? 2000 : null,
            ledOffMs: lightsEnabled ? 1000 : null,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            autoCancel: false,
            ongoing: false,
            showWhen: true,
            when: notificationTime.millisecondsSinceEpoch,
            // Usa som padrão do sistema se som estiver habilitado
            sound: null, // null usa o som padrão do canal
            // Configurações de canal
            channelShowBadge: true,
            onlyAlertOnce: false,
            // Configurações de apresentação
            ticker: 'Teste Android 10s',
            subText: 'Funcionou!',
            // Configurações de timing
            timeoutAfter: null, // Não expira automaticamente
          ),
        ),
        payload: 'android_10s_test',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('✅ Notificação de 10s agendada');

      // Verifica se foi agendado corretamente
      await Future.delayed(const Duration(milliseconds: 1000));
      final pending = await _notifications.pendingNotificationRequests();
      final testNotification = pending.where((n) => n.id == testId).toList();

      debugPrint('🔍 === VERIFICAÇÃO DETALHADA ===');
      debugPrint('📋 Total pendentes: ${pending.length}');
      debugPrint('🔍 Procurando ID: $testId');

      if (testNotification.isNotEmpty) {
        debugPrint('✅ CONFIRMADO: Teste de 10s está na lista pendente');
        debugPrint('  - ID: ${testNotification.first.id}');
        debugPrint('  - Título: ${testNotification.first.title}');
        debugPrint('  - Corpo: ${testNotification.first.body}');

        // Verifica se o horário está no futuro
        final agora = DateTime.now();
        final diferenca = notificationTime.difference(agora).inSeconds;
        debugPrint('⏰ Tempo restante: ${diferenca}s');

        if (diferenca <= 0) {
          debugPrint('❌ PROBLEMA: Notificação agendada para o passado!');
        } else if (diferenca > 15) {
          debugPrint(
              '❌ PROBLEMA: Notificação agendada muito longe (${diferenca}s)!');
        } else {
          debugPrint('✅ Timing correto: ${diferenca}s no futuro');
        }
      } else {
        debugPrint('❌ ERRO: Teste de 10s NÃO está na lista pendente!');
        debugPrint('📋 Todas as pendentes:');
        for (final notif in pending) {
          debugPrint('  - ID: ${notif.id}, Título: ${notif.title}');
        }
      }

      // Debug do sistema Android
      await debugAndroidSpecific();

      // TESTE ALTERNATIVO: Usar Timer para show() após 10 segundos
      debugPrint('🔄 === TESTE ALTERNATIVO COM TIMER ===');
      Timer(const Duration(seconds: 10), () async {
        debugPrint('⏰ Timer disparado! Enviando notificação imediata...');
        try {
          await _notifications.show(
            888888,
            '⏰ TIMER ANDROID 10s',
            'Esta notificação foi enviada via Timer após 10s!',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'immediate',
                'Notificações Imediatas',
                channelDescription: 'Notificações que aparecem imediatamente',
                importance: Importance.max,
                priority: Priority.max,
                icon: '@mipmap/ic_launcher',
                enableVibration: true,
                enableLights: true,
                playSound: true,
                vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
                ledColor: Colors.green,
                ledOnMs: 2000,
                ledOffMs: 1000,
                category: AndroidNotificationCategory.alarm,
                visibility: NotificationVisibility.public,
                ticker: 'Timer Test',
                subText: 'Via Timer!',
              ),
            ),
            payload: 'timer_test',
          );
          debugPrint('✅ Notificação via Timer enviada!');
        } catch (e) {
          debugPrint('❌ Erro na notificação via Timer: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ ERRO CRÍTICO no teste Android 10s: $e');
      debugPrint('💡 Stack trace: ${StackTrace.current}');
    }

    debugPrint('🤖 === TESTE ANDROID 10 SEGUNDOS - FIM ===');
  }

  /// Testa notificação de estacionamento real no Android usando método que funciona
  Future<void> testAndroidParkingNotification({
    required int reminderMinutes,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool lightsEnabled = true,
  }) async {
    if (!Platform.isAndroid) {
      debugPrint('⚠️ Teste específico apenas para Android');
      return;
    }

    debugPrint('🚗 === TESTE ESTACIONAMENTO ANDROID (MÉTODO DIRETO) ===');

    try {
      // Garante inicialização
      await _ensureInitialized();

      // Verifica permissões críticas
      await _checkAndroidCriticalPermissions();

      // ✅ CORREÇÃO: Usar exatamente o mesmo método que funciona para 10s
      await _createOrUpdateNotificationChannel(
        'immediate',
        'Notificações Imediatas',
        'Notificações que aparecem imediatamente',
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        lightsEnabled: lightsEnabled,
      );

      // Agenda para 2 minutos usando o método direto que funciona
      final now = DateTime.now();
      final notificationTime = now.add(const Duration(minutes: 2));
      const testId = 777777;

      debugPrint('🚗 Agendando teste direto:');
      debugPrint('  - ID: $testId');
      debugPrint('  - Horário atual: ${now.hour}:${now.minute}:${now.second}');
      debugPrint(
          '  - Notificação em: ${notificationTime.hour}:${notificationTime.minute}:${notificationTime.second}');
      debugPrint(
          '  - Diferença: ${notificationTime.difference(now).inMinutes} minutos');

      await _notifications.zonedSchedule(
        testId,
        '🚗 TESTE ESTACIONAMENTO 2min',
        'Notificação de estacionamento Android funcionando! 🎉',
        tz.TZDateTime.from(notificationTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'immediate', // Mesmo canal que funciona
            'Notificações Imediatas',
            channelDescription: 'Notificações que aparecem imediatamente',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: vibrationEnabled,
            enableLights: lightsEnabled,
            playSound: soundEnabled,
            vibrationPattern: vibrationEnabled
                ? Int64List.fromList([0, 1000, 500, 1000])
                : null,
            ledColor: lightsEnabled ? Colors.orange : null,
            ledOnMs: lightsEnabled ? 2000 : null,
            ledOffMs: lightsEnabled ? 1000 : null,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            autoCancel: false,
            ongoing: false,
            showWhen: true,
            when: notificationTime.millisecondsSinceEpoch,
            sound: null, // Usa som padrão do canal
            channelShowBadge: true,
            onlyAlertOnce: false,
            ticker: 'Teste Estacionamento 2min',
            subText: 'Funcionou!',
            timeoutAfter: null,
          ),
        ),
        payload: 'android_parking_2min_test',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('✅ Teste de 2 minutos agendado usando método que funciona!');

      // Verifica se foi agendada
      await Future.delayed(const Duration(milliseconds: 500));
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      final scheduledNotification =
          pendingNotifications.where((n) => n.id == testId).isNotEmpty;

      debugPrint('🔍 Verificação pós-agendamento:');
      debugPrint('  - Total pendentes: ${pendingNotifications.length}');
      debugPrint('  - Teste 2min encontrado: $scheduledNotification');

      if (scheduledNotification) {
        debugPrint('✅ CONFIRMADO: Teste de 2min está na lista pendente');
      } else {
        debugPrint('❌ PROBLEMA: Teste de 2min NÃO está na lista pendente');
      }
    } catch (e) {
      debugPrint('❌ ERRO no teste de estacionamento Android: $e');
      debugPrint('💡 Stack trace: ${StackTrace.current}');
    }

    debugPrint('🚗 === FIM TESTE ESTACIONAMENTO ANDROID ===');
  }

  /// Teste simples de 30 segundos para verificar se é problema de tempo
  Future<void> testAndroid30Seconds() async {
    if (!Platform.isAndroid) return;

    debugPrint('⏱️ === TESTE ANDROID 30 SEGUNDOS ===');

    // ✅ Cancela notificações de teste antigas primeiro
    try {
      await _notifications.cancel(666666); // ID do teste de 30s
      await _notifications.cancel(555555); // ID do fallback
      debugPrint('🧹 Notificações antigas de teste canceladas');
    } catch (e) {
      debugPrint('⚠️ Erro ao cancelar notificações antigas: $e');
    }

    try {
      await _ensureInitialized();

      await _createOrUpdateNotificationChannel(
        'immediate',
        'Notificações Imediatas',
        'Notificações que aparecem imediatamente',
        soundEnabled: true,
        vibrationEnabled: true,
        lightsEnabled: true,
      );

      final now = DateTime.now();
      final notificationTime = now.add(const Duration(seconds: 30));
      const testId = 666666;

      debugPrint('⏱️ Agendando para 30 segundos...');
      debugPrint('  - Horário atual: ${now.hour}:${now.minute}:${now.second}');
      debugPrint(
          '  - Horário target: ${notificationTime.hour}:${notificationTime.minute}:${notificationTime.second}');

      // ✅ CORREÇÃO: Usar abordagem mais direta para timezone
      final tzNotificationTime =
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30));

      debugPrint('  - TZDateTime.now(): ${tz.TZDateTime.now(tz.local)}');
      debugPrint('  - TZDateTime target: $tzNotificationTime');
      debugPrint(
          '  - Diferença: ${tzNotificationTime.difference(tz.TZDateTime.now(tz.local)).inSeconds} segundos');
      debugPrint('  - Timezone: ${tz.local}');

      await _notifications.zonedSchedule(
        testId,
        '⏱️ TESTE 30s',
        'Teste de 30 segundos funcionou!',
        tzNotificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'immediate',
            'Notificações Imediatas',
            channelDescription: 'Notificações que aparecem imediatamente',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            enableLights: true,
            playSound: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
          ),
        ),
        payload: 'test_30s',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('✅ Teste de 30s agendado!');

      // ✅ Verifica se foi realmente agendado
      await Future.delayed(const Duration(milliseconds: 500));
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      final scheduledNotification =
          pendingNotifications.where((n) => n.id == testId).isNotEmpty;

      debugPrint('🔍 Verificação pós-agendamento 30s:');
      debugPrint('  - Total pendentes: ${pendingNotifications.length}');
      debugPrint('  - Teste 30s encontrado: $scheduledNotification');

      if (!scheduledNotification) {
        debugPrint('❌ PROBLEMA: Teste de 30s NÃO foi agendado corretamente');
      }

      // ✅ FALLBACK: Timer para garantir que funcione
      Timer(const Duration(seconds: 30), () async {
        debugPrint('⏰ Timer 30s disparado! Enviando notificação imediata...');
        try {
          await _notifications.show(
            555555, // ID diferente para fallback
            '⏰ TESTE 30s',
            'Notificação de 30 segundos funcionou!',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'immediate',
                'Notificações Imediatas',
                channelDescription: 'Notificações que aparecem imediatamente',
                importance: Importance.max,
                priority: Priority.max,
                icon: '@mipmap/ic_launcher',
                enableVibration: true,
                enableLights: true,
                playSound: true,
                category: AndroidNotificationCategory.alarm,
                visibility: NotificationVisibility.public,
              ),
            ),
            payload: 'test_30s_timer',
          );
          debugPrint('✅ Notificação via Timer 30s enviada!');
        } catch (e) {
          debugPrint('❌ Erro na notificação via Timer 30s: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ ERRO no teste de 30s: $e');
    }
  }

  /// Verifica permissões críticas para Android
  Future<void> _checkAndroidCriticalPermissions() async {
    debugPrint('🔐 === VERIFICANDO PERMISSÕES CRÍTICAS ===');

    final notificationStatus = await Permission.notification.status;
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    debugPrint('  - Notificação: $notificationStatus');
    debugPrint('  - Alarme Exato: $exactAlarmStatus');
    debugPrint('  - Ignorar Bateria: $batteryStatus');

    // Solicita permissões se necessário
    if (notificationStatus.isDenied) {
      debugPrint('⚠️ Solicitando permissão de notificação...');
      await Permission.notification.request();
    }

    if (exactAlarmStatus.isDenied) {
      debugPrint('⚠️ Solicitando permissão de alarme exato...');
      await Permission.scheduleExactAlarm.request();
    }

    if (batteryStatus.isDenied) {
      debugPrint(
          '⚠️ Solicitando permissão para ignorar otimizações de bateria...');
      await Permission.ignoreBatteryOptimizations.request();
    }

    // Verifica novamente após solicitar
    final newNotificationStatus = await Permission.notification.status;
    final newExactAlarmStatus = await Permission.scheduleExactAlarm.status;
    final newBatteryStatus = await Permission.ignoreBatteryOptimizations.status;

    debugPrint('🔐 === STATUS FINAL DAS PERMISSÕES ===');
    debugPrint('  - Notificação: $newNotificationStatus');
    debugPrint('  - Alarme Exato: $newExactAlarmStatus');
    debugPrint('  - Ignorar Bateria: $newBatteryStatus');

    if (!newNotificationStatus.isGranted) {
      debugPrint('❌ CRÍTICO: Permissão de notificação negada!');
    }
    if (!newExactAlarmStatus.isGranted) {
      debugPrint('❌ CRÍTICO: Permissão de alarme exato negada!');
    }
    if (!newBatteryStatus.isGranted) {
      debugPrint(
          '⚠️ AVISO: Otimizações de bateria ativas - pode impedir notificações!');
    }
  }

  /// Força teste específico para Android com debugging extenso
  Future<void> forceAndroidScheduledTest({
    required int reminderMinutes,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool lightsEnabled = true,
  }) async {
    if (!Platform.isAndroid) {
      debugPrint('⚠️ Teste específico apenas para Android');
      return;
    }

    debugPrint('🤖 === INICIANDO TESTE FORÇADO ANDROID ===');

    // Verifica estado do sistema
    await debugAndroidSpecific();

    // Calcula tempos
    final now = DateTime.now();
    final expirationTime =
        now.add(Duration(minutes: reminderMinutes, seconds: 10));
    final notificationTime =
        expirationTime.subtract(Duration(minutes: reminderMinutes));

    debugPrint('⏰ Tempos calculados:');
    debugPrint('  - Agora: ${now.hour}:${now.minute}:${now.second}');
    debugPrint(
        '  - Expira: ${expirationTime.hour}:${expirationTime.minute}:${expirationTime.second}');
    debugPrint(
        '  - Notifica: ${notificationTime.hour}:${notificationTime.minute}:${notificationTime.second}');
    debugPrint(
        '  - Segundos até notificação: ${notificationTime.difference(now).inSeconds}');

    // Força criação do canal
    await _createOrUpdateNotificationChannel(
      'android_force_test',
      'Teste Forçado Android',
      'Canal para teste forçado no Android',
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      lightsEnabled: lightsEnabled,
    );

    // Verifica permissões
    final notificationPermission = await Permission.notification.status;
    final exactAlarmPermission = await Permission.scheduleExactAlarm.status;
    final batteryPermission =
        await Permission.ignoreBatteryOptimizations.status;

    debugPrint('🔐 Status das permissões:');
    debugPrint('  - Notificação: $notificationPermission');
    debugPrint('  - Alarme exato: $exactAlarmPermission');
    debugPrint('  - Ignorar bateria: $batteryPermission');

    final canScheduleExact = exactAlarmPermission.isGranted;

    try {
      // Agenda com configurações máximas para Android
      await _notifications.zonedSchedule(
        888888, // ID único para teste forçado
        '🤖 TESTE FORÇADO ANDROID',
        'Esta notificação deve aparecer em ${notificationTime.difference(now).inSeconds} segundos (${reminderMinutes}min antes do vencimento)',
        tz.TZDateTime.from(notificationTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'android_force_test',
            'Teste Forçado Android',
            channelDescription: 'Canal para teste forçado no Android',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            enableVibration: vibrationEnabled,
            enableLights: lightsEnabled,
            playSound: soundEnabled,
            // Configurações extras para forçar funcionamento
            vibrationPattern: vibrationEnabled
                ? Int64List.fromList([0, 500, 250, 500])
                : null,
            ledColor: lightsEnabled ? Colors.red : null,
            ledOnMs: lightsEnabled ? 1000 : null,
            ledOffMs: lightsEnabled ? 500 : null,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
            autoCancel: false, // Não remove automaticamente
            ongoing: false,
            showWhen: true,
            when: notificationTime.millisecondsSinceEpoch,
            usesChronometer: false,
            chronometerCountDown: false,
            // Força som e vibração (usa som padrão do sistema)
            sound: null, // null usa o som padrão do canal
          ),
        ),
        payload: 'android_force_test:TESTE123',
        androidScheduleMode: canScheduleExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );

      debugPrint('✅ Teste forçado agendado com sucesso!');

      // Verifica se foi agendado
      await Future.delayed(const Duration(seconds: 1));
      final pending = await _notifications.pendingNotificationRequests();
      final testNotification = pending.where((n) => n.id == 888888).toList();

      debugPrint('📊 Verificação pós-agendamento:');
      debugPrint('  - Total pendentes: ${pending.length}');
      debugPrint('  - Teste encontrado: ${testNotification.length}');

      if (testNotification.isNotEmpty) {
        final notification = testNotification.first;
        debugPrint('✅ CONFIRMADO: Teste está na lista de pendentes');
        debugPrint('  - ID: ${notification.id}');
        debugPrint('  - Título: ${notification.title}');
        debugPrint('  - Corpo: ${notification.body}');
      } else {
        debugPrint('❌ PROBLEMA CRÍTICO: Teste NÃO está na lista de pendentes!');

        // Lista todas as pendentes para debug
        debugPrint('📋 Todas as notificações pendentes:');
        for (final notification in pending) {
          debugPrint(
              '  - ID: ${notification.id}, Título: ${notification.title}');
        }
      }
    } catch (e) {
      debugPrint('❌ ERRO CRÍTICO no teste forçado: $e');
      debugPrint('💡 Stack trace: ${StackTrace.current}');
    }

    debugPrint('🤖 === FIM TESTE FORÇADO ANDROID ===');
  }

  /// Cria ou atualiza um canal de notificação com configurações específicas
  Future<void> _createOrUpdateNotificationChannel(
    String channelId,
    String channelName,
    String channelDescription, {
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool lightsEnabled = true,
  }) async {
    debugPrint('🔔 Criando/atualizando canal: $channelId');
    debugPrint('  - Som: $soundEnabled');
    debugPrint('  - Vibração: $vibrationEnabled');
    debugPrint('  - Luzes: $lightsEnabled');

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance
                .max, // ✅ Importância máxima para garantir som e vibração
            enableVibration: vibrationEnabled,
            enableLights: lightsEnabled,
            playSound: soundEnabled,
            showBadge: true,
            // ✅ Configurações adicionais para garantir funcionamento (usa som padrão)
            sound: null, // null usa o som padrão do canal
          ),
        );

    debugPrint('🔔 Canal $channelId criado/atualizado com sucesso');
  }
}

/// Provider para o serviço de notificações locais
final localNotificationServiceProvider =
    Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});
