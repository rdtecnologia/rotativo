import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/auth_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/register_form_provider.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../widgets/loading_button.dart';
import '../widgets/app_text_field.dart';
import '../../config/dynamic_app_config.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? initialCPF;

  const RegisterScreen({
    super.key,
    this.initialCPF,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any previous errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
      ref.read(registerFormProvider.notifier).clearValidationError();
    });
  }

  Future<void> _handleSubmit() async {
    final formKey = ref.read(registerFormKeyProvider);
    final registerFormNotifier = ref.read(registerFormProvider.notifier);

    // Valida o formulário usando o provider
    if (!registerFormNotifier.validateForm(formKey)) {
      Fluttertoast.showToast(
        msg: 'Você deve aceitar os termos de uso',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final formData = formKey.currentState!.value;

    final registerRequest = RegisterRequest(
      cpf: formData['cpf'],
      fullname: formData['fullname'],
      email: formData['email'],
      phone: formData['phone'],
      password: formData['password'],
      confirmPassword: formData['confirmPassword'],
    );

    try {
      await ref.read(authProvider.notifier).register(registerRequest);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Cadastro realizado com sucesso!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate to main app after successful registration
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _openTerms() async {
    try {
      final termsLink = await DynamicAppConfig.termsLink;
      if (termsLink != null && termsLink.isNotEmpty) {
        // Abre o PDF dos termos usando o visualizador interno
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Termos e Condições'),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_browser),
                      onPressed: () => _launchUrl(termsLink),
                      tooltip: 'Abrir no navegador',
                    ),
                  ],
                ),
                body: SfPdfViewer.network(
                  termsLink,
                  canShowPaginationDialog: true,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  enableDoubleTapZooming: true,
                  enableTextSelection: true,
                  enableHyperlinkNavigation: true,
                ),
              ),
            ),
          );
        }
      } else {
        // Se não houver link, mostra mensagem
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Termos de Uso'),
              content: const Text(
                  'Os termos de uso não estão disponíveis no momento.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Se houver erro, tenta abrir no navegador
      try {
        final termsLink = await DynamicAppConfig.termsLink;
        if (termsLink != null && termsLink.isNotEmpty) {
          await _launchUrl(termsLink);
        } else {
          throw Exception('Link não disponível');
        }
      } catch (browserError) {
        // Se falhar tudo, mostra mensagem genérica
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Termos de Uso'),
              content: const Text(
                  'Os termos de uso estão disponíveis em nosso site.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Não foi possível abrir o link');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final registerFormState = ref.watch(registerFormProvider);
    final formKey = ref.read(registerFormKeyProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Cadastrar'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Preencha os campos abaixo para se cadastrar:',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      FormBuilder(
                        key: formKey,
                        child: Column(
                          children: [
                            // CPF Field
                            AppTextField(
                              name: 'cpf',
                              label: 'CPF',
                              initialValue: widget.initialCPF,
                              keyboardType: TextInputType.number,
                              inputFormatters: [AppFormatters.cpfFormatter],
                              validator: AppValidators.validateCPF,
                              prefixIcon: const Icon(Icons.person),
                            ),

                            const SizedBox(height: 16),

                            // Full Name Field
                            AppTextField(
                              name: 'fullname',
                              label: 'Nome Completo',
                              textCapitalization: TextCapitalization.words,
                              validator: AppValidators.validateName,
                              prefixIcon: const Icon(Icons.person_outline),
                            ),

                            const SizedBox(height: 16),

                            // Email Field
                            AppTextField(
                              name: 'email',
                              label: 'E-mail',
                              keyboardType: TextInputType.emailAddress,
                              validator: AppValidators.validateEmail,
                              prefixIcon: const Icon(Icons.email),
                            ),

                            const SizedBox(height: 16),

                            // Phone Field
                            AppTextField(
                              name: 'phone',
                              label: 'Celular',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [AppFormatters.phoneFormatter],
                              validator: AppValidators.validatePhone,
                              prefixIcon: const Icon(Icons.phone),
                            ),

                            const SizedBox(height: 16),

                            // Password Field
                            AppTextField(
                              name: 'password',
                              label: 'Senha',
                              obscureText: true,
                              validator: AppValidators.validatePassword,
                              prefixIcon: const Icon(Icons.lock),
                            ),

                            const SizedBox(height: 16),

                            // Confirm Password Field
                            AppTextField(
                              name: 'confirmPassword',
                              label: 'Confirmar Senha',
                              obscureText: true,
                              validator: (value) =>
                                  AppValidators.validateConfirmPassword(
                                value,
                                formKey.currentState?.value['password'],
                              ),
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Terms Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: registerFormState.acceptTerms,
                            onChanged: (value) {
                              ref
                                  .read(registerFormProvider.notifier)
                                  .setAcceptTerms(value ?? false);
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(registerFormProvider.notifier)
                                    .toggleAcceptTerms();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: RichText(
                                  text: TextSpan(
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      const TextSpan(
                                          text: 'Declaro que li e aceito os '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _openTerms,
                                          child: Text(
                                            'termos e condições',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(
                                          text: ' de uso do aplicativo'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Validation Error Display
                      if (registerFormState.hasValidationError) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  registerFormState.validationError!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Register Button
                      LoadingButton(
                        onPressed: _handleSubmit,
                        isLoading: authState.isLoading,
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(
                                text: 'Já tem uma conta? ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextSpan(
                                text: 'Faça login',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }
}
