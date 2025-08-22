import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/validators.dart';
import '../../services/auth_service.dart';
import '../../providers/change_password_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    inspect('build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar senha'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Alterar senha',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Digite sua senha atual e a nova senha',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Current password field
                        _buildPasswordField(
                          context,
                          name: 'currentPassword',
                          labelText: 'Senha atual',
                          prefixIcon: Icons.lock_outline,
                          isConsumer: true,
                          fieldType: 'current',
                        ),

                        const SizedBox(height: 16),

                        // New password field
                        _buildPasswordField(
                          context,
                          name: 'newPassword',
                          labelText: 'Nova senha',
                          prefixIcon: Icons.lock,
                          isConsumer: true,
                          fieldType: 'new',
                        ),

                        const SizedBox(height: 16),

                        // Confirm new password field
                        _buildPasswordField(
                          context,
                          name: 'confirmPassword',
                          labelText: 'Confirmar nova senha',
                          prefixIcon: Icons.lock,
                          isConsumer: true,
                          fieldType: 'confirm',
                        ),

                        const SizedBox(height: 32),

                        // Update button
                        _buildUpdateButton(context),

                        const SizedBox(height: 16),

                        // Security tips
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: 20,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Dicas de segurança',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Use pelo menos 8 caracteres\n'
                                '• Inclua números e símbolos\n'
                                '• Evite informações pessoais\n'
                                '• Não reutilize senhas antigas',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String name,
    required String labelText,
    required IconData prefixIcon,
    bool isConsumer = false,
    String? fieldType,
  }) {
    if (isConsumer) {
      return Consumer(
        builder: (context, ref, child) {
          // Determinar qual valor observar baseado no tipo do campo
          bool obscureText;
          VoidCallback onToggleVisibility;
          ValueChanged<String?> onChanged;

          switch (fieldType) {
            case 'current':
              obscureText = ref.watch(changePasswordProvider
                  .select((state) => state.obscureCurrentPassword));
              onToggleVisibility = () => ref
                  .read(changePasswordProvider.notifier)
                  .toggleCurrentPasswordVisibility();
              onChanged = (value) => ref
                  .read(changePasswordProvider.notifier)
                  .updateCurrentPassword(value ?? '');
              break;
            case 'new':
              obscureText = ref.watch(changePasswordProvider
                  .select((state) => state.obscureNewPassword));
              onToggleVisibility = () => ref
                  .read(changePasswordProvider.notifier)
                  .toggleNewPasswordVisibility();
              onChanged = (value) => ref
                  .read(changePasswordProvider.notifier)
                  .updateNewPassword(value ?? '');
              break;
            case 'confirm':
              obscureText = ref.watch(changePasswordProvider
                  .select((state) => state.obscureConfirmPassword));
              onToggleVisibility = () => ref
                  .read(changePasswordProvider.notifier)
                  .toggleConfirmPasswordVisibility();
              onChanged = (value) => ref
                  .read(changePasswordProvider.notifier)
                  .updateConfirmPassword(value ?? '');
              break;
            default:
              obscureText = true;
              onToggleVisibility = () {};
              onChanged = (value) {};
          }

          FormFieldValidator<String>? validator;
          if (fieldType == 'current') {
            validator = FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Senha atual é obrigatória',
              ),
            ]);
          } else if (fieldType == 'new') {
            validator = AppValidators.validatePassword;
          } else if (fieldType == 'confirm') {
            validator = (value) {
              if (value == null || value.isEmpty) {
                return 'Confirmação de senha é obrigatória';
              }

              // Usar o provider para validar se as senhas coincidem
              final notifier = ref.read(changePasswordProvider.notifier);
              if (!notifier.passwordsMatch) {
                return 'Senhas não coincidem';
              }

              return null;
            };
          }

          return FormBuilderTextField(
            name: name,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: labelText,
              prefixIcon: Icon(prefixIcon),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: validator,
          );
        },
      );
    }

    return FormBuilderTextField(
      name: name,
      obscureText: true,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref
            .watch(changePasswordProvider.select((state) => state.isLoading));

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                isLoading ? null : () => _handlePasswordChange(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Alterar senha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handlePasswordChange(
      BuildContext context, WidgetRef ref) async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    final changePasswordNotifier = ref.read(changePasswordProvider.notifier);
    changePasswordNotifier.setLoading(true);

    try {
      final formData = _formKey.currentState!.value;

      final currentPassword = formData['currentPassword'] as String;
      final newPassword = formData['newPassword'] as String;
      final confirmPassword = formData['confirmPassword'] as String;

      // Validate if new passwords match
      if (newPassword != confirmPassword) {
        throw Exception('As senhas não coincidem');
      }

      // Call the actual API
      await AuthService.changePassword(currentPassword, newPassword);

      // Limpar credenciais biométricas por segurança
      await AuthService.clearBiometricCredentials();

      if (context.mounted) {
        Fluttertoast.showToast(
          msg:
              'Senha alterada com sucesso! Biometria desabilitada por segurança.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Erro ao alterar senha: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (context.mounted) {
        changePasswordNotifier.setLoading(false);
      }
    }
  }
}
