import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vehicle_models.dart';
import '../../providers/home_screen_provider.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/parking_background.dart';
import 'mixins/home_navigation_mixin.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/vehicle_section.dart';
import 'widgets/home_bottom_actions.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver, HomeNavigationMixin {
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
    await navigateToParking(vehicle, _updateBalanceOnly);
  }

  void _onPurchaseTap() async {
    await navigateToPurchase(_updateBalanceOnly);
  }

  void _onBalanceTap() {
    // TODO: Navigate to balance details screen
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Navegar para detalhes do saldo')),
    // );
  }

  void _onHistoryTap() async {
    await navigateToHistory(_updateBalanceOnly);
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
          //opacity: 0.15,
          primaryColor: Colors.white,
          secondaryColor: Colors.white,
          child: Column(
            children: [
              HomeTopBar(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                onRefresh: _refreshData,
              ),
              VehicleSection(
                onVehicleTap: _onVehicleTap,
                onRefresh: _refreshData,
              ),
              HomeBottomActions(
                onPurchaseTap: _onPurchaseTap,
                onBalanceTap: _onBalanceTap,
                onHistoryTap: _onHistoryTap,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
