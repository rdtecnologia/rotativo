import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../models/history_models.dart';
import '../../providers/order_detail_provider.dart';
import '../../services/history_service.dart';
import '../../utils/formatters.dart';

// Widget otimizado para mensagem de cópia
class CopyMessageWidget extends ConsumerWidget {
  const CopyMessageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copyMessageState = ref.watch(copyMessageProvider);

    if (!copyMessageState.isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Text(
        copyMessageState.message,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Widget otimizado para seção de chargeback
class ChargebackSection extends StatelessWidget {
  final OrderDetail order;

  const ChargebackSection({
    super.key,
    required this.order,
  });

  Widget _buildDetailBox({
    required String title,
    required List<Widget> children,
    bool fullBorder = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: fullBorder
            ? Border.all(color: Colors.red, width: 2)
            : Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    inspect('build');
    final chargeback = order.chargeback;
    if (chargeback?.last?.status == null) return const SizedBox.shrink();

    return _buildDetailBox(
      title: 'Solicitação de reembolso:',
      fullBorder: true,
      children: [
        _buildDetailItem('Status do reembolso:', chargeback!.last!.status),
        _buildDetailItem(
          'Data da solicitação:',
          AppFormatters.formatDateTime(chargeback.last!.createdAt),
        ),
        _buildDetailItem(
          'Última atualização:',
          AppFormatters.formatDateTime(chargeback.last!.updatedAt),
        ),
        _buildDetailItem(
          'Valor do reembolso:',
          'R\$ ${AppFormatters.formatCurrency(chargeback.last!.value)}',
        ),
        const SizedBox(height: 8),
        const Text(
          'O saldo referente a esse pedido está bloqueado e não pode ser usado devido a solicitação de cancelamento',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// Widget otimizado para seção de detalhes principais
class MainDetailsSection extends StatelessWidget {
  final OrderDetail order;
  final Function(String, String) onCopyToClipboard;
  final Function(String) onShowQRCode;
  final Function(String) onShowPDF;
  final VoidCallback onShowCancelDialog;

  const MainDetailsSection({
    super.key,
    required this.order,
    required this.onCopyToClipboard,
    required this.onShowQRCode,
    required this.onShowPDF,
    required this.onShowCancelDialog,
  });

  String _getVehicleTypeText(int? vehicleType) {
    if (vehicleType == null) return 'Não informado';
    return vehicleType == 1 ? 'Carro' : 'Moto';
  }

  String _getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'pix':
        return 'PIX';
      case 'billet':
      case 'boleto':
      case 'boleto bancário':
      case 'boleto bancario':
        return 'Boleto';
      case 'credit_card':
      case 'creditcard':
        return 'Cartão de Crédito';
      default:
        return method.isEmpty ? 'Dinheiro' : method;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'pix':
        return Icons.pix;
      case 'billet':
        return Icons.receipt_long;
      case 'credit_card':
      case 'creditcard':
        return Icons.credit_card;
      default:
        return Icons.money;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'pix':
        return Colors.green;
      case 'billet':
        return Colors.orange;
      case 'credit_card':
      case 'creditcard':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pago':
        return Colors.green.shade700;
      case 'aguardando pagamento':
        return Colors.orange.shade700;
      case 'cancelado':
      case 'cancelled':
        return Colors.red.shade700;
      case 'expirado':
      case 'expired':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // Helper method to get boleto data from payments
  String? _getBoletoUrl() {
    if (order.payments.isEmpty) return null;

    if (kDebugMode) {
      print('🔍 DEBUG - Payments count: ${order.payments.length}');
      for (int i = 0; i < order.payments.length; i++) {
        final payment = order.payments[i];
        print(
            '🔍 DEBUG - Payment $i: method=${payment.method}, status=${payment.status}, billet=${payment.billet?.url ?? "null"}');
      }
    }

    // Try to find boleto payment
    final boletoPayment = order.payments.firstWhere(
      (p) =>
          p.method.toLowerCase().contains('boleto') ||
          p.method.toLowerCase().contains('billet'),
      orElse: () => order.payments.first,
    );

    if (kDebugMode) {
      print(
          '🔍 DEBUG - Selected payment: method=${boletoPayment.method}, billet=${boletoPayment.billet?.url ?? "null"}');
    }

    return boletoPayment.billet?.url;
  }

  Widget _buildDetailBox({
    required String title,
    required List<Widget> children,
    bool fullBorder = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: fullBorder
            ? Border.all(color: Colors.red, width: 2)
            : Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value,
      {VoidCallback? onTap, bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isLink ? Colors.blue : Colors.black87,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = order.payments.isNotEmpty ? order.payments.first : null;

    return _buildDetailBox(
      title: '',
      children: [
        _buildDetailItem(
            'Valor:', 'R\$ ${AppFormatters.formatCurrency(order.value)}'),

        if (order.products.isNotEmpty &&
            order.products.first.vehicleType != null)
          _buildDetailItem(
            'Tipo de veículo:',
            _getVehicleTypeText(order.products.first.vehicleType),
          ),

        _buildDetailItem(
          'Data da compra:',
          AppFormatters.formatDateTime(order.createdAt),
        ),

        // Status da compra destacado
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Status da compra:',
                '',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // Botão de cancelamento para compras pagas
        if (order.status == 'Pago' && order.chargeback?.action != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (order.chargeback?.last != null ||
                      (order.chargeback?.message != null &&
                          order.chargeback!.message.isNotEmpty))
                  ? null // Desabilita se já há solicitação em curso OU se passou dos 15 dias (mensagem não vazia)
                  : onShowCancelDialog,
              icon: Icon(
                (order.chargeback?.last != null ||
                        (order.chargeback?.message != null &&
                            order.chargeback!.message.isNotEmpty))
                    ? Icons.block
                    : Icons.cancel_outlined,
              ),
              label: Text(
                order.chargeback?.last != null
                    ? 'Solicitação em Andamento'
                    : (order.chargeback?.message != null &&
                            order.chargeback!.message.isNotEmpty)
                        ? 'Prazo Expirado'
                        : 'Solicitar Cancelamento',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: (order.chargeback?.last != null ||
                        (order.chargeback?.message != null &&
                            order.chargeback!.message.isNotEmpty))
                    ? Colors.grey
                    : Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],

        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Meio de pagamento:',
                payment != null
                    ? _getPaymentMethodText(payment.method)
                    : 'Dinheiro',
              ),
            ),
            if (payment != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(payment.method)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentMethodIcon(payment.method),
                  color: _getPaymentMethodColor(payment.method),
                  size: 24,
                ),
              ),
            ],
          ],
        ),

        // PIX details - only show if payment is pending
        if (payment?.pix != null &&
            payment!.status == 'Aguardando Pagamento') ...[
          const SizedBox(height: 16),

          // Container atrativo para PIX
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagamento via PIX',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Escaneie o QR Code ou copie a chave PIX para efetuar o pagamento.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                // Código PIX copiável
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Código PIX:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              payment.pix!.text,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onCopyToClipboard(
                          payment.pix!.text,
                          'Código PIX copiado para sua área de transferência',
                        ),
                        icon: const Icon(Icons.copy, color: Colors.green),
                        tooltip: 'Copiar código PIX',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botão para visualizar QR Code
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onShowQRCode(payment.pix!.text),
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Ver QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Billet details
        if (payment?.billet != null) ...[
          const SizedBox(height: 16),

          // Container atrativo para Boleto
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagamento via Boleto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seu boleto foi gerado. Pague até o vencimento em qualquer banco, lotérica ou internet banking.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                // Data de vencimento
                if (payment!.billet!.expirationDate.isNotEmpty) ...[
                  _buildDetailItem(
                    'Data de vencimento:',
                    payment.billet!.expirationDate,
                  ),
                  const SizedBox(height: 16),
                ],

                // Linha digitável copiável
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Linha Digitável:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              payment.billet!.lineCode,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onCopyToClipboard(
                          payment.billet!.lineCode,
                          'Linha digitável copiada para sua área de transferência',
                        ),
                        icon: const Icon(Icons.copy, color: Colors.orange),
                        tooltip: 'Copiar linha digitável',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botão de visualizar boleto
                if (_getBoletoUrl() != null && _getBoletoUrl()!.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onShowPDF(_getBoletoUrl()!),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Visualizar Boleto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        // Credit card details
        if (payment?.creditCard != null) ...[
          _buildDetailItem('Cartão:', payment!.creditCard!.number),
          if (payment.creditCard!.holderName != null)
            _buildDetailItem(
                'Titular cartão:', payment.creditCard!.holderName!),
        ],

        // Reference code
        if (order.referenceCode != null)
          _buildDetailItem('Autenticação:', order.referenceCode!),
      ],
    );
  }
}

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load order details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderDetailProvider.notifier).loadOrderDetail(widget.orderId);
    });
  }

  @override
  void dispose() {
    // Clear order detail when leaving screen
    ref.read(orderDetailProvider.notifier).clearOrderDetail();
    super.dispose();
  }

  void _copyToClipboard(String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    ref.read(copyMessageProvider.notifier).showMessage(successMessage);
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o link: $url')),
      );
    }
  }

  void _showCancelOrderDialog(OrderDetail order) {
    final chargeback = order.chargeback;
    if (chargeback?.action == null) return;

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
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Solicitar Cancelamento',
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
                'Tem certeza que deseja solicitar o cancelamento desta compra?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes do Cancelamento:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Valor a ser reembolsado: R\$ ${AppFormatters.formatCurrency(chargeback!.action.value)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '• Créditos a serem reembolsados: ${chargeback.action.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '⚠️ Atenção: Após a solicitação, os créditos ficarão bloqueados até a análise.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
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
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestOrderCancellation(order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Confirmar Solicitação',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _requestOrderCancellation(OrderDetail order) async {
    try {
      // Mostra loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Solicitando cancelamento...'),
              ],
            ),
          );
        },
      );

      // Chama a API de cancelamento
      final chargeback = order.chargeback;
      if (chargeback?.action == null) {
        Navigator.of(context).pop(); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Dados de cancelamento não disponíveis'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await HistoryService.deleteOrder(
        order.id,
        chargeback!.action.value.toString(),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Remove loading
      }

      if (success) {
        // Sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Solicitação de cancelamento enviada com sucesso!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Recarrega os detalhes da compra para atualizar o status
          ref
              .read(orderDetailProvider.notifier)
              .loadOrderDetail(widget.orderId);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading
      }

      // Erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erro ao solicitar cancelamento: ${e.toString()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showQRCodePopup(String pixKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'QR Code PIX',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: QrImageView(
                    data: pixKey,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => _copyToClipboard(
                        pixKey,
                        'Código PIX copiado para sua área de transferência',
                      ),
                      child: const Text('Copiar Código'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPDFPopup(String pdfUrl) {
    if (pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL do boleto não disponível'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (kDebugMode) {
      print('📄 PDF Viewer - Tentando abrir URL: $pdfUrl');
    }

    // Primeiro tenta abrir no visualizador interno
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Visualizar Boleto'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () => _launchUrl(pdfUrl),
                  tooltip: 'Abrir no navegador',
                ),
              ],
            ),
            body: SfPdfViewer.network(
              pdfUrl,
              canShowPaginationDialog: true,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              enableHyperlinkNavigation: true,
            ),
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('📄 PDF Viewer - Erro ao abrir visualizador interno: $e');
      }

      // Se falhar, abre no navegador
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir PDF. Abrindo no navegador...'),
          duration: Duration(seconds: 2),
        ),
      );

      _launchUrl(pdfUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Compra'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade100,
          child: Consumer(
            builder: (context, ref, child) {
              final orderDetailState = ref.watch(orderDetailProvider);
              final isLoading = orderDetailState.isLoading;
              final orderDetail = orderDetailState.orderDetail;
              final error = orderDetailState.error;

              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (error != null) {
                return Center(
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
                        'Erro ao carregar detalhes',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(orderDetailProvider.notifier)
                              .loadOrderDetail(widget.orderId);
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              if (orderDetail == null) {
                return const Center(
                  child: Text('Nenhum detalhe encontrado'),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chargeback section (if exists)
                    ChargebackSection(order: orderDetail),

                    // Main details section
                    MainDetailsSection(
                      order: orderDetail,
                      onCopyToClipboard: _copyToClipboard,
                      onShowQRCode: _showQRCodePopup,
                      onShowPDF: _showPDFPopup,
                      onShowCancelDialog: () =>
                          _showCancelOrderDialog(orderDetail),
                    ),

                    // Copy message - now using Consumer for optimized rebuild
                    CopyMessageWidget(),

                    // Chargeback message (only for paid orders with non-empty message)
                    if (orderDetail.status == 'Pago' &&
                        orderDetail.chargeback?.message != null &&
                        orderDetail.chargeback!.message.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          orderDetail.chargeback!.message,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    // Action buttons
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Voltar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
