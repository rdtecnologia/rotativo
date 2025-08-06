import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmSettingsScreen extends ConsumerStatefulWidget {
  const AlarmSettingsScreen({super.key});

  @override
  ConsumerState<AlarmSettingsScreen> createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends ConsumerState<AlarmSettingsScreen> {
  bool _parkingExpiration = true;
  bool _paymentReminders = true;
  bool _promotions = false;
  bool _systemUpdates = true;
  
  int _reminderMinutes = 15;
  final List<int> _reminderOptions = [5, 10, 15, 30, 60];

  @override
  Widget build(BuildContext context) {
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
              'Notificações de Estacionamento',
              [
                _buildSwitchTile(
                  title: 'Vencimento do estacionamento',
                  subtitle: 'Aviso antes do tempo expirar',
                  value: _parkingExpiration,
                  onChanged: (value) {
                    setState(() {
                      _parkingExpiration = value;
                    });
                  },
                  icon: Icons.timer,
                ),
                if (_parkingExpiration) ...[
                  const Divider(),
                  _buildReminderTimeTile(),
                ],
              ],
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
              'Notificações de Pagamento',
              [
                _buildSwitchTile(
                  title: 'Lembrete de pagamento',
                  subtitle: 'Aviso sobre pagamentos pendentes',
                  value: _paymentReminders,
                  onChanged: (value) {
                    setState(() {
                      _paymentReminders = value;
                    });
                  },
                  icon: Icons.payment,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
              'Outras Notificações',
              [
                _buildSwitchTile(
                  title: 'Promoções e ofertas',
                  subtitle: 'Receber ofertas especiais',
                  value: _promotions,
                  onChanged: (value) {
                    setState(() {
                      _promotions = value;
                    });
                  },
                  icon: Icons.local_offer,
                ),
                const Divider(),
                _buildSwitchTile(
                  title: 'Atualizações do sistema',
                  subtitle: 'Notificações importantes do app',
                  value: _systemUpdates,
                  onChanged: (value) {
                    setState(() {
                      _systemUpdates = value;
                    });
                  },
                  icon: Icons.system_update,
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
                    onPressed: _sendTestNotification,
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

  Widget _buildSettingsCard(String title, List<Widget> children) {
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
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

  Widget _buildReminderTimeTile() {
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
        'Avisar $_reminderMinutes minutos antes',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      trailing: DropdownButton<int>(
        value: _reminderMinutes,
        underline: const SizedBox(),
        items: _reminderOptions.map((minutes) {
          return DropdownMenuItem<int>(
            value: minutes,
            child: Text('${minutes}min'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _reminderMinutes = value;
            });
          }
        },
      ),
    );
  }

  void _sendTestNotification() {
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