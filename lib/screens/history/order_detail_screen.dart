import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../models/history_models.dart';
import '../../providers/order_detail_provider.dart';
import '../../utils/formatters.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  String _copyMessage = '';

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
    setState(() {
      _copyMessage = successMessage;
    });
    
    // Clear message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _copyMessage = '';
        });
      }
    });
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

  String _getVehicleTypeText(int? vehicleType) {
    if (vehicleType == null) return 'Não informado';
    return vehicleType == 1 ? 'Carro' : 'Moto';
  }

  String _getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'pix':
        return 'PIX';
      case 'billet':
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

  Widget _buildDetailItem(String label, String value, {VoidCallback? onTap, bool isLink = false}) {
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

  Widget _buildChargebackSection(OrderDetail order) {
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

  Widget _buildMainDetailsSection(OrderDetail order) {
    final payment = order.payments.isNotEmpty ? order.payments.first : null;
    
    return _buildDetailBox(
      title: '',
      children: [
        _buildDetailItem('Valor:', 'R\$ ${AppFormatters.formatCurrency(order.value)}'),
        
        if (order.products.isNotEmpty && order.products.first.vehicleType != null)
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
        
        // Payment method with icon
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Meio de pagamento:', 
                payment != null ? _getPaymentMethodText(payment.method) : 'Dinheiro',
              ),
            ),
            if (payment != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(payment.method).withValues(alpha: 0.1),
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
        if (payment?.pix != null && payment!.status == 'Aguardando Pagamento') ...[
          _buildDetailItem(
            'Chave PIX: Clique na chave abaixo para copiar o código:',
            payment.pix!.text,
            isLink: true,
            onTap: () => _copyToClipboard(
              payment.pix!.text,
              'Código PIX copiado para sua área de transferência',
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showQRCodePopup(payment.pix!.text),
            child: const Text(
              'Visualizar QRCode',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Billet details
        if (payment?.billet != null) ...[
          _buildDetailItem(
            'Data de vencimento:', 
            payment!.billet!.expirationDate.isNotEmpty 
              ? payment.billet!.expirationDate 
              : 'Não informada',
          ),
          _buildDetailItem(
            'Linha Digitável (Clique para copiar):',
            payment.billet!.lineCode,
            isLink: true,
            onTap: () => _copyToClipboard(
              payment.billet!.lineCode,
              'Linha digitável copiada para sua área de transferência',
            ),
          ),
          if (payment.status == 'Aguardando Pagamento') ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showPDFPopup(payment.billet!.url),
              child: const Text(
                'Visualizar boleto',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
        
        // Credit card details
        if (payment?.creditCard != null) ...[
          _buildDetailItem('Cartão:', payment!.creditCard!.number),
          if (payment.creditCard!.holderName != null)
            _buildDetailItem('Titular cartão:', payment.creditCard!.holderName!),
        ],
        
        // Reference code
        if (order.referenceCode != null)
          _buildDetailItem('Autenticação:', order.referenceCode!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderDetailState = ref.watch(orderDetailProvider);
    final isLoading = orderDetailState.isLoading;
    final orderDetail = orderDetailState.orderDetail;
    final error = orderDetailState.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Compra'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade100,
          child: isLoading 
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : error != null
              ? Center(
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
                          ref.read(orderDetailProvider.notifier).loadOrderDetail(widget.orderId);
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : orderDetail != null
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chargeback section (if exists)
                        _buildChargebackSection(orderDetail),
                        
                        // Main details section
                        _buildMainDetailsSection(orderDetail),
                        
                        // Copy message
                        if (_copyMessage.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              _copyMessage,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        
                        // Chargeback message (if exists)
                        if (orderDetail.chargeback?.message != null) ...[
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
                  )
                : const Center(
                    child: Text('Nenhum detalhe encontrado'),
                  ),
        ),
      ),
    );
  }
}
