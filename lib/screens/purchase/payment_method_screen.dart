import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/purchase_models.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/formatters.dart';
import 'payment_detail_screen.dart';

class PaymentMethodScreen extends ConsumerWidget {
  final int vehicleType;
  final ProductOption product;

  const PaymentMethodScreen({
    Key? key,
    required this.vehicleType,
    required this.product,
  }) : super(key: key);

  String _getPaymentMethodName(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.creditCard:
        return 'Cartão de Crédito';
      case PaymentMethodType.boleto:
        return 'Boleto Bancário';
      case PaymentMethodType.pix:
        return 'PIX';
    }
  }

  String _getPaymentMethodDescription(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.creditCard:
        return 'Pagamento instantâneo com aprovação imediata';
      case PaymentMethodType.boleto:
        return 'Pague em qualquer banco até o vencimento';
      case PaymentMethodType.pix:
        return 'Transferência instantânea via PIX';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.creditCard:
        return Icons.credit_card;
      case PaymentMethodType.boleto:
        return Icons.receipt_long;
      case PaymentMethodType.pix:
        return Icons.pix;
    }
  }

  Color _getPaymentMethodColor(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.creditCard:
        return Colors.blue;
      case PaymentMethodType.boleto:
        return Colors.orange;
      case PaymentMethodType.pix:
        return Colors.green;
    }
  }

  void _selectPaymentMethod(BuildContext context, WidgetRef ref, PaymentMethodType method) {
    ref.read(purchaseProvider.notifier).selectPaymentMethod(method);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(
          vehicleType: vehicleType,
          product: product,
          paymentMethod: method,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    WidgetRef ref,
    PaymentMethodType method,
  ) {
    final color = _getPaymentMethodColor(method);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectPaymentMethod(context, ref, method),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentMethodIcon(method),
                  size: 32,
                  color: color,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodName(method),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPaymentMethodDescription(method),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo da Compra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Créditos:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${product.credits} créditos',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valor Total:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                'R\$ ${AppFormatters.formatCurrency(product.price)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityConfigAsync = ref.watch(cityConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forma de Pagamento'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(context),
            
            const Text(
              'Escolha a forma de pagamento:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
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
                        'Erro ao carregar formas de pagamento',
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
                  final availableMethods = config.payment.availableMethods;
                  
                  if (availableMethods.isEmpty) {
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
                            'Nenhuma forma de pagamento disponível',
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

                  return ListView.builder(
                    itemCount: availableMethods.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPaymentMethodCard(
                          context,
                          ref,
                          availableMethods[index],
                        ),
                      );
                    },
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
