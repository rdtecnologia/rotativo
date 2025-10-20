import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/environment.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  bool _isInitialized = false;

  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  /// Get Firebase Analytics instance
  FirebaseAnalytics? get analytics => _analytics;

  /// Get Firebase Crashlytics instance
  FirebaseCrashlytics? get crashlytics => _crashlytics;

  /// Initialize Firebase with flavor-specific configuration
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('🔥 Firebase already initialized');
      }
      return;
    }

    try {
      final flavor = Environment.flavor;
      if (kDebugMode) {
        print('🔥 Initializing Firebase for flavor: $flavor');
      }

      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: await _getFirebaseOptions(flavor),
      );

      // Initialize Analytics
      _analytics = FirebaseAnalytics.instance;

      // Initialize Crashlytics
      _crashlytics = FirebaseCrashlytics.instance;

      // Configure Crashlytics
      await _configureCrashlytics();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Firebase initialized successfully for flavor: $flavor');
      }

      // Log initialization event
      await logEvent('firebase_initialized', parameters: {
        'flavor': flavor,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing Firebase: $e');
        print('Stack trace: $stackTrace');
      }
      // Don't rethrow - app should continue working even if Firebase fails
    }
  }

  /// Get Firebase options based on current flavor
  Future<FirebaseOptions?> _getFirebaseOptions(String flavor) async {
    try {
      // For Android, the google-services.json is automatically selected by flavor
      // For iOS, we need to load the correct GoogleService-Info.plist

      if (Platform.isIOS) {
        return await _getIOSFirebaseOptions(flavor);
      }

      // For Android, return null to use the default configuration
      // The google-services plugin will automatically use the correct file based on flavor
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading Firebase options for flavor $flavor: $e');
      }
      return null;
    }
  }

  /// Get iOS Firebase options from flavor-specific plist
  Future<FirebaseOptions?> _getIOSFirebaseOptions(String flavor) async {
    try {
      // Map flavor to city directory
      final cityDirectory = _mapFlavorToCityDirectory(flavor);
      final plistPath =
          'assets/config/cities/$cityDirectory/GoogleService-Info.plist';

      if (kDebugMode) {
        print('🍎 Loading iOS Firebase config from: $plistPath');
      }

      // Load the plist content
      final plistContent = await rootBundle.loadString(plistPath);

      // Parse the plist and extract Firebase configuration
      // Note: This is a simplified approach. In production, you might want to use
      // a proper plist parser or copy the file to the iOS bundle during build

      final config = _parseIOSConfig(plistContent, flavor);
      return config;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading iOS Firebase config: $e');
      }
      return null;
    }
  }

  /// Parse iOS plist configuration (simplified)
  FirebaseOptions? _parseIOSConfig(String plistContent, String flavor) {
    try {
      // Extract values from plist content using regex
      final apiKey = _extractPlistValue(plistContent, 'API_KEY');
      final appId = _extractPlistValue(plistContent, 'GOOGLE_APP_ID');
      final messagingSenderId =
          _extractPlistValue(plistContent, 'GCM_SENDER_ID');
      final projectId = _extractPlistValue(plistContent, 'PROJECT_ID');
      final storageBucket = _extractPlistValue(plistContent, 'STORAGE_BUCKET');

      if (apiKey != null &&
          appId != null &&
          messagingSenderId != null &&
          projectId != null) {
        return FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
        );
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing iOS config: $e');
      }
      return null;
    }
  }

  /// Extract value from plist content
  String? _extractPlistValue(String plistContent, String key) {
    final regex = RegExp('<key>$key</key>\\s*<string>([^<]+)</string>');
    final match = regex.firstMatch(plistContent);
    return match?.group(1);
  }

  /// Map flavor to city directory name
  String _mapFlavorToCityDirectory(String flavor) {
    switch (flavor.toLowerCase()) {
      case 'vicosa':
        return 'Vicosa';
      case 'ouropreto':
        return 'OuroPreto';
      case 'demo':
        return 'Main';
      default:
        return 'Main';
    }
  }

  /// Configure Crashlytics settings
  Future<void> _configureCrashlytics() async {
    if (_crashlytics == null) return;

    try {
      // Always enable crash collection (even in debug mode for testing)
      // Set to true to enable crash reporting in all modes
      await _crashlytics!.setCrashlyticsCollectionEnabled(true);

      // Set user identifier (you can customize this based on your user system)
      await _crashlytics!
          .setUserIdentifier('user_${DateTime.now().millisecondsSinceEpoch}');

      // Set custom keys for debugging
      await _crashlytics!.setCustomKey('flavor', Environment.flavor);
      await _crashlytics!.setCustomKey(
          'app_version', '2.0.0+11'); // You can get this dynamically

      if (kDebugMode) {
        print('✅ Crashlytics configured successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error configuring Crashlytics: $e');
      }
    }
  }

  /// Log analytics event
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (_analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters,
      );

      if (kDebugMode) {
        print('📊 Analytics event logged: $name with parameters: $parameters');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging analytics event: $e');
      }
    }
  }

  /// Log custom crash
  Future<void> logCrash(dynamic exception, StackTrace? stackTrace,
      {String? reason}) async {
    if (_crashlytics == null) return;

    try {
      if (reason != null) {
        await _crashlytics!.log(reason);
      }

      await _crashlytics!.recordError(
        exception,
        stackTrace,
        fatal: false,
      );

      if (kDebugMode) {
        print('💥 Crash logged to Crashlytics: $exception');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging crash: $e');
      }
    }
  }

  /// Log fatal crash
  Future<void> logFatalCrash(dynamic exception, StackTrace? stackTrace,
      {String? reason}) async {
    if (_crashlytics == null) return;

    try {
      if (reason != null) {
        await _crashlytics!.log(reason);
      }

      await _crashlytics!.recordError(
        exception,
        stackTrace,
        fatal: true,
      );

      if (kDebugMode) {
        print('💀 Fatal crash logged to Crashlytics: $exception');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging fatal crash: $e');
      }
    }
  }

  /// Set user properties for analytics
  Future<void> setUserProperties({
    String? userId,
    Map<String, String>? properties,
  }) async {
    if (_analytics == null) return;

    try {
      if (userId != null) {
        await _analytics!.setUserId(id: userId);
      }

      if (properties != null) {
        for (final entry in properties.entries) {
          await _analytics!.setUserProperty(
            name: entry.key,
            value: entry.value,
          );
        }
      }

      if (kDebugMode) {
        print('👤 User properties set: userId=$userId, properties=$properties');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting user properties: $e');
      }
    }
  }

  /// Set custom Crashlytics keys
  Future<void> setCrashlyticsKeys(Map<String, String> keys) async {
    if (_crashlytics == null) return;

    try {
      for (final entry in keys.entries) {
        await _crashlytics!.setCustomKey(entry.key, entry.value);
      }

      if (kDebugMode) {
        print('🔑 Crashlytics custom keys set: $keys');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting Crashlytics keys: $e');
      }
    }
  }

  /// Force send unsent reports to Crashlytics
  /// Useful for testing in debug mode
  Future<void> sendUnsentReports() async {
    if (_crashlytics == null) return;

    try {
      await _crashlytics!.sendUnsentReports();

      if (kDebugMode) {
        print('📤 Unsent Crashlytics reports sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending unsent reports: $e');
      }
    }
  }

  /// Check for unsent reports
  Future<bool> checkForUnsentReports() async {
    if (_crashlytics == null) return false;

    try {
      final hasUnsent = await _crashlytics!.checkForUnsentReports();

      if (kDebugMode) {
        print('📊 Has unsent reports: $hasUnsent');
      }

      return hasUnsent;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking for unsent reports: $e');
      }
      return false;
    }
  }
}
