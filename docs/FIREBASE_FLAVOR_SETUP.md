# Firebase Flavor Configuration

This document explains how Firebase is configured for different flavors (cities) in the Rotativo Digital app.

## 🔥 Firebase Services Configured

- **Firebase Analytics**: User behavior tracking and app analytics
- **Firebase Crashlytics**: Crash reporting and error monitoring
- **Firebase Core**: Base Firebase functionality

## 🏗️ Architecture Overview

The Firebase configuration uses a flavor-based approach where each city (flavor) has its own Firebase project and configuration files.

### Supported Flavors
- `vicosa` → Rotativo Viçosa
- `ouroPreto` → Rotativo Ouro Preto  
- `demo` → Demo/Main configuration

## 📁 File Structure

```
rotativo/
├── assets/config/cities/           # Firebase configs per city
│   ├── Vicosa/
│   │   ├── google-services.json    # Android config
│   │   └── GoogleService-Info.plist # iOS config
│   ├── OuroPreto/
│   │   ├── google-services.json
│   │   └── GoogleService-Info.plist
│   └── Main/                       # Demo/fallback config
│       ├── google-services.json
│       └── GoogleService-Info.plist
├── android/app/src/                # Android flavor configs
│   ├── vicosa/google-services.json
│   ├── ouroPreto/google-services.json
│   └── main/google-services.json
├── ios/Runner/                     # iOS config (copied during build)
│   └── GoogleService-Info.plist    # Dynamically copied
└── lib/services/
    └── firebase_service.dart       # Firebase initialization service
```

## 🚀 How It Works

### 1. Android Configuration
- Each flavor has its own `google-services.json` in `android/app/src/{flavor}/`
- The Firebase Gradle plugin automatically selects the correct config based on the build flavor
- No manual copying required for Android

### 2. iOS Configuration  
- Firebase configs are stored in `assets/config/cities/{City}/GoogleService-Info.plist`
- During build, the correct plist is copied to `ios/Runner/GoogleService-Info.plist`
- Handled by the build script: `scripts/copy_ios_firebase_config.dart`

### 3. Dynamic Initialization
- `FirebaseService` class handles initialization based on current flavor
- Integrates with existing `DynamicAppConfig` system
- Automatic error handling and fallback behavior

## 🛠️ Usage

### Building with Firebase

Use the enhanced build script that handles Firebase configuration:

```bash
# Build for specific flavor and platform
dart scripts/build_with_firebase.dart vicosa android release
dart scripts/build_with_firebase.dart ouroPreto ios debug

# Build for all platforms (default debug)
dart scripts/build_with_firebase.dart vicosa
```

### Manual Firebase Config Copy (iOS only)

```bash
# Copy iOS Firebase config for specific flavor
dart scripts/copy_ios_firebase_config.dart vicosa
dart scripts/copy_ios_firebase_config.dart ouroPreto
```

### Standard Flutter Build Commands

```bash
# Android (Firebase config automatic)
flutter build apk --flavor vicosa --release
flutter build appbundle --flavor ouroPreto --release

# iOS (requires manual config copy first)
dart scripts/copy_ios_firebase_config.dart vicosa
flutter build ios --release
```

## 📊 Analytics Usage

### Screen Tracking
```dart
import 'package:rotativo/utils/firebase_analytics_helper.dart';

// Log screen views
await FirebaseAnalyticsHelper.logScreenView('home_screen');
await FirebaseAnalyticsHelper.logScreenView('parking_screen');
```

### Custom Events
```dart
// Log parking activation
await FirebaseAnalyticsHelper.logParkingActivation(
  vehicleType: 'car',
  duration: 120,
  amount: 3.50,
  zone: 'Zona Azul',
);

// Log credit purchase
await FirebaseAnalyticsHelper.logCreditPurchase(
  credits: 100,
  amount: 50.0,
  paymentMethod: 'credit_card',
);
```

### User Properties
```dart
// Set user properties
await FirebaseAnalyticsHelper.setUserProperties(
  userId: 'user123',
  userType: 'premium',
  city: 'vicosa',
  vehicleType: 'car',
);
```

