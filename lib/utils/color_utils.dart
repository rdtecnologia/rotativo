import 'package:flutter/material.dart';

/// Utility functions for color operations
class ColorUtils {
  /// Convert hex color string to Color object
  /// Supports formats: #RRGGBB, #AARRGGBB, RRGGBB, AARRGGBB
  static Color hexToColor(String hexString) {
    // Remove # if present
    String hex = hexString.replaceAll('#', '');

    // Add alpha channel if not present (default to FF for full opacity)
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    // Parse hex string to int
    int colorValue = int.parse(hex, radix: 16);

    return Color(colorValue);
  }

  /// Convert Color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// Create a ColorScheme from a primary color
  static ColorScheme createColorScheme(Color primaryColor) {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
  }

  /// Create a custom ColorScheme with primary and secondary colors
  static ColorScheme createCustomColorScheme({
    required Color primaryColor,
    required Color secondaryColor,
    Brightness brightness = Brightness.light,
  }) {
    return ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: _getContrastColor(primaryColor),
      secondary: secondaryColor,
      onSecondary: _getContrastColor(secondaryColor),
      tertiary: secondaryColor.withValues(alpha: 0.7),
      onTertiary: _getContrastColor(secondaryColor),
      error: Colors.red,
      onError: Colors.white,
      surface:
          brightness == Brightness.light ? Colors.white : Colors.grey[900]!,
      onSurface: brightness == Brightness.light ? Colors.black : Colors.white,
      surfaceContainerHighest: primaryColor.withValues(alpha: 0.1),
      onSurfaceVariant: brightness == Brightness.light
          ? Colors.grey[600]!
          : Colors.grey[400]!,
      outline: secondaryColor.withValues(alpha: 0.5),
      outlineVariant: secondaryColor.withValues(alpha: 0.2),
    );
  }

  /// Get contrast color (black or white) for better readability
  static Color _getContrastColor(Color color) {
    // Calculate luminance
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Create gradient colors using primary and secondary colors
  static List<Color> createGradientColors({
    required Color primaryColor,
    required Color secondaryColor,
    int steps = 3,
  }) {
    final colors = <Color>[];
    for (int i = 0; i < steps; i++) {
      final ratio = i / (steps - 1);
      colors.add(Color.lerp(primaryColor, secondaryColor, ratio)!);
    }
    return colors;
  }

  /// Create a subtle gradient for backgrounds
  static LinearGradient createSubtleGradient({
    required Color primaryColor,
    required Color secondaryColor,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        primaryColor.withValues(alpha: 0.1),
        secondaryColor.withValues(alpha: 0.1),
        primaryColor.withValues(alpha: 0.05),
      ],
    );
  }

  /// Create a vibrant gradient for buttons and highlights
  static LinearGradient createVibrantGradient({
    required Color primaryColor,
    required Color secondaryColor,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        primaryColor,
        secondaryColor,
        primaryColor.withValues(alpha: 0.8),
      ],
    );
  }
}
