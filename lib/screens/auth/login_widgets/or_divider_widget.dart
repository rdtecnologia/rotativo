import 'package:flutter/material.dart';

class OrDividerWidget extends StatelessWidget {
  const OrDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.white54)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        Expanded(child: Divider(color: Colors.white54)),
      ],
    );
  }
}
