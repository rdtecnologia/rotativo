import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Config
import 'config/dynamic_app_config.dart';
import 'config/environment.dart';

// Models
import 'models/vehicle_models.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/balance_provider.dart';
import 'providers/active_activations_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/purchase/choose_value_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/parking/parking_screen.dart';

// Widgets
import 'widgets/vehicle_carousel.dart';
import 'widgets/balance_card.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/parking_background.dart';

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

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? cityName;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    debugPrint('🅿️ Main - initState: Iniciando tela principal');
    _focusNode = FocusNode();
    _loadData();
    debugPrint('🅿️ Main - initState: _loadData chamado');
    
    // Adiciona listener para detectar quando a tela recebe foco
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        debugPrint('🅿️ Main - FocusNode: Tela recebeu foco');
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Quando o app volta ao estado ativo (resumed), atualiza o saldo
    if (state == AppLifecycleState.resumed) {
      _updateBalanceOnly();
    }
  }

  Future<void> _loadData() async {
    // Load city name
    cityName = await DynamicAppConfig.cityName;
    setState(() {}); // Update UI with city name

    // Load vehicles and balance from API
    await ref.read(vehicleProvider.notifier).loadVehicles();
    ref.read(balanceProvider.notifier).loadBalance();
    
    // Carrega as ativações ativas para todos os veículos após os veículos serem carregados
    await _loadActiveActivations();
  }

  Future<void> _refreshData() async {
    await _loadData();
    // Recarrega as ativações ativas
    await _loadActiveActivations();
  }

  /// Atualiza apenas o saldo sem recarregar toda a tela
  Future<void> _updateBalanceOnly() async {
    ref.read(balanceProvider.notifier).loadBalance();
    // Também atualiza as ativações ativas
    await _loadActiveActivations();
  }

  /// Carrega as ativações ativas para todos os veículos
  Future<void> _loadActiveActivations() async {
    final vehicleState = ref.read(vehicleProvider);
   // debugPrint('🅿️ Main - _loadActiveActivations: ${vehicleState.vehicles.length} veículos carregados');
    if (vehicleState.vehicles.isNotEmpty) {
      //debugPrint('🅿️ Main - _loadActiveActivations: Iniciando carregamento para veículos: ${vehicleState.vehicles.map((v) => v.licensePlate).join(', ')}');
      await ref.read(activeActivationsProvider.notifier).loadActiveActivationsForVehicles(vehicleState.vehicles);
    } else {
      //debugPrint('🅿️ Main - _loadActiveActivations: Nenhum veículo disponível ainda');
    }
  }

  void _onVehicleTap(Vehicle vehicle) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingScreen(vehicle: vehicle),
      ),
    );
    // Quando retorna da tela de estacionamento, atualiza o saldo e ativações
    await _updateBalanceOnly();
    await _loadActiveActivations();
  }

  void _onPurchaseTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseValueScreen(vehicleType: 1), // 1 = carro
      ),
    );
    // Quando retorna da tela de compra, atualiza o saldo e ativações
    await _updateBalanceOnly();
    await _loadActiveActivations();
  }

  void _onBalanceTap() {
    // TODO: Navigate to balance details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegar para detalhes do saldo')),
    );
  }

  void _onHistoryTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
    // Quando retorna da tela de histórico, atualiza o saldo e ativações
    await _updateBalanceOnly();
    await _loadActiveActivations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: Focus(
        focusNode: _focusNode,
        onFocusChange: (hasFocus) async {
          // Quando a tela recebe foco, atualiza o saldo
          if (hasFocus) {
            await _updateBalanceOnly();
          }
        },
        child: ParkingBackground(
          primaryColor: Theme.of(context).primaryColor,
          opacity: 0.15, // Opacidade menor para a tela principal
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
                          // Debug functionality removed
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Debug mode'),
                              duration: Duration(seconds: 1),
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

                // Vehicle carousel with refresh
                Expanded(
                  flex: 3,
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white,
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
                ),

                // Bottom action cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduzido padding
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
                      
                      const SizedBox(width: 8), // Reduzido de 12 para 8
                      
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
                      
                      const SizedBox(width: 8), // Reduzido de 12 para 8
                      
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
                
                const SizedBox(height: 12), // Reduzido de 16 para 12
              ],
            ),
          ),
        ),
    );
  }
}
