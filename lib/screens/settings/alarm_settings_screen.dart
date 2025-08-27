import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alarm_settings_provider.dart';
import '../../services/local_notification_service.dart';
import 'dart:io' show Platform;

class AlarmSettingsScreen extends ConsumerWidget {
  const AlarmSettingsScreen({super.key});

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

            // Test notification button
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
                    'Testar Notificações',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Envie uma notificação de teste para verificar se está funcionando',
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
                          onPressed: () => _sendTestNotification(
                              context, localNotificationService),
                          icon: const Icon(Icons.send),
                          label: const Text('Notificação imediata'),
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
                          onPressed: () => _scheduleTestNotification(
                              context, localNotificationService),
                          icon: const Icon(Icons.schedule),
                          label: const Text('Agendar teste'),
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
                  // ✅ Botão específico para iOS
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _testIOSNotification(
                            context, localNotificationService),
                        icon: const Icon(Icons.apple),
                        label: const Text('🍎 Teste Específico iOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
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
                ],
              ),
            ),

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
        value: reminderMinutes,
        underline: const SizedBox(),
        items: reminderOptions.map((minutes) {
          return DropdownMenuItem<int>(
            value: minutes,
            child: Text('${minutes}min'),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _sendTestNotification(
      BuildContext context, LocalNotificationService service) async {
    try {
      // Configurações de som, vibração e luzes sempre ativadas por padrão
      await service.showImmediateNotification(
        title: 'Teste de Notificação',
        body:
            'Esta é uma notificação de teste para verificar se o sistema está funcionando',
        soundEnabled: true,
        vibrationEnabled: true,
        lightsEnabled: true,
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
                        'Notificação de teste enviada!')), // ✅ Texto mais conciso
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao enviar notificação: $e')),
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

  void _scheduleTestNotification(
      BuildContext context, LocalNotificationService service) async {
    try {
      // Configurações de som, vibração e luzes sempre ativadas por padrão
      await service.scheduleTestNotification(
        soundEnabled: true,
        vibrationEnabled: true,
        lightsEnabled: true,
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
                        'Notificação de teste agendada!')), // ✅ Texto mais conciso
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao agendar notificação: $e')),
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

  void _testIOSNotification(
      BuildContext context, LocalNotificationService service) async {
    try {
      // Configurações de som, vibração e luzes sempre ativadas por padrão
      await service.showImmediateNotification(
        title: 'Teste de Notificação iOS',
        body: 'Esta é uma notificação de teste específica para iOS.',
        soundEnabled: true,
        vibrationEnabled: true,
        lightsEnabled: true,
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
                        'Notificação de teste iOS enviada!')), // ✅ Texto mais conciso
              ],
            ),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao enviar notificação iOS: $e')),
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
}
