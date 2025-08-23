import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/login_screen_provider.dart';

class LoginToggleButtonWidget extends ConsumerWidget {
  final bool showingLoginCard;
  
  const LoginToggleButtonWidget({
    super.key,
    required this.showingLoginCard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showingLoginCard) {
      // Botão para voltar para biometria
      return Column(
        children: [
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              ref.read(loginScreenProvider.notifier).toggleLoginCard();
            },
            icon: const Icon(Icons.fingerprint, color: Colors.white54),
            label: const Text(
              'Usar apenas biometria',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      );
    } else {
      // Botão para mostrar login tradicional
      return Column(
        children: [
          TextButton.icon(
            onPressed: () {
              ref.read(loginScreenProvider.notifier).toggleLoginCard();
            },
            icon: const Icon(Icons.login, color: Colors.white54),
            label: const Text(
              'Usar login tradicional',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
  }
}
