import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/dynamic_app_config.dart';
import 'config/environment.dart';
import 'debug_page.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/purchase/vehicle_type_screen.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/vehicle_carousel.dart';
import 'widgets/balance_card.dart';
import 'models/vehicle_models.dart';
import 'providers/vehicle_provider.dart';
import 'providers/balance_provider.dart';

void main() {
  // Initialize app environment configuration
  _initializeApp();
  
  runApp(const ProviderScope(child: RotativoApp()));
}

/// Initialize app configuration
/// Change Environment.setEnvironment('dev') to switch to development
void _initializeApp() {
  // 🔧 CONFIGURE ENVIRONMENT HERE:
  // Environment.setEnvironment('dev');   // Use development APIs
  Environment.setEnvironment('prod');     // Use production APIs (default)
  
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
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const AuthWrapper(),
          routes: {
            '/home': (context) => const HomePage(),
            '/login': (context) => const LoginScreen(),
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (authState.isAuthenticated) {
      return const HomePage();
    } else {
      return const LoginScreen();
    }
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? cityName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load city name
    cityName = await DynamicAppConfig.cityName;
    setState(() {}); // Update UI with city name

    // Load vehicles and balance from API
    ref.read(vehicleProvider.notifier).loadVehicles();
    ref.read(balanceProvider.notifier).loadBalance();
  }

  void _refreshData() {
    _loadData();
  }

  void _onVehicleTap(Vehicle vehicle) {
    // TODO: Navigate to parking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estacionar veículo ${vehicle.licensePlate}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _onPurchaseTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VehicleTypeScreen(),
      ),
    );
  }

  void _onBalanceTap() {
    // TODO: Navigate to balance details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegar para detalhes do saldo')),
    );
  }

  void _onHistoryTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Menu button
                    IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    // City name
                    Expanded(
                      child: GestureDetector(
                        onTap: _refreshData,
                        child: Center(
                          child: Text(
                            cityName ?? 'Carregando...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Debug button
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DebugPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.bug_report,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Vehicle carousel
              Expanded(
                flex: 3,
                child: Center(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final vehicles = ref.watch(vehicleListProvider);
                      final isLoading = ref.watch(vehicleLoadingProvider);
                      
                      if (isLoading) {
                        return const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        );
                      }
                      
                      return VehicleCarousel(
                        vehicles: vehicles,
                        onVehicleTap: _onVehicleTap,
                      );
                    },
                  ),
                ),
              ),

              // Bottom action cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Purchase card
                    Expanded(
                      child: ActionCard(
                        icon: Icons.shopping_cart,
                        label: 'COMPRAR',
                        onTap: _onPurchaseTap,
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Balance card
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final balance = ref.watch(currentBalanceProvider);
                          final isLoading = ref.watch(balanceLoadingProvider);
                          
                          return BalanceCard(
                            balance: balance,
                            isLoading: isLoading,
                            onTap: _onBalanceTap,
                            displayType: 'credits',
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // History card
                    Expanded(
                      child: ActionCard(
                        icon: Icons.history,
                        label: 'HISTÓRICO',
                        onTap: _onHistoryTap,
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
