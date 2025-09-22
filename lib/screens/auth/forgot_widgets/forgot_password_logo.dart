import 'package:flutter/material.dart';

class ForgotPasswordLogo extends StatelessWidget {
  const ForgotPasswordLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.lock_reset,
        size: 60,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
