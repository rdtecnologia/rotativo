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

  String _getVehicleTypeName(int vehicleType) {
    switch (vehicleType) {
      case 1:
        return 'Carro';
      case 2:
        return 'Moto';
      case 3:
        return 'Caminhão';
      case 4:
        return 'Motocicleta';
      case 5:
        return 'Caminhão Grande';
      default:
        return 'Veículo';
    }
  }

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
    final rules = parkingRules?[vehicleType.toString()] ?? [];
    
    // Find what this amount of credits can buy in parking time
    String timeDescription = '';
    if (rules.isNotEmpty) {
      int totalMinutes = 0;
      int remainingCredits = product.credits;
      
      for (final rule in rules) {
        final timesCanBuy = remainingCredits ~/ rule.credits;
        if (timesCanBuy > 0) {
          totalMinutes += timesCanBuy * rule.time;
          remainingCredits -= timesCanBuy * rule.credits;
        }
      }
      
      if (totalMinutes > 0) {
        if (totalMinutes < 60) {
          timeDescription = '≈ ${totalMinutes}min de estacionamento';
        } else {
          final hours = totalMinutes ~/ 60;
          final minutes = totalMinutes % 60;
          if (minutes == 0) {
            timeDescription = '≈ ${hours}h de estacionamento';
          } else {
            timeDescription = '≈ ${hours}h ${minutes}min de estacionamento';
          }
        }
      }
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectProduct(context, ref, product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Credits
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.credits}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Text(
                        'créditos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${AppFormatters.formatCurrency(product.price)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'valor total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (timeDescription.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    timeDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Expanded(child: SizedBox()),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParkingRulesInfo(Map<String, List<ParkingRule>>? parkingRules) {
    final rules = parkingRules?[vehicleType.toString()] ?? [];
    
    if (rules.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valores de estacionamento para ${_getVehicleTypeName(vehicleType)}:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          ...rules.map((rule) => Padding(
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
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityConfigAsync = ref.watch(cityConfigProvider);
    final parkingRulesAsync = ref.watch(parkingRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Créditos para ${_getVehicleTypeName(vehicleType)}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha a quantidade de créditos:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Parking rules info
            parkingRulesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (parkingRules) => _buildParkingRulesInfo(parkingRules),
            ),
            
            Expanded(
              child: cityConfigAsync.when(
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

                  return parkingRulesAsync.when(
                    loading: () => ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildProductCard(context, ref, products[index], null),
                        );
                      },
                    ),
                    error: (_, __) => ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildProductCard(context, ref, products[index], null),
                        );
                      },
                    ),
                    data: (parkingRules) => ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildProductCard(context, ref, products[index], parkingRules),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
