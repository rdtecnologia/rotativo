import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/purchase_models.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/formatters.dart';

class PaymentDetailScreen extends ConsumerStatefulWidget {
  final int vehicleType;
  final ProductOption product;
  final PaymentMethodType paymentMethod;

  const PaymentDetailScreen({
    Key? key,
    required this.vehicleType,
    required this.product,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  ConsumerState<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  OrderResponse? _orderResponse;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-process order for PIX and Boleto (no additional data needed)
    if (widget.paymentMethod == PaymentMethodType.pix || 
        widget.paymentMethod == PaymentMethodType.boleto) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processOrder();
      });
    }
  }

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

  Future<void> _processOrder() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;
      
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Create payment data based on method
      PaymentData paymentData;
      
      if (widget.paymentMethod == PaymentMethodType.creditCard) {
        // For now, we'll create a simple credit card payment
        // In a real app, this would come from a credit card form
        final holder = HolderCard(
          name: user.name ?? '',
          document: user.cpf ?? '',
          email: user.email ?? '',
          mobile: user.phone ?? '',
        );
        
        final creditCard = CreditCardOrder(
          number: '4111111111111111', // Test card
          expirationMonth: '12',
          expirationYear: '2025',
          cvc: '123',
          store: false,
          holder: holder,
        );
        
        paymentData = PaymentData(
          method: widget.paymentMethod,
          creditCard: creditCard,
        );
      } else {
        paymentData = PaymentData(
          method: widget.paymentMethod,
        );
      }

      final payment = Payment(
        gateway: 'pagSeguro',
        data: paymentData,
      );

      final purchaseProduct = PurchaseProduct(
        productId: 13, // From city config
        quantity: widget.product.credits,
        vehicleType: widget.vehicleType,
      );

      final order = PurchaseOrder(
        products: [purchaseProduct],
        payment: payment,
      );

      final response = await ref.read(purchaseProvider.notifier).createOrder(order);
      
      setState(() {
        _orderResponse = response;
        _isProcessing = false;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
    }
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

  void _showQRCodePopup(String pixCode) {
    if (pixCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código PIX não disponível'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                    data: pixCode,
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
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: pixCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código PIX copiado para sua área de transferência'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
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

  Widget _buildOrderSummary() {
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
              const Text('Forma de Pagamento:', style: TextStyle(fontSize: 16)),
              Text(
                _getPaymentMethodName(widget.paymentMethod),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Valor Total:', style: TextStyle(fontSize: 16)),
              Text(
                'R\$ ${AppFormatters.formatCurrency(widget.product.price)}',
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

  Widget _buildProcessingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        const Text(
          'Processando seu pedido...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aguarde enquanto processamos seu pagamento',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 24),
        const Text(
          'Erro no Pagamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Ocorreu um erro ao processar seu pedido',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _processOrder,
          child: const Text('Tentar Novamente'),
        ),
      ],
    );
  }

  Widget _buildSuccessView(OrderResponse order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success icon and message
        Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green[600],
              ),
              const SizedBox(height: 16),
              const Text(
                'Pedido Criado com Sucesso!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Número do pedido: #${order.id}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Order details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalhes do Pedido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status:'),
                  Text(
                    order.status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Data:'),
                  Text(
                    AppFormatters.formatDateTime(order.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Valor:'),
                  Text(
                    'R\$ ${AppFormatters.formatCurrency(order.value)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Payment-specific instructions
        if (widget.paymentMethod == PaymentMethodType.boleto) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instruções para Pagamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seu boleto foi gerado. Pague até o vencimento em qualquer banco, lotérica ou internet banking.',
                ),
                const SizedBox(height: 16),
                
                // Linha digitável copiável
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[300]!),
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
                              order.boletoLineCode ?? 'Linha digitável não disponível',
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
                        onPressed: () {
                          if (order.boletoLineCode != null) {
                            Clipboard.setData(ClipboardData(text: order.boletoLineCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Linha digitável copiada para a área de transferência!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy, color: Colors.orange),
                        tooltip: 'Copiar linha digitável',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botão de visualizar boleto
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showPDFPopup(order.boletoUrl ?? ''),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Visualizar Boleto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        if (widget.paymentMethod == PaymentMethodType.pix) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagamento via PIX',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Escaneie o QR Code ou copie a chave PIX para efetuar o pagamento.',
                ),
                const SizedBox(height: 16),
                
                // Código PIX copiável
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!),
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
                              order.pixCodeFromPayments ?? 'Código PIX não disponível',
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
                        onPressed: () {
                          if (order.pixCodeFromPayments != null) {
                            Clipboard.setData(ClipboardData(text: order.pixCodeFromPayments!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Código PIX copiado para a área de transferência!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy, color: Colors.green),
                        tooltip: 'Copiar código PIX',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botões de ação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showQRCodePopup(order.pixCodeFromPayments ?? ''),
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
        
        const SizedBox(height: 24),
        
        // Botão voltar ao início
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Voltar ao início para ativar'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPaymentMethodName(widget.paymentMethod)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildOrderSummary(),
              
              _isProcessing
                  ? _buildProcessingView()
                  : _error != null
                      ? _buildErrorView()
                      : _orderResponse != null
                          ? _buildSuccessView(_orderResponse!)
                          : widget.paymentMethod == PaymentMethodType.creditCard
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Cartão de Crédito',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Funcionalidade em desenvolvimento.\nPor favor, use PIX ou Boleto.',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Voltar'),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
              
              // Espaço extra no final para evitar que o último elemento fique cortado
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
