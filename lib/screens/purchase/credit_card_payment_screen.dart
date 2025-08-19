import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../models/purchase_models.dart';
import '../../models/card_models.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/card_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class CreditCardPaymentScreen extends ConsumerStatefulWidget {
  final int vehicleType;
  final ProductOption product;

  const CreditCardPaymentScreen({
    super.key,
    required this.vehicleType,
    required this.product,
  });

  @override
  ConsumerState<CreditCardPaymentScreen> createState() => _CreditCardPaymentScreenState();
}

class _CreditCardPaymentScreenState extends ConsumerState<CreditCardPaymentScreen> {
  bool _isProcessing = false;
  String? _error;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvcController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _holderDocumentController = TextEditingController();
  final _holderBirthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load cards when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardProvider.notifier).loadCards();
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    _holderNameController.dispose();
    _holderDocumentController.dispose();
    _holderBirthDateController.dispose();
    super.dispose();
  }

  Future<void> _confirmPurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      if (kDebugMode) {
        AppLogger.purchase('Processing credit card payment');
      }

      // Create payment data for credit card - matching React structure exactly
      final paymentData = PaymentData(
        method: PaymentMethodType.creditCard,
        creditCard: CreditCardOrder(
          number: _cardNumberController.text.replaceAll(' ', ''),
          expirationMonth: _expiryMonthController.text,
          expirationYear: _expiryYearController.text,
          cvc: _cvcController.text,
          store: true, // Sempre salvar o cartão após compra bem-sucedida
          holder: HolderCard(
            name: _holderNameController.text,
            cpf: _holderDocumentController.text.replaceAll(RegExp(r'[^\d]'), ''), // CPF limpo sem máscara
            birthDate: _formatBirthDate(_holderBirthDateController.text),
          ),
        ),
      );

      final payment = Payment(
        gateway: 'pagSeguro', // Gateway padrão usado no React
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
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compra realizada com sucesso!\nID: ${response.id}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error type: ${e.runtimeType}');
        AppLogger.error('Error content: $e');
        if (e is DioException) {
          AppLogger.error('DioException response data: ${e.response?.data}');
          AppLogger.error('DioException status code: ${e.response?.statusCode}');
        }
      }
      
      setState(() {
        _error = ErrorHandler.getErrorMessage(e);
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmPurchaseWithSavedCard(CreditCard savedCard) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      if (kDebugMode) {
        AppLogger.purchase('Processing payment with saved card: ${savedCard.id}');
      }

      // Create payment data for saved card - matching React structure exactly
      // React uses StoredCreditCard with just the ID for saved cards
      final paymentData = PaymentData(
        method: PaymentMethodType.creditCard,
        creditCard: StoredCreditCard(id: savedCard.id),
      );

      final payment = Payment(
        gateway: 'pagSeguro', // Gateway padrão usado no React
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
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compra realizada com sucesso!\nID: ${response.id}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error type: ${e.runtimeType}');
        AppLogger.error('Error content: $e');
        if (e is DioException) {
          AppLogger.error('DioException response data: ${e.response?.data}');
          AppLogger.error('DioException status code: ${e.response?.statusCode}');
        }
      }
      
      setState(() {
        _error = ErrorHandler.getErrorMessage(e);
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Número do cartão é obrigatório';
    }
    
    final cleanNumber = value.replaceAll(' ', '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Número do cartão inválido';
    }
    
    return null;
  }

  String? _validateExpiryMonth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mês é obrigatório';
    }
    
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) {
      return 'Mês inválido (1-12)';
    }
    
    return null;
  }

  String? _validateExpiryYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ano é obrigatório';
    }
    
    final year = int.tryParse(value);
    if (year == null || year < DateTime.now().year) {
      return 'Ano inválido';
    }
    
    return null;
  }

  String? _validateCVC(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVC é obrigatório';
    }
    
    if (value.length < 3 || value.length > 4) {
      return 'CVC inválido';
    }
    
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  String _detectCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    
    if (cleanNumber.startsWith('4')) {
      return 'VISA';
    } else if (cleanNumber.startsWith('5')) {
      return 'MASTER';
    } else if (cleanNumber.startsWith('3')) {
      return 'AMEX';
    } else if (cleanNumber.startsWith('6')) {
      return 'ELO';
    } else if (cleanNumber.startsWith('35') || cleanNumber.startsWith('36') || cleanNumber.startsWith('38')) {
      return 'DINNERS';
    } else if (cleanNumber.startsWith('60') || cleanNumber.startsWith('65')) {
      return 'HIPERCARD';
    }
    
    return 'GENERIC';
  }

  /// Format birth date from DD/MM/AAAA to YYYY-MM-DD format (like React)
  String _formatBirthDate(String input) {
    // Remove separators and check length
    final cleanInput = input.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanInput.length != 8) return '';
    
    final day = cleanInput.substring(0, 2);
    final month = cleanInput.substring(2, 4);
    final year = cleanInput.substring(4, 8);
    
    return '$year-$month-$day'; // Format YYYY-MM-DD like React
  }

  IconData _getCardBrandIcon(String brand) {
    switch (brand.toUpperCase()) {
      case 'VISA':
        return Icons.credit_card;
      case 'MASTER':
        return Icons.credit_card;
      case 'AMEX':
        return Icons.credit_card;
      case 'DINNERS':
        return Icons.credit_card;
      case 'ELO':
        return Icons.credit_card;
      case 'HIPERCARD':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCard = ref.watch(selectedCardProvider);
    final isLoading = ref.watch(cardLoadingProvider);
    final totalValue = widget.product.price; // O preço já é o total para esta opção
    final detectedBrand = _detectCardBrand(_cardNumberController.text);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Compra com Cartão',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Purchase summary
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Resumo da sua compra:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Total value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Valor à pagar:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'R\$ ${AppFormatters.formatCurrency(totalValue)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Payment method
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Forma de Pagamento:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Cartão de Crédito',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Show selected card if available
              if (selectedCard != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.credit_card,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Use o cartão selecionado',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Final ${selectedCard.lastFourDigits}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        Text(
                                          'Cartão salvo para uso futuro',
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Confirm purchase button for saved card
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isProcessing ? null : () => _confirmPurchaseWithSavedCard(selectedCard),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isProcessing
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Confirmar a compra',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Credit card form
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show "ou use um novo cartão" if there's a selected card
                      if (selectedCard != null) ...[
                        const Text(
                          'ou use um novo cartão',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Dados do Cartão',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Card number with brand detection
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Número do Cartão',
                          border: const OutlineInputBorder(),
                          hintText: '0000 0000 0000 0000',
                          suffixIcon: _cardNumberController.text.isNotEmpty
                              ? Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    _getCardBrandIcon(detectedBrand),
                                    size: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(19),
                          _CardNumberFormatter(),
                        ],
                        validator: _validateCardNumber,
                        onChanged: (value) {
                          setState(() {}); // Rebuild to show brand icon
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Expiry and CVC row
                      Row(
                        children: [
                          // Expiry month
                          Expanded(
                            child: TextFormField(
                              controller: _expiryMonthController,
                              decoration: const InputDecoration(
                                labelText: 'Mês',
                                border: OutlineInputBorder(),
                                hintText: 'MM',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              validator: _validateExpiryMonth,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Expiry year
                          Expanded(
                            child: TextFormField(
                              controller: _expiryYearController,
                              decoration: const InputDecoration(
                                labelText: 'Ano',
                                border: OutlineInputBorder(),
                                hintText: 'AAAA',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: _validateExpiryYear,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // CVC
                          Expanded(
                            child: TextFormField(
                              controller: _cvcController,
                              decoration: const InputDecoration(
                                labelText: 'CVC',
                                border: OutlineInputBorder(),
                                hintText: '123',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: _validateCVC,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Cardholder information
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Dados do Titular',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Holder name
                      TextFormField(
                        controller: _holderNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          hintText: 'Seu nome como aparece no cartão',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => _validateRequired(value, 'Nome'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Holder document
                      TextFormField(
                        controller: _holderDocumentController,
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          border: OutlineInputBorder(),
                          hintText: '000.000.000-00',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: (value) => _validateRequired(value, 'CPF'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Holder birth date
                      TextFormField(
                        controller: _holderBirthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Data de Nascimento',
                          border: OutlineInputBorder(),
                          hintText: 'DD/MM/AAAA',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          _BirthDateMaskFormatter(), // Máscara DD/MM/AAAA
                        ],
                        validator: (value) => _validateRequired(value, 'Data de Nascimento'),
                      ),
                      const SizedBox(height: 20),
                      

                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              

              
              // Confirm purchase button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (isLoading || _isProcessing) ? null : _confirmPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'COMPRAR AGORA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              

              
              const SizedBox(height: 16),
              
              // Meus Cartões button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/cards'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.credit_card),
                  label: const Text('MEUS CARTÕES'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Error display
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


}

/// Custom formatter for card number with spaces
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final text = newValue.text.replaceAll(' ', '');
    final formatted = _formatCardNumber(text);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
  
  String _formatCardNumber(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

/// Custom formatter for birth date with DD/MM/AAAA mask
class _BirthDateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Remove all non-digit characters
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit to 8 digits
    if (text.length > 8) {
      return oldValue;
    }
    
    // Apply mask DD/MM/AAAA
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
