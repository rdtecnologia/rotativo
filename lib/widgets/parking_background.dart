import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/color_scheme_provider.dart';

class ParkingBackground extends ConsumerWidget {
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;
  final double opacity;

  const ParkingBackground({
    super.key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(appColorsProvider).when(
      data: (appColors) {
        final primary = primaryColor ?? appColors.primary;
        final secondary = secondaryColor ?? appColors.secondary;

        return _buildBackground(context, primary, secondary);
      },
      loading: () {
        final primary = primaryColor ?? Theme.of(context).primaryColor;
        final secondary =
            secondaryColor ?? Theme.of(context).colorScheme.secondary;
        return _buildBackground(context, primary, secondary);
      },
      error: (_, __) {
        final primary = primaryColor ?? Theme.of(context).primaryColor;
        final secondary =
            secondaryColor ?? Theme.of(context).colorScheme.secondary;
        return _buildBackground(context, primary, secondary);
      },
    );
  }

  Widget _buildBackground(
      BuildContext context, Color primary, Color secondary) {
    return Stack(
      children: [
        // Background color base para evitar tela branca
        Container(
          color: primary,
        ),
        // Background image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/parking_background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.3),
                BlendMode.modulate,
              ),
            ),
          ),
        ),
        // Gradient overlay with both colors + child
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: (opacity).clamp(0.0, 1.0)),
                  secondary.withValues(alpha: (opacity * 0.8).clamp(0.0, 1.0)),
                  primary.withValues(alpha: (opacity * 0.6).clamp(0.0, 1.0)),
                ],
                stops: const [0.0, 0.5, 1.0],
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
