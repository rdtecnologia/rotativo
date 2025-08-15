import 'package:flutter/foundation.dart';

/// Logger utility class for the Rotativo app
/// Provides different log levels and only logs in debug mode
class AppLogger {
  static const String _tag = '🔄 Rotativo';
  
  /// Log debug information (only in debug mode)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_tag DEBUG: $message');
    }
  }
  
  /// Log info information (only in debug mode)
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_tag INFO: $message');
    }
  }
  
  /// Log warning information (only in debug mode)
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_tag WARNING: $message');
    }
  }
  
  /// Log error information (only in debug mode)
  static void error(String message) {
    if (kDebugMode) {
      debugPrint('$_tag ERROR: $message');
    }
  }
  
  /// Log success information (only in debug mode)
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('$_tag SUCCESS: $message');
    }
  }
  
  /// Log API request information (only in debug mode)
  static void api(String message) {
    if (kDebugMode) {
      debugPrint('$_tag API: $message');
    }
  }
  
  /// Log parking information (only in debug mode)
  static void parking(String message) {
    if (kDebugMode) {
      debugPrint('$_tag PARKING: $message');
    }
  }
  
  /// Log purchase information (only in debug mode)
  static void purchase(String message) {
    if (kDebugMode) {
      debugPrint('$_tag PURCHASE: $message');
    }
  }
  
  /// Log auth information (only in debug mode)
  static void auth(String message) {
    if (kDebugMode) {
      debugPrint('$_tag AUTH: $message');
    }
  }
  
  /// Log balance information (only in debug mode)
  static void balance(String message) {
    if (kDebugMode) {
      debugPrint('$_tag BALANCE: $message');
    }
  }
  
  /// Log history information (only in debug mode)
  static void history(String message) {
    if (kDebugMode) {
      debugPrint('$_tag HISTORY: $message');
    }
  }
  
  /// Log vehicle information (only in debug mode)
  static void vehicle(String message) {
    if (kDebugMode) {
      debugPrint('$_tag VEHICLE: $message');
    }
  }
}
