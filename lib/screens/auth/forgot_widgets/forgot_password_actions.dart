import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordActions extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordActions({
    super.key,
    required this.onBackToLogin,
  });

  void _showContactSupport() {
    Fluttertoast.showToast(
      msg: 'Entre em contato com o suporte',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Back to Login
        TextButton(
          onPressed: onBackToLogin,
          child: const Text(
            'Voltar ao Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Contact Support
        TextButton(
          onPressed: _showContactSupport,
          child: const Text(
            'Problemas? Fale conosco!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
