import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../providers/alarm_settings_provider.dart';
import '../../services/local_notification_service.dart';
import '../../config/environment.dart';

class AlarmSettingsScreen extends ConsumerWidget {
  const AlarmSettingsScreen({super.key});

  /// Verifica se deve mostrar o card de teste de notificações
  /// Esconde em produção quando o build é release
  bool _shouldShowTestCard() {
    // Se for ambiente de produção E build release, esconder o card
    if (Environment.currentEnvironment == 'prod' && kReleaseMode) {
      return false;
    }
    // Em todos os outros casos, mostrar o card
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar ref.read para obter o notifier apenas uma vez
    final alarmNotifier = ref.read(alarmSettingsProvider.notifier);
    final localNotificationService = ref.read(localNotificationServiceProvider);
    final alarmSettings = ref.watch(alarmSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar alarmes'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Notificações e Alarmes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure como deseja ser notificado',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Configurações gerais de notificações
            _buildSettingsCard(
              context,
              'Configurações Gerais',
              [
                _buildSwitchTile(
                  context,
                  title: 'Notificações locais',
                  subtitle: 'Receber notificações mesmo com o app fechado',
                  value: alarmSettings.localNotificationsEnabled,
                  onChanged: (value) async {
                    await alarmNotifier.updateLocalNotificationsEnabled(value);
                  },
                  icon: Icons.notifications,
                  isConsumer: true,
                  consumerKey: 'localNotifications',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notification settings
            _buildSettingsCard(
              context,
              'Notificações de Estacionamento',
              [
                _buildSwitchTile(
                  context,
                  title: 'Vencimento de estacionamento',
                  subtitle: 'Aviso antes do vencimento',
                  value: alarmSettings.parkingExpiration,
                  onChanged: (value) async {
                    await alarmNotifier.updateParkingExpiration(value);
                  },
                  icon: Icons.timer,
                  isConsumer: true,
                  consumerKey: 'parkingExpiration',
                ),
                _buildReminderTimeSection(context, alarmNotifier),
              ],
            ),

            const SizedBox(height: 32),

            // Test notification button - Only show if not in production release
            if (_shouldShowTestCard()) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 32,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Teste de Notificações',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Teste o funcionamento das notificações agendadas',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _testImmediateNotification(
                                context, localNotificationService, ref),
                            icon: const Icon(Icons.send),
                            label: const Text('Imediata'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _testScheduled10Seconds(
                                context, localNotificationService, ref),
                            icon: const Icon(Icons.schedule),
                            label: const Text('10 segundos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Botões de teste para Android
                    if (Platform.isAndroid) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _test30Seconds(
                                  context, localNotificationService),
                              icon: const Icon(Icons.timer),
                              label: const Text('30s'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _testAndroidParkingNotification(
                                  context, localNotificationService, ref),
                              icon: const Icon(Icons.local_parking),
                              label: const Text('2min'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required dynamic Function(bool) onChanged,
    required IconData icon,
    bool isConsumer = false,
    String? consumerKey,
  }) {
    if (isConsumer) {
      return Consumer(
        builder: (context, ref, child) {
          // Determinar qual valor observar baseado na chave do consumer
          bool currentValue;
          switch (consumerKey) {
            case 'localNotifications':
              currentValue = ref.watch(alarmSettingsProvider
                  .select((settings) => settings.localNotificationsEnabled));
              break;
            case 'parkingExpiration':
              currentValue = ref.watch(alarmSettingsProvider
                  .select((settings) => settings.parkingExpiration));
              break;
            case 'paymentReminders':
              currentValue = ref.watch(alarmSettingsProvider
                  .select((settings) => settings.paymentReminders));
              break;
            case 'promotions':
              currentValue = ref.watch(alarmSettingsProvider
                  .select((settings) => settings.promotions));
              break;
            case 'systemUpdates':
              currentValue = ref.watch(alarmSettingsProvider
                  .select((settings) => settings.systemUpdates));
              break;
            default:
              currentValue = value;
          }

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            trailing: Switch(
              value: currentValue,
              onChanged: (value) {
                final result = onChanged(value);
                if (result is Future) {
                  // Ignora o resultado se for assíncrono
                }
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          );
        },
      );
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (value) {
          final result = onChanged(value);
          if (result is Future) {
            // Ignora o resultado se for assíncrono
          }
        },
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildReminderTimeSection(
      BuildContext context, dynamic alarmNotifier) {
    return Consumer(
      builder: (context, ref, child) {
        final parkingExpiration = ref.watch(alarmSettingsProvider
            .select((settings) => settings.parkingExpiration));

        if (!parkingExpiration) return const SizedBox.shrink();

        return Column(
          children: [
            const Divider(),
            _buildReminderTimeTile(
              context,
              reminderMinutes: ref.watch(alarmSettingsProvider
                  .select((settings) => settings.reminderMinutes)),
              reminderOptions: alarmNotifier.reminderOptions,
              onChanged: (value) async {
                if (value != null) {
                  await alarmNotifier.updateReminderMinutes(value);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildReminderTimeTile(
    BuildContext context, {
    required int reminderMinutes,
    required List<int> reminderOptions,
    required ValueChanged<int?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.schedule,
          color: Colors.orange,
          size: 20,
        ),
      ),
      title: const Text(
        'Tempo de antecedência',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Avisar $reminderMinutes minutos antes',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      trailing: DropdownButton<int>(
        value: reminderOptions.contains(reminderMinutes)
            ? reminderMinutes
            : reminderOptions.first,
        underline: const SizedBox(),
        items: (reminderOptions.toSet().toList()..sort()).map((minutes) {
          return DropdownMenuItem<int>(
            value: minutes,
            child: Text('${minutes}min'),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  /// Testa notificação imediata
  void _testImmediateNotification(BuildContext context,
      LocalNotificationService service, WidgetRef ref) async {
    try {
      final alarmSettings = ref.read(alarmSettingsProvider);

      debugPrint('🔔 === TESTE DE NOTIFICAÇÃO IMEDIATA ===');

      await service.showImmediateNotification(
        title: 'Teste Imediato',
        body: 'Esta é uma notificação de teste imediata!',
        soundEnabled: alarmSettings.soundEnabled,
        vibrationEnabled: alarmSettings.vibrationEnabled,
        lightsEnabled: alarmSettings.lightsEnabled,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Notificação imediata enviada!')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ERRO no teste de notificação imediata: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro no teste: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Testa notificação agendada para 10 segundos
  void _testScheduled10Seconds(BuildContext context,
      LocalNotificationService service, WidgetRef ref) async {
    try {
      final alarmSettings = ref.read(alarmSettingsProvider);

      debugPrint('🔔 === TESTE DE NOTIFICAÇÃO AGENDADA 10 SEGUNDOS ===');

      if (!alarmSettings.localNotificationsEnabled ||
          !alarmSettings.parkingExpiration) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        'Ative as notificações locais e de vencimento para testar'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return;
      }

      // Usa método específico para Android se for Android, senão usa método padrão
      if (Platform.isAndroid) {
        debugPrint('🤖 Usando método específico para Android');
        await service.testAndroid10SecondsNotification(
          soundEnabled: alarmSettings.soundEnabled,
          vibrationEnabled: alarmSettings.vibrationEnabled,
          lightsEnabled: alarmSettings.lightsEnabled,
        );
      } else {
        debugPrint('🍎 Usando método padrão para iOS');
        // Para iOS, usa o método normal que já funciona
        final testExpirationTime =
            DateTime.now().add(const Duration(seconds: 10));

        await service.scheduleParkingExpirationNotification(
          licensePlate: 'TESTE10S',
          expirationTime: testExpirationTime,
          reminderMinutes: 0, // Notificação no momento da expiração
          location: 'Teste 10 segundos',
          soundEnabled: alarmSettings.soundEnabled,
          vibrationEnabled: alarmSettings.vibrationEnabled,
          lightsEnabled: alarmSettings.lightsEnabled,
        );

        debugPrint('✅ Teste iOS de 10 segundos agendado:');
        debugPrint(
            '  - Notificação em: ${testExpirationTime.hour}:${testExpirationTime.minute}:${testExpirationTime.second}');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Notificação agendada para 10 segundos!')),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ERRO no teste de 10 segundos: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro no teste: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Testa notificação de estacionamento real no Android
  void _testAndroidParkingNotification(BuildContext context,
      LocalNotificationService service, WidgetRef ref) async {
    try {
      final alarmSettings = ref.read(alarmSettingsProvider);

      debugPrint('🚗 === TESTE DE ESTACIONAMENTO ANDROID ===');

      if (!alarmSettings.localNotificationsEnabled ||
          !alarmSettings.parkingExpiration) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        'Ative as notificações locais e de vencimento para testar'),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return;
      }

      // ✅ CORREÇÃO: Testa usando o método real de estacionamento corrigido
      final testExpirationTime = DateTime.now()
          .add(Duration(minutes: alarmSettings.reminderMinutes + 2));

      await service.scheduleParkingExpirationNotification(
        licensePlate: 'TESTE-REAL-ANDROID',
        expirationTime: testExpirationTime,
        reminderMinutes: alarmSettings.reminderMinutes,
        location: 'Teste Método Real Android',
        soundEnabled: alarmSettings.soundEnabled,
        vibrationEnabled: alarmSettings.vibrationEnabled,
        lightsEnabled: alarmSettings.lightsEnabled,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Teste de estacionamento agendado para 2 minutos!')),
              ],
            ),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ERRO no teste de estacionamento Android: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro no teste: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Testa notificação de 30 segundos
  void _test30Seconds(
      BuildContext context, LocalNotificationService service) async {
    try {
      await service.testAndroid30Seconds();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Teste de 30 segundos agendado!')),
              ],
            ),
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ERRO no teste de 30s: $e');
    }
  }
}
