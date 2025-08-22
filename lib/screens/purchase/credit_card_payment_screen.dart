import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../models/purchase_models.dart';
import '../../models/card_models.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/card_provider.dart';
import '../../providers/credit_card_payment_provider.dart';
import '../../widgets/credit_card_form_fields.dart';
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
  ConsumerState<CreditCardPaymentScreen> createState() =>
      _CreditCardPaymentScreenState();
}

class _CreditCardPaymentScreenState
    extends ConsumerState<CreditCardPaymentScreen> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
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
    _expiryController.dispose();
    _cvcController.dispose();
    _holderNameController.dispose();
    _holderDocumentController.dispose();
    _holderBirthDateController.dispose();
    super.dispose();
  }

  Future<void> _confirmPurchase() async {
    if (!_formKey.currentState!.validate()) return;

    final isProcessing = ref.read(isProcessingProvider);
    if (isProcessing) return;

    ref.read(creditCardPaymentProvider.notifier).startProcessing();

    try {
      if (kDebugMode) {
        AppLogger.purchase('Processing credit card payment');
      }

      // Create payment data for credit card - matching React structure exactly
      final paymentData = PaymentData(
        method: PaymentMethodType.creditCard,
        creditCard: CreditCardOrder(
          number: _cardNumberController.text.replaceAll(' ', ''),
          expirationMonth: _extractExpiryMonth(_expiryController.text),
          expirationYear: _extractExpiryYear(_expiryController.text),
          cvc: _cvcController.text,
          store: true, // Sempre salvar o cartão após compra bem-sucedida
          holder: HolderCard(
            name: _holderNameController.text,
            cpf: _holderDocumentController.text
                .replaceAll(RegExp(r'[^\d]'), ''), // CPF limpo sem máscara
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
        totalValue: widget.product.price, // Incluindo o valor total do produto
      );

      final response =
          await ref.read(purchaseProvider.notifier).createOrder(order);

      ref.read(creditCardPaymentProvider.notifier).finishProcessing();

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
          AppLogger.error(
              'DioException status code: ${e.response?.statusCode}');
        }
      }

      ref
          .read(creditCardPaymentProvider.notifier)
          .setError(ErrorHandler.getErrorMessage(e));

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
    final isProcessing = ref.read(isProcessingProvider);
    if (isProcessing) return;

    ref.read(creditCardPaymentProvider.notifier).startProcessing();

    try {
      if (kDebugMode) {
        AppLogger.purchase(
            'Processing payment with saved card: ${savedCard.id}');
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
        totalValue: widget.product.price, // Incluindo o valor total do produto
      );

      final response =
          await ref.read(purchaseProvider.notifier).createOrder(order);

      ref.read(creditCardPaymentProvider.notifier).finishProcessing();

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
          AppLogger.error(
              'DioException status code: ${e.response?.statusCode}');
        }
      }

      ref
          .read(creditCardPaymentProvider.notifier)
          .setError(ErrorHandler.getErrorMessage(e));

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
      return 'Data de validade é obrigatória';
    }

    // Remove a barra e pega apenas os números
    final cleanValue = value.replaceAll('/', '');
    if (cleanValue.length < 4) {
      return 'Data de validade incompleta';
    }

    final month = int.tryParse(cleanValue.substring(0, 2));
    if (month == null || month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }

    return null;
  }

  String? _validateExpiryYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de validade é obrigatória';
    }

    // Remove a barra e pega apenas os números
    final cleanValue = value.replaceAll('/', '');
    if (cleanValue.length < 4) {
      return 'Data de validade incompleta';
    }

    final year = int.tryParse(cleanValue.substring(2, 4));
    if (year == null) {
      return 'Ano inválido';
    }

    // Validação do ano (máximo 15 anos no futuro)
    final currentYear = DateTime.now().year;
    final currentYearShort =
        currentYear % 100; // Pega apenas os últimos 2 dígitos
    final maxYearShort = (currentYear + 15) % 100; // Máximo 15 anos no futuro

    // Validação simples: ano deve ser >= ano atual e <= ano atual + 15
    if (year < currentYearShort) {
      return 'Ano deve ser ${currentYearShort.toString().padLeft(2, '0')} ou posterior';
    }

    if (year > maxYearShort) {
      return 'Ano não pode ser maior que ${maxYearShort.toString().padLeft(2, '0')}';
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

  /// Extracts the month from a string like "MM/AA"
  String _extractExpiryMonth(String value) {
    final cleanValue = value.replaceAll('/', '');
    if (cleanValue.length >= 2) {
      return cleanValue.substring(0, 2);
    }
    return '';
  }

  /// Extracts the year from a string like "MM/AA" and converts to 4-digit format
  String _extractExpiryYear(String value) {
    final cleanValue = value.replaceAll('/', '');
    if (cleanValue.length >= 4) {
      final year = cleanValue.substring(2, 4);
      // Convert 2-digit year to 4-digit year
      final currentYear = DateTime.now().year;
      final currentYearShort = currentYear % 100;
      final inputYear = int.tryParse(year) ?? 0;

      // For years 00-99, assume 20xx for recent years and 19xx for older years
      // This is a common convention for credit card expiry dates
      if (inputYear >= 0 && inputYear <= 99) {
        if (inputYear >= currentYearShort) {
          return '20${year.padLeft(2, '0')}';
        } else {
          return '19${year.padLeft(2, '0')}';
        }
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final selectedCard = ref.watch(selectedCardProvider);
    final isLoading = ref.watch(cardLoadingProvider);
    final totalValue = widget.product.price;

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                              SavedCardProcessingButton(
                                onPressed: () =>
                                    _confirmPurchaseWithSavedCard(selectedCard),
                                child: const Text(
                                  'Confirmar a compra',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
                      CardNumberField(
                        controller: _cardNumberController,
                        validator: _validateCardNumber,
                      ),
                      const SizedBox(height: 16),

                      // Expiry and CVC row
                      Row(
                        children: [
                          // Expiry date (unified field)
                          Expanded(
                            flex: 2,
                            child: ExpiryField(
                              controller: _expiryController,
                              validator: (value) =>
                                  _validateExpiryMonth(value) ??
                                  _validateExpiryYear(value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // CVC
                          Expanded(
                            flex: 1,
                            child: CvcField(
                              controller: _cvcController,
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
                      HolderNameField(
                        controller: _holderNameController,
                        validator: (value) => _validateRequired(value, 'Nome'),
                      ),
                      const SizedBox(height: 16),

                      // Holder document
                      HolderDocumentField(
                        controller: _holderDocumentController,
                        validator: (value) => _validateRequired(value, 'CPF'),
                      ),
                      const SizedBox(height: 16),

                      // Holder birth date
                      HolderBirthDateField(
                        controller: _holderBirthDateController,
                        validator: (value) =>
                            _validateRequired(value, 'Data de Nascimento'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Confirm purchase button
              ProcessingButton(
                onPressed: (isLoading) ? null : _confirmPurchase,
                child: const Text(
                  'COMPRAR AGORA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
              const ErrorDisplay(),
            ],
          ),
        ),
      ),
    );
  }
}
