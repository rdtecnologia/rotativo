import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../utils/validators.dart';
import '../../../utils/formatters.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_button.dart';

class ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final String? initialCPF;
  final VoidCallback onSubmit;
  final bool isLoading;

  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    this.initialCPF,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.3),
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
              Text(
                'Digite seu CPF para recuperar sua senha:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // CPF Field
              AppTextField(
                name: 'cpf',
                label: 'CPF',
                initialValue: initialCPF,
                keyboardType: TextInputType.number,
                inputFormatters: [AppFormatters.cpfFormatter],
                validator: AppValidators.validateCPF,
                prefixIcon: const Icon(Icons.person),
              ),

              const SizedBox(height: 24),

              // Submit Button
              LoadingButton(
                onPressed: onSubmit,
                isLoading: isLoading,
                child: const Text(
                  'Recuperar Senha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Text
              Text(
                'Enviaremos as instruções para o e-mail cadastrado em sua conta.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
