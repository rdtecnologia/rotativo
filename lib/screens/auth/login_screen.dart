import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/login_screen_provider.dart';
import '../../widgets/parking_background.dart';
import 'login_widgets/login_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();

    // Clear any previous errors and initialize login screen state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
      ref.read(loginScreenProvider.notifier).initialize();
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final formData = _formKey.currentState!.value;
    final cpf = formData['cpf'] as String;
    final password = formData['password'] as String;

    try {
      // Direct login attempt
      await ref.read(authProvider.notifier).login(cpf, password);

      // Navigate to main app after successful login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
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
    inspect('build');
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          ParkingBackground(
            primaryColor: Theme.of(context).primaryColor,
            opacity: 0.25,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and City Name
                      const AppLogoWidget(),
                      const SizedBox(height: 48),

                      // Biometric Section
                      const BiometricSectionWidget(),

                      // Login Form Section
                      LoginFormSectionWidget(
                        formKey: _formKey,
                        onLogin: _handleLogin,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
