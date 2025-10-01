import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/dynamic_app_config.dart';
import '../utils/color_utils.dart';

/// Provider for managing dynamic color scheme
final colorSchemeProvider = FutureProvider<ColorScheme>((ref) async {
  final primaryColorHex = await DynamicAppConfig.primaryColor;
  final secondaryColorHex = await DynamicAppConfig.secondaryColor;

  final primaryColor = ColorUtils.hexToColor(primaryColorHex);
  final secondaryColor = ColorUtils.hexToColor(secondaryColorHex);

  return ColorUtils.createCustomColorScheme(
    primaryColor: primaryColor,
    secondaryColor: secondaryColor,
  );
});

/// Provider for primary color
final primaryColorProvider = FutureProvider<Color>((ref) async {
  final primaryColorHex = await DynamicAppConfig.primaryColor;
  return ColorUtils.hexToColor(primaryColorHex);
});

/// Provider for secondary color
final secondaryColorProvider = FutureProvider<Color>((ref) async {
  final secondaryColorHex = await DynamicAppConfig.secondaryColor;
  return ColorUtils.hexToColor(secondaryColorHex);
});

/// Provider for gradient colors
final gradientColorsProvider = FutureProvider<List<Color>>((ref) async {
  final primaryColor = await ref.watch(primaryColorProvider.future);
  final secondaryColor = await ref.watch(secondaryColorProvider.future);

  return ColorUtils.createGradientColors(
    primaryColor: primaryColor,
    secondaryColor: secondaryColor,
  );
});

/// Provider for subtle gradient
final subtleGradientProvider = FutureProvider<LinearGradient>((ref) async {
  final primaryColor = await ref.watch(primaryColorProvider.future);
  final secondaryColor = await ref.watch(secondaryColorProvider.future);

  return ColorUtils.createSubtleGradient(
    primaryColor: primaryColor,
    secondaryColor: secondaryColor,
  );
});

/// Provider for vibrant gradient
final vibrantGradientProvider = FutureProvider<LinearGradient>((ref) async {
  final primaryColor = await ref.watch(primaryColorProvider.future);
  final secondaryColor = await ref.watch(secondaryColorProvider.future);

  return ColorUtils.createVibrantGradient(
    primaryColor: primaryColor,
    secondaryColor: secondaryColor,
  );
});

/// Provider for app colors configuration
final appColorsProvider = FutureProvider<AppColors>((ref) async {
  final primaryColor = await ref.watch(primaryColorProvider.future);
  final secondaryColor = await ref.watch(secondaryColorProvider.future);
  final colorScheme = await ref.watch(colorSchemeProvider.future);
  final subtleGradient = await ref.watch(subtleGradientProvider.future);
  final vibrantGradient = await ref.watch(vibrantGradientProvider.future);

  return AppColors(
    primary: primaryColor,
    secondary: secondaryColor,
    colorScheme: colorScheme,
    subtleGradient: subtleGradient,
    vibrantGradient: vibrantGradient,
  );
});

/// Data class for app colors
class AppColors {
  final Color primary;
  final Color secondary;
  final ColorScheme colorScheme;
  final LinearGradient subtleGradient;
  final LinearGradient vibrantGradient;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.colorScheme,
    required this.subtleGradient,
    required this.vibrantGradient,
  });

  /// Get primary color with opacity
  Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);

  /// Get secondary color with opacity
  Color secondaryWithOpacity(double opacity) =>
      secondary.withValues(alpha: opacity);

  /// Get contrast color for primary
  Color get primaryContrast => _getContrastColor(primary);

  /// Get contrast color for secondary
  Color get secondaryContrast => _getContrastColor(secondary);

  /// Get contrast color (black or white) for better readability
  Color _getContrastColor(Color color) {
    // Calculate luminance
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
