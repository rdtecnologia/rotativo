import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/active_activations_provider.dart';

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
    // Monitora ativações que estão próximas de expirar
    final expiringSoon = ref.watch(expiringSoonActivationsProvider);

    // Monitora ativações que expiraram recentemente
    final recentlyExpired = ref.watch(recentlyExpiredActivationsProvider);

    // Mostra notificações para ativações próximas de expirar
    for (final activation in expiringSoon) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService().showExpiringSoonNotification(
          context,
          activation.licensePlate,
          activation.remainingMinutes,
        );
      });
    }

    // Mostra notificações para ativações que expiraram
    for (final activation in recentlyExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService().showExpiredNotification(
          context,
          activation.licensePlate,
        );
      });
    }

    return child;
  }
}

/// Hook para usar em qualquer tela que queira monitorar ativações
class UseActivationNotifications {
  static void showExpiringSoon(
      BuildContext context, String licensePlate, int remainingMinutes) {
    NotificationService()
        .showExpiringSoonNotification(context, licensePlate, remainingMinutes);
  }

  static void showExpired(BuildContext context, String licensePlate) {
    NotificationService().showExpiredNotification(context, licensePlate);
  }
}
