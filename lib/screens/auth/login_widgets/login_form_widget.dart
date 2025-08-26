import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/validators.dart';
import '../../../utils/formatters.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/app_text_field.dart';
import '../register_screen.dart';

class LoginFormWidget extends ConsumerWidget {
  final GlobalKey<FormBuilderState> formKey;
  final VoidCallback onLogin;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: Colors.grey.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FormBuilder(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Faça login na sua conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Digite suas credenciais para acessar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // CPF Field
              GestureDetector(
                onTap: () {
                  // Feedback tátil ao tocar no campo
                  HapticFeedback.lightImpact();
                },
                child: AppTextField(
                  name: 'cpf',
                  label: 'CPF',
                  keyboardType: TextInputType.number,
                  inputFormatters: [AppFormatters.cpfFormatter],
                  validator: AppValidators.validateCPF,
                  prefixIcon: const Icon(Icons.person),
                  fillColor: Colors.white.withAlpha(100),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              GestureDetector(
                onTap: () {
                  // Feedback tátil ao tocar no campo
                  HapticFeedback.lightImpact();
                },
                child: AppTextField(
                  name: 'password',
                  label: 'Senha',
                  obscureText: true,
                  validator: AppValidators.validatePassword,
                  prefixIcon: const Icon(Icons.lock),
                  fillColor: Colors.white.withAlpha(100),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authProvider);
                  return GestureDetector(
                    onTap: () {
                      // Feedback tátil ao tocar no botão
                      HapticFeedback.mediumImpact();
                      onLogin();
                    },
                    child: LoadingButton(
                      onPressed: onLogin,
                      isLoading: authState.isLoading,
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Register Link
              GestureDetector(
                onTap: () {
                  // Feedback tátil ao tocar no link
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(
                          text: 'Não tem uma conta? ',
                          style: TextStyle(color: Colors.white60),
                        ),
                        TextSpan(
                          text: 'Cadastre-se',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
