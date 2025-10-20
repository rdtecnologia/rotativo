import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

/// Helper class for Firebase Analytics events
class FirebaseAnalyticsHelper {
  static final FirebaseService _firebaseService = FirebaseService.instance;

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    await _firebaseService.logEvent('screen_view', parameters: {
      'screen_name': screenName,
      'screen_class': screenName,
    });
  }

  /// Log login event
  static Future<void> logLogin(String method) async {
    await _firebaseService.logEvent('login', parameters: {
      'method': method,
    });
  }

  /// Log logout event
  static Future<void> logLogout() async {
    await _firebaseService.logEvent('logout');
  }

  /// Log parking activation
  static Future<void> logParkingActivation({
    required String vehicleType,
    required int duration,
    required double amount,
    required String zone,
  }) async {
    await _firebaseService.logEvent('parking_activation', parameters: {
      'vehicle_type': vehicleType,
      'duration_minutes': duration,
      'amount': amount,
      'zone': zone,
      'currency': 'BRL',
    });
  }

  /// Log credit purchase
  static Future<void> logCreditPurchase({
    required int credits,
    required double amount,
    required String paymentMethod,
  }) async {
    await _firebaseService.logEvent('purchase', parameters: {
      'item_id': 'credits',
      'item_name': 'Parking Credits',
      'item_category': 'credits',
      'quantity': credits,
      'value': amount,
      'currency': 'BRL',
      'payment_method': paymentMethod,
    });
  }

  /// Log search event
  static Future<void> logSearch(String searchTerm) async {
    await _firebaseService.logEvent('search', parameters: {
      'search_term': searchTerm,
    });
  }

  /// Log app open
  static Future<void> logAppOpen() async {
    await _firebaseService.logEvent('app_open');
  }

  /// Log tutorial begin
  static Future<void> logTutorialBegin() async {
    await _firebaseService.logEvent('tutorial_begin');
  }

  /// Log tutorial complete
  static Future<void> logTutorialComplete() async {
    await _firebaseService.logEvent('tutorial_complete');
  }

  /// Log error event
  static Future<void> logError(String errorMessage, {String? errorCode}) async {
    await _firebaseService.logEvent('error', parameters: {
      'error_message': errorMessage,
      if (errorCode != null) 'error_code': errorCode,
    });
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userId,
    String? userType,
    String? city,
    String? vehicleType,
  }) async {
    final properties = <String, String>{};

    if (userType != null) properties['user_type'] = userType;
    if (city != null) properties['city'] = city;
    if (vehicleType != null) properties['primary_vehicle_type'] = vehicleType;

    await _firebaseService.setUserProperties(
      userId: userId,
      properties: properties,
    );
  }

  /// Log custom event
  static Future<void> logCustomEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    await _firebaseService.logEvent(eventName, parameters: parameters);
  }
}

/// Helper class for Firebase Crashlytics
class FirebaseCrashlyticsHelper {
  static final FirebaseService _firebaseService = FirebaseService.instance;

  /// Log non-fatal error
  static Future<void> logError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    await _firebaseService.logCrash(exception, stackTrace, reason: reason);
  }

  /// Log fatal error
  static Future<void> logFatalError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    await _firebaseService.logFatalCrash(exception, stackTrace, reason: reason);
  }

  /// Set custom keys for debugging
  static Future<void> setCustomKeys(Map<String, String> keys) async {
    await _firebaseService.setCrashlyticsKeys(keys);
  }

  /// Log message
  static Future<void> log(String message) async {
    if (_firebaseService.crashlytics != null) {
      await _firebaseService.crashlytics!.log(message);
    }
  }

  /// Record API error
  static Future<void> recordApiError({
    required String endpoint,
    required int statusCode,
    required String method,
    String? errorMessage,
  }) async {
    await setCustomKeys({
      'api_endpoint': endpoint,
      'http_method': method,
      'status_code': statusCode.toString(),
    });

    await logError(
      'API Error: $statusCode',
      StackTrace.current,
      reason: 'API call failed: $method $endpoint - $errorMessage',
    );
  }

  /// Record payment error
  static Future<void> recordPaymentError({
    required String paymentMethod,
    required double amount,
    required String errorCode,
    String? errorMessage,
  }) async {
    await setCustomKeys({
      'payment_method': paymentMethod,
      'payment_amount': amount.toString(),
      'payment_error_code': errorCode,
    });

    await logError(
      'Payment Error: $errorCode',
      StackTrace.current,
      reason: 'Payment failed: $paymentMethod - $errorMessage',
    );
  }

  /// Record authentication error
  static Future<void> recordAuthError({
    required String authMethod,
    required String errorCode,
    String? errorMessage,
  }) async {
    await setCustomKeys({
      'auth_method': authMethod,
      'auth_error_code': errorCode,
    });

    await logError(
      'Auth Error: $errorCode',
      StackTrace.current,
      reason: 'Authentication failed: $authMethod - $errorMessage',
    );
  }
}
