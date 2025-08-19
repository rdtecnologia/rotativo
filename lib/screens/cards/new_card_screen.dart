import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/card_models.dart';
import '../../providers/card_provider.dart';
import '../../services/card_service.dart';
import '../../utils/error_handler.dart';

class NewCardScreen extends ConsumerStatefulWidget {
  const NewCardScreen({super.key});

  @override
  ConsumerState<NewCardScreen> createState() => _NewCardScreenState();
}

class _NewCardScreenState extends ConsumerState<NewCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cvcController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _holderDocumentController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default gateway is handled in CardService.getDefaultGateway()
  }

  @override
  void dispose() {
    _holderNameController.dispose();
    _cardNumberController.dispose();
    _cvcController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _holderDocumentController.dispose();
    _birthDateController.dispose();
    super.dispose();
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert 2-digit year to 4-digit year
      final year2Digit = int.tryParse(_expiryYearController.text) ?? 0;
      final fullYear = year2Digit < 50 ? 2000 + year2Digit : 1900 + year2Digit;
      
      // Convert Brazilian date to ISO format
      final birthDateParts = _birthDateController.text.split('/');
      final birthDay = int.parse(birthDateParts[0]);
      final birthMonth = int.parse(birthDateParts[1]);
      final birthYear = int.parse(birthDateParts[2]);
      final birthDateISO = '${birthYear.toString().padLeft(4, '0')}-${birthMonth.toString().padLeft(2, '0')}-${birthDay.toString().padLeft(2, '0')}';
      
      final request = CreateCardRequest(
        number: _cardNumberController.text.replaceAll(' ', ''),
        expirationMonth: _expiryMonthController.text,
        expirationYear: fullYear.toString(),
        cvc: _cvcController.text,
        holderName: _holderNameController.text,
        holderDocument: _holderDocumentController.text,
        holderEmail: 'user@example.com', // Default email
        holderPhone: '00000000000', // Default phone
        gateway: CardService.getDefaultGateway(),
        birthDate: birthDateISO,
      );

      final card = await ref.read(cardProvider.notifier).createCard(request);
      
      if (card != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cartão criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao criar cartão'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    
    if (value.length != 2) {
      return 'Ano deve ter 2 dígitos';
    }
    
    final year = int.tryParse(value);
    if (year == null || year < 0 || year > 99) {
      return 'Ano inválido';
    }
    
    // Convert 2-digit year to 4-digit year
    final currentYear = DateTime.now().year;
    final fullYear = year < 50 ? 2000 + year : 1900 + year;
    
    if (fullYear < currentYear) {
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

  String? _validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de nascimento é obrigatória';
    }

    // Parse Brazilian date format (dd/mm/aaaa)
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'Data de nascimento inválida';
    }

    if (day < 1 || day > 31 || month < 1 || month > 12) {
      return 'Data de nascimento inválida';
    }

    try {
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

      if (date.isAfter(eighteenYearsAgo)) {
        return 'Você deve ter pelo menos 18 anos';
      }

      if (date.isAfter(now)) {
        return 'Data de nascimento não pode ser no futuro';
      }

      // Check if date is reasonable (not more than 100 years ago)
      final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);
      if (date.isBefore(hundredYearsAgo)) {
        return 'Data de nascimento muito antiga';
      }

      return null;
    } catch (e) {
      return 'Data de nascimento inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Novo Cartão',
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
              // Card information section
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
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Informações do Cartão',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                          labelText: 'Titular do cartão',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => _validateRequired(value, 'Nome'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Card number with brand detection
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Número do cartão',
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
                                    _getCardBrandIcon(_detectCardBrand(_cardNumberController.text)),
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
                        validator: (value) => _validateCardNumber(value),
                        onChanged: (value) {
                          setState(() {
                            // Auto-detect brand and update
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // CVV
                      TextFormField(
                        controller: _cvcController,
                        decoration: const InputDecoration(
                          labelText: 'CVV do cartão',
                          border: OutlineInputBorder(),
                          hintText: '123',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (value) => _validateCVC(value),
                      ),
                      const SizedBox(height: 16),
                      
                      // Expiry date
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryMonthController,
                              decoration: const InputDecoration(
                                labelText: 'Validade do cartão (mm/aa)',
                                border: OutlineInputBorder(),
                                hintText: 'MM',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              validator: (value) => _validateExpiryMonth(value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _expiryYearController,
                              decoration: const InputDecoration(
                                labelText: '',
                                border: OutlineInputBorder(),
                                hintText: 'AA',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              validator: (value) => _validateExpiryYear(value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Holder document
                      TextFormField(
                        controller: _holderDocumentController,
                        decoration: const InputDecoration(
                          labelText: 'CPF do Titular',
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
                      
                      // Birth date
                      TextFormField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Data de nascimento titular',
                          border: OutlineInputBorder(),
                          hintText: 'dd/mm/aaaa',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                          _BirthDateFormatter(),
                        ],
                        validator: (value) => _validateBirthDate(value),
                        onChanged: (value) {
                          // Auto-format as user types
                          if (value.length == 8) {
                            final formatted = '${value.substring(0, 2)}/${value.substring(2, 4)}/${value.substring(4, 8)}';
                            _birthDateController.text = formatted;
                            _birthDateController.selection = TextSelection.fromPosition(
                              TextPosition(offset: formatted.length),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Comprar Agora',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
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

/// Custom formatter for birth date with mask
class _BirthDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll('/', '');
    final formatted = _formatBirthDate(text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatBirthDate(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

