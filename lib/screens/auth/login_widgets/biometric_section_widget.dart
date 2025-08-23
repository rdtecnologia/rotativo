import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/login_screen_provider.dart';
import 'biometric_login_widget.dart';
import 'or_divider_widget.dart';
import 'login_toggle_button_widget.dart';

class BiometricSectionWidget extends ConsumerWidget {
  const BiometricSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final showLoginCard = ref.watch(showLoginCardProvider);

    if (!biometricEnabled) return const SizedBox.shrink();

    return Column(
      children: [
        // Sempre mostra a biometria quando ela está ativa
        const BiometricLoginWidget(),
        const SizedBox(height: 24),
        const OrDividerWidget(),
        const SizedBox(height: 24),
        
        // Botão para mostrar/ocultar login tradicional
        if (!showLoginCard)
          LoginToggleButtonWidget(showingLoginCard: showLoginCard),
      ],
    );
  }
}
