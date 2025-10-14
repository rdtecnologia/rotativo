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
    super.key,
    required this.vehicleType,
    required this.product,
  });

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

  void _selectPaymentMethod(
      BuildContext context, WidgetRef ref, PaymentMethodType method) {
    // Validação para boleto: valor mínimo de R$ 20,00
    if (method == PaymentMethodType.boleto && product.price < 20.0) {
      _showBoletoMinimumValueDialog(context);
      return;
    }

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

  void _showBoletoMinimumValueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Valor Mínimo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para pagamentos via boleto bancário, o valor mínimo é de R\$ 20,00.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Valor atual: R\$ ${AppFormatters.formatCurrency(product.price)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Entendi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    WidgetRef ref,
    PaymentMethodType method,
  ) {
    final color = _getPaymentMethodColor(method);
    final isBoletoUnavailable =
        method == PaymentMethodType.boleto && product.price < 20.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isBoletoUnavailable ? Colors.grey[100] : null,
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
                  color: isBoletoUnavailable
                      ? Colors.grey[300]
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentMethodIcon(method),
                  size: 32,
                  color: isBoletoUnavailable ? Colors.grey[600] : color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getPaymentMethodName(method),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isBoletoUnavailable
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (isBoletoUnavailable) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[300]!),
                            ),
                            child: Text(
                              'Mín. R\$ 20,00',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBoletoUnavailable
                          ? 'Valor mínimo não atingido para esta opção'
                          : _getPaymentMethodDescription(method),
                      style: TextStyle(
                        fontSize: 14,
                        color: isBoletoUnavailable
                            ? Colors.grey[500]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color:
                    isBoletoUnavailable ? Colors.grey[400] : Colors.grey[400],
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
              const Flexible(
                child: Text(
                  'Valor Total:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  'R\$ ${AppFormatters.formatCurrency(product.price)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.end,
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
      body: SingleChildScrollView(
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

            // Lista de métodos de pagamento
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

                return Column(
                  children: availableMethods
                      .map((method) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPaymentMethodCard(
                              context,
                              ref,
                              method,
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
