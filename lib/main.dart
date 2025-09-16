import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotativo/screens/widgets/loader.dart';

// Config
import 'config/dynamic_app_config.dart';
import 'config/environment.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/environment_provider.dart';

// Services
import 'services/notification_service.dart';
import 'services/parking_notification_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cards/cards_screen.dart';
import 'screens/settings/biometric_settings_screen.dart';

void main() {
  // Configurar tratamento de erros para eventos de ponteiro
  _configureErrorHandling();

  // Initialize app environment configuration
  _initializeApp();

  runApp(const ProviderScope(child: RotativoApp()));
}

/// Initialize Google Maps
Future<void> _initializeGoogleMaps() async {
  // A API Key é configurada no AppDelegate.swift
  // Aqui apenas garantimos que o plugin está pronto
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    // Para iOS, a inicialização é feita no AppDelegate.swift
    return;
  }
}

/// Configure error handling for pointer events
void _configureErrorHandling() {
  // Configurar tratamento de erros para eventos de ponteiro
  FlutterError.onError = (FlutterErrorDetails details) {
    // Filtrar erros relacionados ao MouseTracker
    if (details.exception.toString().contains('MouseTracker') ||
        details.exception.toString().contains('PointerAddedEvent') ||
        details.exception.toString().contains('PointerRemovedEvent')) {
      // Log do erro mas não quebrar o app
      debugPrint('Pointer event error handled: ${details.exception}');
      return;
    }

    // Para outros erros, usar o handler padrão
    FlutterError.presentError(details);
  };

  // Configurar tratamento de erros assíncronos
}

/// Initialize app configuration
/// Change Environment.setEnvironment('dev') to switch to development
void _initializeApp() {
  // 🔧 CONFIGURE ENVIRONMENT HERE:
  Environment.setEnvironment('dev'); // Use development APIs (default)
  //Environment.setEnvironment('prod'); // Use production APIs

  // Print current configuration for debugging
  Environment.printCurrentConfig();
}

class RotativoApp extends ConsumerWidget {
  const RotativoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializa o provider do ambiente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(environmentProvider.notifier).initialize();
    });

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

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Garantir que a inicialização seja feita apenas uma vez
    // Adicionar delay para garantir estado estável
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_hasInitialized) {
          setState(() {
            _hasInitialized = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Sempre mostrar loader durante o estado de loading para evitar flash
    // Também mostrar loader durante a inicialização para garantir estado estável
    // Adicionar delay adicional para garantir estado completamente estável
    if (authState.isLoading || !_hasInitialized) {
      if (kDebugMode) {
        print(
            '🔄 AuthWrapper: Mostrando loader - isLoading: ${authState.isLoading}, hasInitialized: $_hasInitialized');
      }
      return const LoaderWidget();
    }

    // Verificar se o estado está completamente carregado e estável
    // Só navegar se não estiver mais carregando e tiver um estado definitivo
    // Adicionar verificação adicional para garantir estado estável
    if (authState.user != null &&
        authState.user!.isAuthenticated &&
        !authState.isLoading) {
      if (kDebugMode) {
        print('🔄 AuthWrapper: Navegando para HomePage - usuário autenticado');
      }
      // Envolve a HomePage com os monitores de notificações
      return ParkingNotificationMonitor(
        child: ActivationNotificationMonitor(
          child: HomePage(),
        ),
      );
    } else {
      if (kDebugMode) {
        print(
            '🔄 AuthWrapper: Navegando para LoginScreen - usuário não autenticado');
      }
      // Estado definitivo: usuário não autenticado ou erro
      // Garantir que não há mudanças de estado durante a navegação
      return const LoginScreen();
    }
  }
}
