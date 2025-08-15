import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/purchase_models.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/formatters.dart';
import 'payment_method_screen.dart';

class ChooseValueScreen extends ConsumerWidget {
  final int vehicleType;

  const ChooseValueScreen({
    Key? key,
    required this.vehicleType,
  }) : super(key: key);

  void _selectProduct(BuildContext context, WidgetRef ref, ProductOption product) {
    ref.read(purchaseProvider.notifier).selectProduct(product);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          vehicleType: vehicleType,
          product: product,
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    ProductOption product,
    Map<String, List<ParkingRule>>? parkingRules,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _selectProduct(context, ref, product),
        child: Container(
          height: 80, // Aumentando a altura do card
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Price (apenas valor monetário)
              Text(
                'R\$ ${AppFormatters.formatCurrency(product.price)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParkingRulesInfo(Map<String, List<ParkingRule>>? parkingRules) {
    final carRules = parkingRules?['1'] ?? []; // Carro
    final motorcycleRules = parkingRules?['2'] ?? []; // Moto
    
    print('🔍 ChooseValueScreen - Building parking rules info');
    print('🔍 ChooseValueScreen - Car rules: ${carRules.length}');
    print('🔍 ChooseValueScreen - Motorcycle rules: ${motorcycleRules.length}');
    
    if (carRules.isEmpty && motorcycleRules.isEmpty) {
      print('🔍 ChooseValueScreen - No parking rules found, returning SizedBox.shrink');
      return const SizedBox.shrink();
    }

    print('🔍 ChooseValueScreen - Building Row with parking rules');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primeira column - Valores para Carro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valores para Carro',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                ...carRules.map((rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${rule.formattedTime} = R\$ ${AppFormatters.formatCurrency(rule.price)} (${rule.credits} créditos)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                )),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Segunda column - Valores para Moto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valores para Moto',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                ...motorcycleRules.map((rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${rule.formattedTime} = R\$ ${AppFormatters.formatCurrency(rule.price)} (${rule.credits} créditos)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityConfigAsync = ref.watch(cityConfigProvider);
    final parkingRulesAsync = ref.watch(parkingRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compra de estacionamento'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh city config and parking rules
          ref.invalidate(cityConfigProvider);
          ref.invalidate(parkingRulesProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Referência de valores para estacionar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Parking rules info for both car and motorcycle
              parkingRulesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (parkingRules) => _buildParkingRulesInfo(parkingRules),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Selecione o valor a adquirir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Grid de produtos
              cityConfigAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar opções de compra',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(cityConfigProvider);
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
                data: (config) {
                  final products = config.getProductsForVehicleType(vehicleType);
                  
                  print('🔍 ChooseValueScreen - Products found: ${products.length}');
                  print('🔍 ChooseValueScreen - Vehicle type: $vehicleType');
                  
                  if (products.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma opção de compra disponível para este tipo de veículo',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: products.map((product) {
                      print('🔍 ChooseValueScreen - Building card for product: ${product.credits} créditos, R\$ ${product.price}');
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 48) / 2,
                        child: _buildProductCard(context, ref, product, null),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
