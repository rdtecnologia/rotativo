import 'package:flutter/material.dart';
import '../forgot_password_screen.dart';

class ForgotPasswordLinkWidget extends StatelessWidget {
  const ForgotPasswordLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ForgotPasswordScreen(),
          ),
        );
      },
      child: Text(
        'Esqueceu sua senha?',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
