import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/credit_card_payment_provider.dart';

// Widget otimizado para o campo de número do cartão
class CardNumberField extends ConsumerWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CardNumberField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardNumber = ref.watch(cardNumberProvider);
    final cardBrand = ref.watch(cardBrandProvider);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Número do Cartão',
        border: const OutlineInputBorder(),
        hintText: '0000 0000 0000 0000',
        suffixIcon: cardNumber.isNotEmpty
            ? Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getCardBrandIcon(cardBrand),
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
      validator: validator,
      onChanged: (value) {
        ref.read(creditCardPaymentProvider.notifier).updateCardNumber(value);
      },
    );
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
}

// Widget otimizado para o campo de validade
class ExpiryField extends ConsumerWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const ExpiryField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Validade (MM/AA)',
        border: OutlineInputBorder(),
        hintText: 'MM/AA',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _ExpiryMaskFormatter(),
      ],
      validator: validator,
      onChanged: (value) {
        ref.read(creditCardPaymentProvider.notifier).updateExpiry(value);
      },
    );
  }
}

// Widget otimizado para o campo CVC
class CvcField extends ConsumerWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CvcField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
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
      validator: validator,
      onChanged: (value) {
        ref.read(creditCardPaymentProvider.notifier).updateCvc(value);
      },
    );
  }
}

// Widget otimizado para o campo de nome do titular
class HolderNameField extends ConsumerWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const HolderNameField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Nome Completo',
        hintText: 'Seu nome como aparece no cartão',
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.words,
      validator: validator,
      onChanged: (value) {
        ref.read(creditCardPaymentProvider.notifier).updateHolderName(value);
      },
    );
  }
}

// Widget otimizado para o campo de documento do titular
class HolderDocumentField extends ConsumerWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const HolderDocumentField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
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
      validator: validator,
      onChanged: (value) {
        ref
            .read(creditCardPaymentProvider.notifier)
            .updateHolderDocument(value);
      },
    );
  }
}

// Widget otimizado para o campo de data de nascimento do titular
class HolderBirthDateField extends ConsumerWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const HolderBirthDateField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Data de Nascimento',
        border: OutlineInputBorder(),
        hintText: 'DD/MM/AAAA',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        _BirthDateMaskFormatter(),
      ],
      validator: validator,
      onChanged: (value) {
        ref
            .read(creditCardPaymentProvider.notifier)
            .updateHolderBirthDate(value);
      },
    );
  }
}

// Widget otimizado para exibir erros
class ErrorDisplay extends ConsumerWidget {
  const ErrorDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(errorProvider);

    if (error == null) return const SizedBox.shrink();

    return Container(
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
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget otimizado para botões de processamento
class ProcessingButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;

  const ProcessingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = Colors.green,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = ref.watch(isProcessingProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : child,
      ),
    );
  }
}

// Widget otimizado para botão de processamento com cartão salvo
class SavedCardProcessingButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const SavedCardProcessingButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = ref.watch(isProcessingProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isProcessing
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : child,
      ),
    );
  }
}

// Formatters
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

class _ExpiryMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.length > 4) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
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

class _BirthDateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.length > 8) {
      return oldValue;
    }

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
