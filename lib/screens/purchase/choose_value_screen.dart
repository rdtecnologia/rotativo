import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/purchase_models.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/choose_value_provider.dart';
import '../../utils/formatters.dart';
import '../../config/dynamic_app_config.dart';
import '../../widgets/custom_value_section.dart';
import 'payment_method_screen.dart';

class ChooseValueScreen extends ConsumerStatefulWidget {
  final int vehicleType;

  const ChooseValueScreen({
    super.key,
    required this.vehicleType,
  });

  @override
  ConsumerState<ChooseValueScreen> createState() => _ChooseValueScreenState();
}

class _ChooseValueScreenState extends ConsumerState<ChooseValueScreen> {
  @override
  void dispose() {
    // Reset do provider quando a tela for descartada
    ref.read(chooseValueProvider.notifier).reset();
    super.dispose();
  }

  void _selectProduct(
      BuildContext context, WidgetRef ref, ProductOption product) {
    ref.read(purchaseProvider.notifier).selectProduct(product);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          vehicleType: widget.vehicleType,
          product: product,
        ),
      ),
    );
  }

  void _purchaseCustomValue(BuildContext context, WidgetRef ref) async {
    final chooseValueState = ref.read(chooseValueProvider);

    if (!chooseValueState.isCustomValueValid ||
        chooseValueState.customValue == null) {
      return;
    }

    try {
      // Carregar a configuração de compra da cidade para obter a relação preço/crédito
      final purchaseConfig = await DynamicAppConfig.purchase;

      if (purchaseConfig.isEmpty) {
        throw Exception('Configuração de compra não encontrada');
      }

      final products = purchaseConfig['products'] as Map<String, dynamic>?;
      if (products == null) {
        throw Exception('Produtos não encontrados na configuração');
      }

      final vehicleProducts =
          products[widget.vehicleType.toString()] as List<dynamic>?;
      if (vehicleProducts == null || vehicleProducts.isEmpty) {
        throw Exception('Produtos para este tipo de veículo não encontrados');
      }

      // Usar o valor fixo por crédito conforme a configuração da cidade
      const double pricePerCredit = 0.50; // R$ 0,50 por crédito

      // Calcular quantos créditos o usuário deve receber pelo valor digitado
      final calculatedCredits =
          (chooseValueState.customValue! / pricePerCredit).round();

      if (kDebugMode) {
        print('🔍 DEBUG - Cálculo de créditos customizados:');
        print('🔍 Valor digitado: R\$ ${chooseValueState.customValue}');
        print('🔍 Preço por crédito: R\$ ${pricePerCredit.toStringAsFixed(2)}');
        print('🔍 Créditos calculados: $calculatedCredits');
        print('🔍 Tipo de veículo: ${widget.vehicleType}');
      }

      // Criar um ProductOption customizado com os créditos calculados
      final customProduct = ProductOption(
        credits: calculatedCredits,
        price: chooseValueState.customValue!,
      );

      ref.read(purchaseProvider.notifier).selectProduct(customProduct);

      // Verificar se o contexto ainda é válido antes de navegar
      if (!mounted) return;

      // Navegar para a próxima tela usando um callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateToPaymentMethod(context, customProduct);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('🔍 ERRO ao calcular créditos customizados: $e');
      }

      // Fallback: usar 1 crédito por real (assumindo valor padrão)
      final customProduct = ProductOption(
        credits: chooseValueState.customValue!.round(),
        price: chooseValueState.customValue!,
      );

      ref.read(purchaseProvider.notifier).selectProduct(customProduct);

      // Verificar se o contexto ainda é válido antes de navegar
      if (!mounted) return;

      // Navegar para a próxima tela usando um callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateToPaymentMethod(context, customProduct);
        }
      });
    }
  }

  void _navigateToPaymentMethod(BuildContext context, ProductOption product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          vehicleType: widget.vehicleType,
          product: product,
        ),
      ),
    );
  }

  Widget _buildParkingRulesInfo(Map<String, List<ParkingRule>>? parkingRules) {
    final carRules = parkingRules?['1'] ?? []; // Carro
    final motorcycleRules = parkingRules?['2'] ?? []; // Moto

    if (carRules.isEmpty && motorcycleRules.isEmpty) {
      return const SizedBox.shrink();
    }

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

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    ProductOption product,
    Map<String, List<ParkingRule>>? parkingRules,
  ) {
    return Card(
      elevation: 0,
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

  @override
  Widget build(BuildContext context) {
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

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Digite um valor ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Seção de valor customizado usando o widget separado
              CustomValueSection(
                onPurchase: () => _purchaseCustomValue(context, ref),
              ),

              const Text(
                'ou selecione o valor a adquirir',
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
                  final products =
                      config.getProductsForVehicleType(widget.vehicleType);

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
