import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/environment_provider.dart';

/// Widget para mostrar o indicador de ambiente atual
/// Só é exibido quando o app está em modo debug
class EnvironmentIndicator extends ConsumerWidget {
  const EnvironmentIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Só mostra o indicador em modo debug
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Consumer(
      builder: (context, ref, child) {
        final envState = ref.watch(environmentProvider);
        final envNotifier = ref.read(environmentProvider.notifier);

        if (envState.currentEnvironment == 'dev' || kDebugMode) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(envNotifier.environmentColor),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getEnvironmentIcon(envState.currentEnvironment),
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  envNotifier.environmentDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  /// Retorna o ícone apropriado para cada ambiente
  IconData _getEnvironmentIcon(String environment) {
    switch (environment) {
      case 'dev':
        return Icons.developer_mode;
      case 'prod':
        return Icons.production_quantity_limits;
      case 'offline':
        return Icons.offline_bolt;
      default:
        return Icons.info;
    }
  }
}
