import 'package:flutter/material.dart';

class ForgotPasswordTitle extends StatelessWidget {
  const ForgotPasswordTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'ESQUECI MINHA SENHA',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
