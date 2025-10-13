import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotativo/screens/widgets/loader.dart';

// Config
import 'config/dynamic_app_config.dart';
import 'config/environment.dart';

// Utils
import 'utils/color_utils.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/environment_provider.dart';

// Services
import 'services/notification_service.dart';
import 'services/parking_notification_service.dart';
import 'services/local_notification_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cards/cards_screen.dart';
import 'screens/settings/biometric_settings_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar tratamento de erros para eventos de ponteiro
  _configureErrorHandling();

  // Initialize app environment configuration
  _initializeApp();

  // Initialize notification service early
  try {
    await LocalNotificationService().initialize();
  } catch (e) {
    //
  }

  runApp(const ProviderScope(child: RotativoApp()));
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

  /// Get contrast color (black or white) for better readability
  Color _getContrastColor(Color color) {
    // Calculate luminance
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Load app configuration including title and colors
  Future<Map<String, dynamic>> _loadAppConfig() async {
    try {
      // Clear cache to ensure fresh config loading
      DynamicAppConfig.clearCache();

      final title = await DynamicAppConfig.displayName;
      final primaryColor = await DynamicAppConfig.primaryColor;
      final secondaryColor = await DynamicAppConfig.secondaryColor;

      if (kDebugMode) {
        print('🎨 Main._loadAppConfig - Title: $title');
        print('🎨 Main._loadAppConfig - Primary Color: $primaryColor');
        print('🎨 Main._loadAppConfig - Secondary Color: $secondaryColor');
      }

      return {
        'title': title,
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading app config: $e');
      }
      // Return fallback values
      return {
        'title': 'Rotativo Digital',
        'primaryColor': '#074733',
        'secondaryColor': '#17428e',
      };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializa o provider do ambiente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(environmentProvider.notifier).initialize();
    });

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadAppConfig(),
      builder: (context, snapshot) {
        final config = snapshot.data ??
            {
              'title': 'Rotativo Digital',
              'primaryColor': '#074733',
              'secondaryColor': '#17428e'
            };
        final title = config['title'] as String;
        final primaryColorHex = config['primaryColor'] as String;
        final secondaryColorHex = config['secondaryColor'] as String;

        if (kDebugMode) {
          print('🎨 Main.build - Config loaded: $config');
          print('🎨 Main.build - Primary Color Hex: $primaryColorHex');
          print('🎨 Main.build - Secondary Color Hex: $secondaryColorHex');
        }

        // Convert hex colors to Color objects
        final primaryColor = ColorUtils.hexToColor(primaryColorHex);
        final secondaryColor = ColorUtils.hexToColor(secondaryColorHex);

        if (kDebugMode) {
          print('🎨 Main.build - Primary Color Object: $primaryColor');
          print('🎨 Main.build - Secondary Color Object: $secondaryColor');
          print(
              '🎨 Main.build - Primary Color Value: ${primaryColor.value.toRadixString(16)}');
          print(
              '🎨 Main.build - Secondary Color Value: ${secondaryColor.value.toRadixString(16)}');
        }

        // Create custom color scheme with both colors
        final colorScheme = ColorUtils.createCustomColorScheme(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        );

        return MaterialApp(
          title: title,
          theme: ThemeData(
            colorScheme: colorScheme,
            useMaterial3: true,
            // Additional theme customizations
            appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
              foregroundColor: _getContrastColor(primaryColor),
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: _getContrastColor(primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: secondaryColor,
                side: BorderSide(color: secondaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
  bool _isInitialLoad = true;

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

    // Mostrar loader apenas durante a carga inicial (checking stored credentials)
    // Não mostrar loader durante tentativas ativas de login (usuário clicando no botão)
    // Isso permite que o loader do botão seja mostrado e os toasts sejam exibidos
    if (!_hasInitialized) {
      if (kDebugMode) {
        print('🔄 AuthWrapper: Mostrando loader - inicialização');
      }
      return const LoaderWidget();
    }

    // Após a inicialização, marcar que não é mais a carga inicial
    // Isso permite que tentativas de login mostrem apenas o loader do botão
    if (_isInitialLoad && !authState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isInitialLoad = false;
          });
        }
      });
    }

    // Durante a carga inicial E loading, mostrar loader full-screen
    if (_isInitialLoad && authState.isLoading) {
      if (kDebugMode) {
        print('🔄 AuthWrapper: Mostrando loader - carga inicial');
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
