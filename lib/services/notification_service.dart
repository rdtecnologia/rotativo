import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Serviço para gerenciar notificações relacionadas às ativações
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Mostra notificação quando uma ativação está próxima de expirar
  void showExpiringSoonNotification(
      BuildContext context, String licensePlate, int remainingMinutes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Estacionamento do veículo $licensePlate expira em $remainingMinutes minutos!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: remainingMinutes <= 5 ? Colors.red : Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Navegar para a tela de detalhes ou home
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  /// Mostra notificação quando uma ativação expirou
  void showExpiredNotification(BuildContext context, String licensePlate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Estacionamento do veículo $licensePlate expirou!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Renovar',
          textColor: Colors.white,
          onPressed: () {
            // Navegar para a tela de compra
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

/// Widget para monitorar ativações e mostrar notificações automaticamente
class ActivationNotificationMonitor extends ConsumerWidget {
  final Widget child;

  const ActivationNotificationMonitor({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}

/// Hook para usar em qualquer tela que queira monitorar ativações
class UseActivationNotifications {
  // NOTIFICAÇÕES TOAST DESABILITADAS - mantendo apenas notificações locais
  static void showExpiringSoon(
      BuildContext context, String licensePlate, int remainingMinutes) {}

  static void showExpired(BuildContext context, String licensePlate) {}
}
