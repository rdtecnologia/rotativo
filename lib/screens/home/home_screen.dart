import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotativo/debug_page.dart';

import '../../models/vehicle_models.dart';
import '../../providers/balance_provider.dart';
import '../../providers/city_config_provider.dart';
import '../../providers/home_screen_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/parking_background.dart';
import '../../widgets/vehicle_carousel.dart';
import '../history/history_screen.dart';
import '../parking/parking_screen.dart';
import '../purchase/choose_value_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    debugPrint('🅿️ Main - initState: Iniciando tela principal');
    _focusNode = FocusNode();

    // Adiciona listener para detectar quando a tela recebe foco
    // Isso garante que os dados sejam recarregados sempre que a tela voltar ao foco
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        debugPrint('🅿️ Main - FocusNode: Tela recebeu foco');
        // Recarrega dados quando a tela recebe foco (retornando de outras telas)
        _reloadDataOnFocus();
      }
    });

    // Garante que loadData seja executado após a tela ser montada
    // Isso cobre o caso da primeira vez que a tela é aberta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      debugPrint(
          '🅿️ Main - PostFrameCallback: _loadData chamado após montagem');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Não é mais necessário o código do RouteAware
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

  // Remove todos os métodos RouteAware que não são mais necessários

  Future<void> _loadData() async {
    // Usa o provider otimizado para carregar todos os dados
    await ref.read(homeScreenProvider.notifier).loadAllData();
  }

  /// Recarrega dados quando a tela recebe foco
  Future<void> _reloadDataOnFocus() async {
    debugPrint('🔄 HomeScreen: Recarregando dados ao focar na tela');
    await ref.read(homeScreenProvider.notifier).reloadOnScreenFocus();
  }

  Future<void> _refreshData() async {
    await ref.read(homeScreenProvider.notifier).refresh();
  }

  /// Atualiza apenas o saldo sem recarregar toda a tela
  Future<void> _updateBalanceOnly() async {
    await ref.read(homeScreenProvider.notifier).updateBalanceAndActivations();
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
  }

  void _onPurchaseTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ChooseValueScreen(vehicleType: 1), // 1 = carro
      ),
    );
    // Quando retorna da tela de compra, atualiza o saldo e ativações
    await _updateBalanceOnly();
  }

  void _onBalanceTap() {
    // TODO: Navigate to balance details screen
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Navegar para detalhes do saldo')),
    // );
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
  }

  @override
  Widget build(BuildContext context) {
    inspect('build');
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: Focus(
        focusNode: _focusNode,
        onFocusChange: (hasFocus) async {
          // Quando a tela recebe foco, atualiza o saldo e ativações
          if (hasFocus) {
            await _updateBalanceOnly();
          }
        },
        child: ParkingBackground(
          primaryColor: Theme.of(context).primaryColor,
          opacity: 0.15,
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
                          child: Consumer(
                            builder: (context, ref, child) {
                              final cityNameAsync = ref.watch(cityNameProvider);
                              return cityNameAsync.when(
                                data: (cityName) => Text(
                                  cityName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                loading: () => const Text(
                                  'Carregando...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                error: (error, stack) => const Text(
                                  'Erro',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 8.0), // Reduzido padding
                child: Row(
                  children: [
                    // Purchase card
                    Expanded(
                      child: ActionCard(
                        icon: Icons.shopping_cart,
                        label: 'COMPRAR',
                        onTap: _onPurchaseTap,
                        backgroundColor: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.8),
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
                        backgroundColor: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.8),
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
