import 'package:flutter/material.dart';
import '../utils/firebase_analytics_helper.dart';

/// Example widget showing how to use Firebase Analytics and Crashlytics
class FirebaseUsageExample extends StatefulWidget {
  const FirebaseUsageExample({super.key});

  @override
  State<FirebaseUsageExample> createState() => _FirebaseUsageExampleState();
}

class _FirebaseUsageExampleState extends State<FirebaseUsageExample> {
  @override
  void initState() {
    super.initState();
    // Log screen view when widget is created
    _logScreenView();
  }

  Future<void> _logScreenView() async {
    await FirebaseAnalyticsHelper.logScreenView('firebase_example_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Integration Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Analytics Examples
            const Text(
              'Analytics Examples:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _logCustomEvent,
              child: const Text('Log Custom Event'),
            ),

            ElevatedButton(
              onPressed: _logParkingActivation,
              child: const Text('Log Parking Activation'),
            ),

            ElevatedButton(
              onPressed: _logCreditPurchase,
              child: const Text('Log Credit Purchase'),
            ),

            const SizedBox(height: 20),

            // Crashlytics Examples
            const Text(
              'Crashlytics Examples:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _logNonFatalError,
              child: const Text('Log Non-Fatal Error'),
            ),

            ElevatedButton(
              onPressed: _logApiError,
              child: const Text('Log API Error'),
            ),

            ElevatedButton(
              onPressed: _logPaymentError,
              child: const Text('Log Payment Error'),
            ),

            const SizedBox(height: 20),

            // User Properties
            ElevatedButton(
              onPressed: _setUserProperties,
              child: const Text('Set User Properties'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logCustomEvent() async {
    await FirebaseAnalyticsHelper.logCustomEvent(
      'button_pressed',
      parameters: {
        'button_name': 'custom_event_button',
        'screen': 'firebase_example',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    _showSnackBar('Custom event logged!');
  }

  Future<void> _logParkingActivation() async {
    await FirebaseAnalyticsHelper.logParkingActivation(
      vehicleType: 'car',
      duration: 120, // 2 hours
      amount: 3.50,
      zone: 'Zona Azul',
    );

    _showSnackBar('Parking activation logged!');
  }

  Future<void> _logCreditPurchase() async {
    await FirebaseAnalyticsHelper.logCreditPurchase(
      credits: 100,
      amount: 50.0,
      paymentMethod: 'credit_card',
    );

    _showSnackBar('Credit purchase logged!');
  }

  Future<void> _logNonFatalError() async {
    await FirebaseCrashlyticsHelper.logError(
      Exception('This is a test non-fatal error'),
      StackTrace.current,
      reason: 'User triggered test error from Firebase example',
    );

    _showSnackBar('Non-fatal error logged!');
  }

  Future<void> _logApiError() async {
    await FirebaseCrashlyticsHelper.recordApiError(
      endpoint: '/api/test/error',
      statusCode: 500,
      method: 'POST',
      errorMessage: 'Internal server error - test from Firebase example',
    );

    _showSnackBar('API error logged!');
  }

  Future<void> _logPaymentError() async {
    await FirebaseCrashlyticsHelper.recordPaymentError(
      paymentMethod: 'credit_card',
      amount: 50.0,
      errorCode: 'CARD_DECLINED',
      errorMessage: 'Test payment error from Firebase example',
    );

    _showSnackBar('Payment error logged!');
  }

  Future<void> _setUserProperties() async {
    await FirebaseAnalyticsHelper.setUserProperties(
      userId: 'test_user_123',
      userType: 'premium',
      city: 'vicosa',
      vehicleType: 'car',
    );

    _showSnackBar('User properties set!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Example of how to integrate Firebase logging in existing screens
mixin FirebaseScreenMixin<T extends StatefulWidget> on State<T> {
  String get screenName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAnalyticsHelper.logScreenView(screenName);
    });
  }
}

/// Example usage of the mixin:
/// 
/// class MyScreen extends StatefulWidget {
///   @override
///   State<MyScreen> createState() => _MyScreenState();
/// }
/// 
/// class _MyScreenState extends State<MyScreen> with FirebaseScreenMixin {
///   @override
///   String get screenName => 'my_screen';
///   
///   // Your widget implementation...
/// }
