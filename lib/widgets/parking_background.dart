import 'package:flutter/material.dart';

class ParkingBackground extends StatelessWidget {
  final Widget child;
  final Color? primaryColor;
  final double opacity;

  const ParkingBackground({
    Key? key,
    required this.child,
    this.primaryColor,
    this.opacity = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? Theme.of(context).primaryColor;
    
    return Stack(
      children: [
        // Background image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/parking_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Color overlay + child
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity((opacity).clamp(0.0, 1.0)),
                  color.withOpacity((opacity * 0.7).clamp(0.0, 1.0)),
                ],
              ),
            ),
            child: SafeArea(
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
