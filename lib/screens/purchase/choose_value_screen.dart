import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/purchase_models.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/formatters.dart';
import 'payment_method_screen.dart';

class ChooseValueScreen extends ConsumerStatefulWidget {
  final int vehicleType;

  const ChooseValueScreen({
    Key? key,
    required this.vehicleType,
  }) : super(key: key);

  @override
  ConsumerState<ChooseValueScreen> createState() => _ChooseValueScreenState();
}

class _ChooseValueScreenState extends ConsumerState<ChooseValueScreen> {
  final TextEditingController _customValueController = TextEditingController();
  final FocusNode _customValueFocusNode = FocusNode();
  bool _isCustomValueValid = false;
  double? _customValue;

  @override
  void initState() {
    super.initState();
    _customValueController.addListener(_validateCustomValue);
  }

  @override
  void dispose() {
    _customValueController.dispose();
    _customValueFocusNode.dispose();
    super.dispose();
  }

  void _validateCustomValue() {
    final text = _customValueController.text;
    if (text.isEmpty) {
      setState(() {
        _isCustomValueValid = false;
        _customValue = null;
      });
      return;
    }

    final value = double.tryParse(text);
    if (value != null && value > 0 && value <= 100.0) {
      setState(() {
        _isCustomValueValid = true;
        _customValue = value;
      });
    } else {
      setState(() {
        _isCustomValueValid = false;
        _customValue = null;
      });
    }
  }

  void _selectProduct(BuildContext context, WidgetRef ref, ProductOption product) {
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

  void _purchaseCustomValue(BuildContext context, WidgetRef ref) {
    if (!_isCustomValueValid || _customValue == null) return;

    // Criar um ProductOption customizado
    // Assumindo que 1 crédito = R$ 1,00 (valor padrão)
    final customProduct = ProductOption(
      credits: _customValue!.round(), // 1 crédito por real
      price: _customValue!,
    );

    ref.read(purchaseProvider.notifier).selectProduct(customProduct);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          vehicleType: widget.vehicleType,
          product: customProduct,
        ),
      ),
    );
  }

  Widget _buildCustomValueSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                color: Colors.green.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Valor Personalizado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Digite um valor personalizado para compra (máximo R\$ 100,00)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),
          
          // Campo de valor e botão de compra
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customValueController,
                  focusNode: _customValueFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0,00',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _isCustomValueValid ? Colors.green : Colors.grey.shade400,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _isCustomValueValid ? Colors.green : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: (value) {
                    _validateCustomValue();
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isCustomValueValid ? () => _purchaseCustomValue(context, ref) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: _isCustomValueValid ? 2 : 0,
                ),
                child: const Text(
                  'COMPRAR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          
          // Mensagem de validação
          if (_customValueController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isCustomValueValid ? Icons.check_circle : Icons.error,
                  color: _isCustomValueValid ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isCustomValueValid 
                      ? 'Valor válido! Clique em COMPRAR para continuar.'
                      : 'Valor deve ser maior que R\$ 0,00 e menor ou igual a R\$ 100,00',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isCustomValueValid ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // Informação sobre créditos
          if (_isCustomValueValid && _customValue != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
                                child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Você receberá ${_customValue!.round()} créditos por R\$ ${AppFormatters.formatCurrency(_customValue!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
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
    
    //print('🔍 ChooseValueScreen - Building parking rules info');
    //print('🔍 ChooseValueScreen - Car rules: ${carRules.length}');
    //print('🔍 ChooseValueScreen - Motorcycle rules: ${motorcycleRules.length}');
    
    if (carRules.isEmpty && motorcycleRules.isEmpty) {
      //print('🔍 ChooseValueScreen - No parking rules found, returning SizedBox.shrink');
      return const SizedBox.shrink();
    }

    //print('🔍 ChooseValueScreen - Building Row with parking rules');
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
              
              const SizedBox(height: 24),
              
              // Seção de valor customizado
              _buildCustomValueSection(),
              
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
                  final products = config.getProductsForVehicleType(widget.vehicleType);
                  
                  print('🔍 ChooseValueScreen - Products found: ${products.length}');
                  print('🔍 ChooseValueScreen - Vehicle type: ${widget.vehicleType}');
                  
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
