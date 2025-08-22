import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado da tela de pagamento com cartão de crédito
class CreditCardPaymentState {
  final bool isProcessing;
  final String? error;
  final String cardNumber;
  final String expiry;
  final String cvc;
  final String holderName;
  final String holderDocument;
  final String holderBirthDate;

  const CreditCardPaymentState({
    this.isProcessing = false,
    this.error,
    this.cardNumber = '',
    this.expiry = '',
    this.cvc = '',
    this.holderName = '',
    this.holderDocument = '',
    this.holderBirthDate = '',
  });

  CreditCardPaymentState copyWith({
    bool? isProcessing,
    String? error,
    String? cardNumber,
    String? expiry,
    String? cvc,
    String? holderName,
    String? holderDocument,
    String? holderBirthDate,
  }) {
    return CreditCardPaymentState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      cvc: cvc ?? this.cvc,
      holderName: holderName ?? this.holderName,
      holderDocument: holderDocument ?? this.holderDocument,
      holderBirthDate: holderBirthDate ?? this.holderBirthDate,
    );
  }
}

// Notifier para gerenciar o estado
class CreditCardPaymentNotifier extends StateNotifier<CreditCardPaymentState> {
  CreditCardPaymentNotifier() : super(const CreditCardPaymentState());

  // Iniciar processamento
  void startProcessing() {
    state = state.copyWith(
      isProcessing: true,
      error: null,
    );
  }

  // Finalizar processamento
  void finishProcessing() {
    state = state.copyWith(isProcessing: false);
  }

  // Definir erro
  void setError(String error) {
    state = state.copyWith(
      error: error,
      isProcessing: false,
    );
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Atualizar número do cartão
  void updateCardNumber(String cardNumber) {
    state = state.copyWith(cardNumber: cardNumber);
  }

  // Atualizar data de validade
  void updateExpiry(String expiry) {
    state = state.copyWith(expiry: expiry);
  }

  // Atualizar CVC
  void updateCvc(String cvc) {
    state = state.copyWith(cvc: cvc);
  }

  // Atualizar nome do titular
  void updateHolderName(String holderName) {
    state = state.copyWith(holderName: holderName);
  }

  // Atualizar documento do titular
  void updateHolderDocument(String holderDocument) {
    state = state.copyWith(holderDocument: holderDocument);
  }

  // Atualizar data de nascimento do titular
  void updateHolderBirthDate(String holderBirthDate) {
    state = state.copyWith(holderBirthDate: holderBirthDate);
  }

  // Resetar estado
  void reset() {
    state = const CreditCardPaymentState();
  }
}

// Provider principal
final creditCardPaymentProvider =
    StateNotifierProvider<CreditCardPaymentNotifier, CreditCardPaymentState>(
  (ref) => CreditCardPaymentNotifier(),
);

// Providers específicos para cada campo (otimizam rebuilds)
final cardNumberProvider = Provider<String>((ref) {
  return ref.watch(creditCardPaymentProvider).cardNumber;
});

final expiryProvider = Provider<String>((ref) {
  return ref.watch(creditCardPaymentProvider).expiry;
});

final cvcProvider = Provider<String>((ref) {
  return ref.watch(creditCardPaymentProvider).cvc;
});

final holderNameProvider = Provider<String>((ref) {
  return ref.watch(creditCardPaymentProvider).holderName;
});

final holderDocumentProvider = Provider<String>((ref) {
  return ref.watch(creditCardPaymentProvider).holderDocument;
});

final holderBirthDateProvider = Provider<String>((ref) {
  return ref.watch(creditCardPaymentProvider).holderBirthDate;
});

final isProcessingProvider = Provider<bool>((ref) {
  return ref.watch(creditCardPaymentProvider).isProcessing;
});

final errorProvider = Provider<String?>((ref) {
  return ref.watch(creditCardPaymentProvider).error;
});

// Provider para detectar a marca do cartão
final cardBrandProvider = Provider<String>((ref) {
  final cardNumber = ref.watch(cardNumberProvider);
  return _detectCardBrand(cardNumber);
});

// Função para detectar a marca do cartão
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
  } else if (cleanNumber.startsWith('35') ||
      cleanNumber.startsWith('36') ||
      cleanNumber.startsWith('38')) {
    return 'DINNERS';
  } else if (cleanNumber.startsWith('60') || cleanNumber.startsWith('65')) {
    return 'HIPERCARD';
  }

  return 'GENERIC';
}
