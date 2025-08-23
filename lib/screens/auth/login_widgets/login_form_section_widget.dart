import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../providers/login_screen_provider.dart';
import 'login_form_widget.dart';
import 'forgot_password_link_widget.dart';
import 'login_toggle_button_widget.dart';

class LoginFormSectionWidget extends ConsumerWidget {
  final GlobalKey<FormBuilderState> formKey;
  final VoidCallback onLogin;

  const LoginFormSectionWidget({
    super.key,
    required this.formKey,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final showLoginCard = ref.watch(showLoginCardProvider);

    if (!showLoginCard) return const SizedBox.shrink();

    return Column(
      children: [
        LoginFormWidget(
          formKey: formKey,
          onLogin: onLogin,
        ),
        const SizedBox(height: 24),
        const ForgotPasswordLinkWidget(),
        
        // Botão para alternar quando biometria está ativa
        if (biometricEnabled)
          LoginToggleButtonWidget(showingLoginCard: showLoginCard),
      ],
    );
  }
}
