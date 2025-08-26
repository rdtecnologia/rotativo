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

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    try {
      // Inicializa timezone
      tz.initializeTimeZones();

      // Aguarda um momento para garantir que o banco de dados seja carregado
      await Future.delayed(const Duration(milliseconds: 200));

      // Define timezone padrão para Brasil
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

      debugPrint('🌍 Timezone inicializado: America/Sao_Paulo');

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

      debugPrint('🔔 Serviço de notificações inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar serviço de notificações: $e');
      rethrow;
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

      debugPrint('🔔 Status das permissões:');
      debugPrint('  - Notificação: ${await Permission.notification.status}');
      debugPrint(
          '  - Alarme Exato: ${await Permission.scheduleExactAlarm.status}');
    } catch (e) {
      debugPrint('⚠️ Erro ao solicitar permissões: $e');
    }
  }

  /// Callback quando uma notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificação tocada: ${response.payload}');
    // TODO: Implementar navegação baseada no payload
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
    // Calcula o horário da notificação
    final notificationTime =
        expirationTime.subtract(Duration(minutes: reminderMinutes));

    // Se o horário já passou, não agenda
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('⏰ Horário de notificação já passou para $licensePlate');
      return;
    }

    // Cria ou atualiza o canal de notificação com as configurações
    await _createOrUpdateNotificationChannel(
      'parking_expiration',
      'Vencimento de Estacionamento',
      'Notificações sobre vencimento de estacionamento',
      soundEnabled: soundEnabled ?? true,
      vibrationEnabled: vibrationEnabled ?? true,
      lightsEnabled: lightsEnabled ?? true,
    );

    // ID único para a notificação
    final notificationId =
        _generateNotificationId(licensePlate, reminderMinutes);

    // Calcula o delay até a notificação
    final delay = notificationTime.difference(DateTime.now());

    debugPrint('🔔 Agendando notificação para $licensePlate:');
    debugPrint('  - Expira às: ${expirationTime.toString()}');
    debugPrint('  - Notificação em: $reminderMinutes minutos');
    debugPrint('  - Delay: ${delay.inSeconds} segundos');

    // Solução robusta: usa Timer.delayed para garantir funcionamento
    Timer(delay, () async {
      try {
        await _notifications.show(
          notificationId,
          'Estacionamento expirando',
          'O estacionamento do veículo $licensePlate expira em $reminderMinutes minutos${location != null ? ' em $location' : ''}',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'parking_expiration',
              'Vencimento de Estacionamento',
              channelDescription:
                  'Notificações sobre vencimento de estacionamento',
              importance: Importance.max,
              priority: Priority.max,
              color: Colors.orange,
              icon: 'ic_notification',
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
        );

        debugPrint(
            '🔔 Notificação de estacionamento exibida para $licensePlate!');
      } catch (e) {
        debugPrint(
            '❌ Erro ao exibir notificação de estacionamento para $licensePlate: $e');
      }
    });

    debugPrint(
        '🔔 Timer de notificação configurado para $licensePlate em ${delay.inSeconds} segundos');
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

  /// Mostra uma notificação imediata (para testes)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? lightsEnabled,
  }) async {
    try {
      // ✅ Verificação específica para iOS
      if (Platform.isIOS) {
        debugPrint('🍎 iOS detectado - Configurando notificações específicas');

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

        debugPrint('🍎 Notificação iOS enviada com sucesso');

        // ✅ Para emulador iOS, vamos aguardar um pouco e verificar se apareceu
        await Future.delayed(const Duration(seconds: 2));

        // ✅ Se estiver no emulador, vamos mostrar um log adicional
        if (kDebugMode) {
          debugPrint(
              '🍎 Emulador iOS detectado - Verifique o Centro de Notificações');
          debugPrint(
              '🍎 Dica: Puxe para baixo no topo da tela para ver notificações');
        }

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

      debugPrint('🔔 Enviando notificação imediata:');
      debugPrint('  - Som: $soundEnabled');
      debugPrint('  - Vibração: $vibrationEnabled');
      debugPrint('  - Luzes: $lightsEnabled');

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
            icon: 'ic_notification',
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

      debugPrint('🔔 Notificação imediata enviada com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao enviar notificação imediata: $e');
    }
  }

  /// Lista todas as notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
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
    // Verifica permissões antes de agendar
    final notificationPermission = await Permission.notification.status;
    final exactAlarmPermission = await Permission.scheduleExactAlarm.status;

    debugPrint('🔔 Verificando permissões antes do teste:');
    debugPrint('  - Notificação: $notificationPermission');
    debugPrint('  - Alarme Exato: $exactAlarmPermission');

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

    // Solução mais robusta: usa Timer.delayed para garantir que funcione
    Timer(const Duration(seconds: 5), () async {
      try {
        await _notifications.show(
          999999, // ID de teste
          'Teste de Notificação',
          'Esta é uma notificação de teste!',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'test',
              'Teste',
              channelDescription: 'Notificações de teste',
              importance: Importance.max,
              priority: Priority.max,
              icon: 'ic_notification',
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
        );

        debugPrint('🧪 Notificação de teste exibida com sucesso!');
        debugPrint(
            '🧪 Configurações aplicadas: Som=$soundEnabled, Vibração=$vibrationEnabled, Luzes=$lightsEnabled');
      } catch (e) {
        debugPrint('❌ Erro ao exibir notificação de teste: $e');
      }
    });

    debugPrint('🧪 Timer de teste configurado para 5 segundos');
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
            // ✅ Não especifica som específico - deixa a notificação individual controlar
            sound: null,
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