## 💥 Crashlytics Usage

### Automatic Crash Reporting
Crashes are automatically reported when they occur. The app is configured to:
- Report all unhandled exceptions
- Filter out known pointer event errors
- Include flavor information in crash reports

### Manual Error Logging
```dart
import 'package:rotativo/utils/firebase_analytics_helper.dart';

// Log non-fatal errors
await FirebaseCrashlyticsHelper.logError(
  exception,
  stackTrace,
  reason: 'Payment processing failed',
);

// Log API errors
await FirebaseCrashlyticsHelper.recordApiError(
  endpoint: '/api/parking/activate',
  statusCode: 500,
  method: 'POST',
  errorMessage: 'Server timeout',
);

// Log payment errors
await FirebaseCrashlyticsHelper.recordPaymentError(
  paymentMethod: 'credit_card',
  amount: 50.0,
  errorCode: 'CARD_DECLINED',
  errorMessage: 'Insufficient funds',
);
```

### Custom Keys and Logging
```dart
// Set custom keys for debugging
await FirebaseCrashlyticsHelper.setCustomKeys({
  'user_id': 'user123',
  'session_id': 'session456',
  'feature_flag': 'new_payment_flow',
});

// Log custom messages
await FirebaseCrashlyticsHelper.log('User started parking activation');
```

## 🔧 Configuration Details

### Firebase Projects
Each flavor connects to its own Firebase project:

- **Vicosa**: `rotativo-vicosa`
- **Ouro Preto**: `rotativo-ouro-preto`  
- **Demo**: `rotativo-digital`

### Package Names
- **Vicosa**: `com.rotativodigitalvicosard`
- **Ouro Preto**: `com.rotativodigitalouropretord`
- **Demo**: `com.rotativodigital`

## 🐛 Troubleshooting

### Common Issues

1. **iOS Build Fails - Missing GoogleService-Info.plist**
   ```bash
   # Solution: Copy the config file first
   dart scripts/copy_ios_firebase_config.dart vicosa
   flutter build ios
   ```

2. **Android Build Fails - google-services.json not found**
   - Check that the file exists in `android/app/src/{flavor}/google-services.json`
   - Verify the flavor name matches exactly

3. **Firebase Not Initializing**
   - Check that the flavor is correctly detected in `Environment.flavor`
   - Verify the Firebase config files are valid JSON/plist
   - Check console logs for initialization errors

### Debug Information

Enable debug logging to see Firebase initialization details:
```dart
// In debug mode, Firebase logs detailed information
if (kDebugMode) {
  print('🔥 Firebase initialization logs will appear here');
}
```

## 📱 Testing

### Test Firebase Integration
1. Build and run the app with a specific flavor
2. Check console logs for Firebase initialization messages
3. Trigger a test crash to verify Crashlytics
4. Check Firebase console for analytics events

### Verify Configuration
```dart
// Check if Firebase is properly initialized
if (FirebaseService.instance.analytics != null) {
  print('✅ Analytics initialized');
}

if (FirebaseService.instance.crashlytics != null) {
  print('✅ Crashlytics initialized');
}
```

## 🔄 Adding New Flavors

To add a new city/flavor:

1. **Create Firebase Project**
   - Create new project in Firebase Console
   - Add Android and iOS apps with appropriate package names

2. **Add Configuration Files**
   ```bash
   # Add to assets
   assets/config/cities/NewCity/google-services.json
   assets/config/cities/NewCity/GoogleService-Info.plist
   
   # Add to Android flavors
   android/app/src/newCity/google-services.json
   ```

3. **Update Build Configuration**
   - Add flavor to `android/app/build.gradle.kts`
   - Update `FirebaseService._mapFlavorToCityDirectory()`
   - Add to build scripts

4. **Test Configuration**
   ```bash
   dart scripts/build_with_firebase.dart newCity android debug
   ```

## 📚 Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Analytics Events](https://firebase.google.com/docs/analytics/events)
- [Firebase Crashlytics Setup](https://firebase.google.com/docs/crashlytics/get-started)
- [Android App Bundle with Flavors](https://developer.android.com/guide/app-bundle/configure-base)
