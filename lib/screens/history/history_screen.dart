import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/history_models.dart';
import '../../providers/history_provider.dart';
import 'order_detail_screen.dart';
import 'activation_detail_screen.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _ordersScrollController = ScrollController();
  final ScrollController _activationsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).loadOrders(refresh: true);
      ref.read(historyProvider.notifier).loadActivations(refresh: true);
    });

    // Add scroll listeners for pagination
    _ordersScrollController.addListener(_onOrdersScroll);
    _activationsScrollController.addListener(_onActivationsScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ordersScrollController.dispose();
    _activationsScrollController.dispose();
    super.dispose();
  }

  void _onOrdersScroll() {
    if (_ordersScrollController.position.pixels ==
        _ordersScrollController.position.maxScrollExtent) {
      ref.read(historyProvider.notifier).loadOrders();
    }
  }

  void _onActivationsScroll() {
    if (_activationsScrollController.position.pixels ==
        _activationsScrollController.position.maxScrollExtent) {
      ref.read(historyProvider.notifier).loadActivations();
    }
  }

  Future<void> _refreshOrders() async {
    await ref.read(historyProvider.notifier).loadOrders(refresh: true);
  }

  Future<void> _refreshActivations() async {
    await ref.read(historyProvider.notifier).loadActivations(refresh: true);
  }

  Future<void> _deleteOrder(OrderHistory order) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Compra'),
        content: Text(
          'Deseja realmente cancelar a compra de R\$ ${order.value.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await ref.read(historyProvider.notifier).deleteOrder(
            order.id,
            order.value.toString(),
          );

      if (success) {
        Fluttertoast.showToast(
          msg: 'Compra cancelada com sucesso',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        final error = ref.read(historyErrorProvider);
        Fluttertoast.showToast(
          msg: error ?? 'Erro ao cancelar compra',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Histórico',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Compras'),
            Tab(text: 'Ativações'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab(),
          _buildActivationsTab(),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Consumer(
      builder: (context, ref, child) {
        final orders = ref.watch(ordersProvider);
        final isLoading = ref.watch(historyLoadingOrdersProvider);
        final hasMoreData = ref.watch(historyHasMoreDataProvider);
        final error = ref.watch(historyErrorProvider);

        // Show error if exists
        if (error != null && orders.isEmpty && !isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar compras',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(historyProvider.notifier)
                      .loadOrders(refresh: true),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (orders.isEmpty && isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orders.isEmpty && !isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma compra encontrada',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Suas compras aparecerão aqui',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshOrders,
          child: ListView.builder(
            controller: _ordersScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: orders.length + (hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= orders.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final order = orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildActivationsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final activations = ref.watch(activationsProvider);
        final isLoading = ref.watch(historyLoadingActivationsProvider);
        final hasMoreData = ref.watch(historyHasMoreDataProvider);
        final error = ref.watch(historyErrorProvider);

        // Show error if exists
        if (error != null && activations.isEmpty && !isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar ativações',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(historyProvider.notifier)
                      .loadActivations(refresh: true),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (activations.isEmpty && isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (activations.isEmpty && !isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_parking_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma ativação encontrada',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Suas ativações aparecerão aqui',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshActivations,
          child: ListView.builder(
            controller: _activationsScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: activations.length + (hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= activations.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final activation = activations[index];
              return _buildActivationCard(activation);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderHistory order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Compra #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(order.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ ${order.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      if (order.status.toLowerCase() == 'pending')
                        TextButton.icon(
                          onPressed: () => _deleteOrder(order),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Cancelar'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
              if (order.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  order.description!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivationCard(ActivationHistory activation) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivationDetailScreen(
                  activationId: activation.id,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ativação #${activation.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildParkingStatusChip(activation),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activation.licensePlate,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${activation.parkingTime} min',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ativado em ${dateFormat.format(activation.activatedAt)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (activation.expiresAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expira em ${dateFormat.format(activation.expiresAt!)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (activation.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activation.location!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pago':
      case 'completed':
      case 'active':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        displayText = 'Pago';
        break;
      case 'aguardando pagamento':
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        displayText = 'Aguardando pagamento';
        break;
      case 'cancelled':
      case 'expired':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        displayText =
            status.toLowerCase() == 'cancelled' ? 'Cancelado' : 'Expirado';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildParkingStatusChip(ActivationHistory activation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: activation.statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        activation.displayStatus,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
