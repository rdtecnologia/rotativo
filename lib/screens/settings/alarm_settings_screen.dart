import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alarm_settings_provider.dart';

class AlarmSettingsScreen extends ConsumerWidget {
  const AlarmSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar ref.read para obter o notifier apenas uma vez
    final alarmNotifier = ref.read(alarmSettingsProvider.notifier);

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

            // Notification settings
            _buildSettingsCard(
              context,
              'Notificações de Estacionamento',
              [
                _buildSwitchTile(
                  context,
                  title: 'Vencimento do estacionamento',
                  subtitle: 'Aviso antes do tempo expirar',
                  value: false,
                  onChanged: (value) {
                    alarmNotifier.updateParkingExpiration(value);
                  },
                  icon: Icons.timer,
                  isConsumer: true,
                ),
                _buildReminderTimeSection(context, alarmNotifier),
              ],
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
              context,
              'Notificações de Pagamento',
              [
                _buildSwitchTile(
                  context,
                  title: 'Lembrete de pagamento',
                  subtitle: 'Aviso sobre pagamentos pendentes',
                  value: false,
                  onChanged: (value) {
                    alarmNotifier.updatePaymentReminders(value);
                  },
                  icon: Icons.payment,
                  isConsumer: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
              context,
              'Outras Notificações',
              [
                _buildSwitchTile(
                  context,
                  title: 'Promoções e ofertas',
                  subtitle: 'Receber ofertas especiais',
                  value: false,
                  onChanged: (value) {
                    alarmNotifier.updatePromotions(value);
                  },
                  icon: Icons.local_offer,
                  isConsumer: true,
                ),
                const Divider(),
                _buildSwitchTile(
                  context,
                  title: 'Atualizações do sistema',
                  subtitle: 'Notificações importantes do app',
                  value: false,
                  onChanged: (value) {
                    alarmNotifier.updateSystemUpdates(value);
                  },
                  icon: Icons.system_update,
                  isConsumer: true,
                ),
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
                  ElevatedButton.icon(
                    onPressed: () => _sendTestNotification(context),
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar notificação de teste'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
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
    required ValueChanged<bool> onChanged,
    required IconData icon,
    bool isConsumer = false,
  }) {
    if (isConsumer) {
      return Consumer(
        builder: (context, ref, child) {
          // Determinar qual valor observar baseado no título
          bool currentValue;
          if (title.contains('Vencimento')) {
            currentValue = ref.watch(alarmSettingsProvider
                .select((settings) => settings.parkingExpiration));
          } else if (title.contains('pagamento')) {
            currentValue = ref.watch(alarmSettingsProvider
                .select((settings) => settings.paymentReminders));
          } else if (title.contains('Promoções')) {
            currentValue = ref.watch(alarmSettingsProvider
                .select((settings) => settings.promotions));
          } else if (title.contains('sistema')) {
            currentValue = ref.watch(alarmSettingsProvider
                .select((settings) => settings.systemUpdates));
          } else {
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
              onChanged: onChanged,
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
        onChanged: onChanged,
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
              onChanged: (value) {
                if (value != null) {
                  alarmNotifier.updateReminderMinutes(value);
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

  void _sendTestNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Notificação de teste enviada!'),
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

    // TODO: Implement actual test notification
    // NotificationService.sendTestNotification();
  }
}
