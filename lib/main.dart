import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotativo/screens/widgets/loader.dart';

// Config
import 'config/dynamic_app_config.dart';
import 'config/environment.dart';

// Providers
import 'providers/auth_provider.dart';

// Services
import 'services/notification_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cards/cards_screen.dart';
import 'screens/settings/biometric_settings_screen.dart';

void main() {
  // Initialize app environment configuration
  _initializeApp();

  runApp(const ProviderScope(child: RotativoApp()));
}

/// Initialize app configuration
/// Change Environment.setEnvironment('dev') to switch to development
void _initializeApp() {
  // 🔧 CONFIGURE ENVIRONMENT HERE:
  //Environment.setEnvironment('dev'); // Use development APIs
  Environment.setEnvironment('prod'); // Use production APIs (default)

  // Print current configuration for debugging
  Environment.printCurrentConfig();
}

class RotativoApp extends ConsumerWidget {
  const RotativoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: DynamicAppConfig.displayName,
      builder: (context, snapshot) {
        final title = snapshot.data ?? 'Rotativo Digital';
        return MaterialApp(
          title: title,
          theme: ThemeData(
            //colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            colorScheme: ColorScheme(
              brightness: Brightness.light,
              error: Colors.red,
              onError: Colors.white,
              primary: const Color.fromARGB(255, 90, 123, 151),
              secondary: Colors.orange,
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.black87,
            ),

            useMaterial3: true,
          ),
          home: const SplashScreen(),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/home': (context) => const HomePage(),
            '/login': (context) => const LoginScreen(),
            '/cards': (context) => const CardsScreen(),
            '/biometric-settings': (context) => const BiometricSettingsScreen(),
            '/auth': (context) => const AuthWrapper(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const LoaderWidget();
    }

    if (authState.isAuthenticated) {
      // Envolve a HomePage com o monitor de notificações
      return const ActivationNotificationMonitor(
        child: HomePage(),
      );
    } else {
      return const LoginScreen();
    }
  }
}
