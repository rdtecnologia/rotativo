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
}
