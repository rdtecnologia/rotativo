import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/parking_background.dart';
import 'forgot_widgets/forgot_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? initialCPF;

  const ForgotPasswordScreen({
    super.key,
    this.initialCPF,
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    // Clear any previous errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final formData = _formKey.currentState!.value;
    final cpf = formData['cpf'] as String;

    try {
      await ref.read(authProvider.notifier).forgotPassword(cpf);
      
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Instruções de recuperação enviadas!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        
        Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: ParkingBackground(
        primaryColor: Theme.of(context).primaryColor,
        opacity: 0.25,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const ForgotPasswordLogo(),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  const ForgotPasswordTitle(),
                  
                  const SizedBox(height: 48),
                  
                  // Form Card
                  ForgotPasswordForm(
                    formKey: _formKey,
                    initialCPF: widget.initialCPF,
                    onSubmit: _handleSubmit,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  ForgotPasswordActions(
                    onBackToLogin: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}