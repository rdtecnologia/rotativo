import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/edit_profile_provider.dart';
import '../../models/auth_models.dart';
import '../../services/auth_service.dart';
import '../../utils/formatters.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    // Busca dados atualizados da API ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Busca dados frescos da API
        final freshUser = await AuthService.getCurrentUser();
        if (freshUser != null && mounted) {
          // Inicializa o formulário com dados frescos da API
          ref.read(editProfileNotifierProvider).initializeWithUser(freshUser);
        }
      } catch (e) {
        // Se falhar ao buscar da API, usa dados cacheados
        final user = ref.read(currentUserProvider);
        if (user != null) {
          ref.read(editProfileNotifierProvider).initializeWithUser(user);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar meus dados'),
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
                // Profile avatar
                Container(
                  padding: const EdgeInsets.all(20),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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
                    initialValue: {
                      'name': user?.name ?? '',
                      'email': user?.email ?? '',
                      'cpf': user?.cpf ?? '',
                      'phone': user?.phone ?? '',
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Informações pessoais',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Name field
                        _NameField(),

                        const SizedBox(height: 16),

                        // Email field
                        _EmailField(),

                        const SizedBox(height: 16),

                        // CPF field (readonly)
                        _CPFField(user: user),

                        const SizedBox(height: 16),

                        // Phone field
                        _PhoneField(),

                        const SizedBox(height: 32),

                        // Update button
                        _UpdateButton(formKey: _formKey),
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
}

// Widgets otimizados que só rebuild quando necessário

class _NameField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(editProfileFormDataProvider);
    final notifier = ref.read(editProfileNotifierProvider);

    return FormBuilderTextField(
      name: 'name',
      initialValue: formData['name'],
      decoration: InputDecoration(
        labelText: 'Nome completo',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
          errorText: 'Nome é obrigatório',
        ),
        FormBuilderValidators.minLength(
          2,
          errorText: 'Nome deve ter pelo menos 2 caracteres',
        ),
      ]),
      onChanged: (value) {
        notifier.updateField('name', value ?? '');
        notifier.validateForm();
      },
    );
  }
}

class _EmailField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(editProfileFormDataProvider);
    final notifier = ref.read(editProfileNotifierProvider);

    return FormBuilderTextField(
      name: 'email',
      initialValue: formData['email'],
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'E-mail',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
          errorText: 'E-mail é obrigatório',
        ),
        FormBuilderValidators.email(
          errorText: 'Digite um e-mail válido',
        ),
      ]),
      onChanged: (value) {
        notifier.updateField('email', value ?? '');
        notifier.validateForm();
      },
    );
  }
}

class _CPFField extends StatelessWidget {
  final User? user;

  const _CPFField({this.user});

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'cpf',
      initialValue: user?.cpf ?? '',
      keyboardType: TextInputType.number,
      inputFormatters: [AppFormatters.cpfFormatter],
      enabled: false,
      decoration: InputDecoration(
        labelText: 'CPF',
        prefixIcon: const Icon(Icons.badge),
        helperText: 'CPF não pode ser alterado',
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

class _PhoneField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(editProfileFormDataProvider);
    final notifier = ref.read(editProfileNotifierProvider);

    return FormBuilderTextField(
      name: 'phone',
      initialValue: formData['phone'],
      keyboardType: TextInputType.phone,
      inputFormatters: [AppFormatters.phoneFormatter],
      decoration: InputDecoration(
        labelText: 'Telefone',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
          errorText: 'Telefone é obrigatório',
        ),
      ]),
      onChanged: (value) {
        notifier.updateField('phone', value ?? '');
        notifier.validateForm();
      },
    );
  }
}

class _UpdateButton extends ConsumerWidget {
  final GlobalKey<FormBuilderState> formKey;

  const _UpdateButton({required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(editProfileLoadingProvider);
    final isFormValid = ref.watch(editProfileFormValidProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isLoading || !isFormValid)
            ? null
            : () => _handleUpdate(context, ref),
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
                'Salvar alterações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context, WidgetRef ref) async {
    if (!formKey.currentState!.saveAndValidate()) return;

    ref.read(editProfileNotifierProvider).setLoading(true);

    try {
      final formData = formKey.currentState!.value;

      // Chama API real para atualizar dados
      await ref.read(authProvider.notifier).updateUser(
            name: formData['name']?.toString().trim() ?? '',
            email: formData['email']?.toString().trim() ?? '',
            phone: formData['phone']?.toString().trim() ?? '',
          );

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Dados atualizados com sucesso!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ref
            .read(editProfileNotifierProvider)
            .setError('Erro ao atualizar dados: $e');

        Fluttertoast.showToast(
          msg: 'Erro ao atualizar dados: $e',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (context.mounted) {
        ref.read(editProfileNotifierProvider).setLoading(false);
      }
    }
  }
}
