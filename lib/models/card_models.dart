class CreditCard {
  final String id;
  final String number;
  final String brand;
  final String gateway;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CreditCard({
    required this.id,
    required this.number,
    required this.brand,
    required this.gateway,
    this.active = false,
    this.createdAt,
    this.updatedAt,
  });

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      gateway: json['gateway']?.toString() ?? '',
      active: json['active'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'brand': brand,
      'gateway': gateway,
      'active': active,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Retorna os últimos 4 dígitos do cartão
  String get lastFourDigits {
    if (number.length >= 4) {
      return number.substring(number.length - 4);
    }
    return number;
  }

  /// Retorna o número mascarado do cartão
  String get maskedNumber {
    if (number.length >= 8) {
      return '**** **** **** $lastFourDigits';
    }
    return number;
  }

  /// Retorna o ícone da bandeira do cartão
  String get brandIcon {
    switch (brand.toUpperCase()) {
      case 'VISA':
        return 'cc-visa';
      case 'MASTER':
      case 'MASTERCARD':
        return 'cc-mastercard';
      case 'AMEX':
      case 'AMERICAN EXPRESS':
        return 'cc-amex';
      case 'DINNERS':
      case 'DINERS CLUB':
        return 'cc-diners-club';
      case 'STRIPE':
        return 'cc-stripe';
      case 'APPLE PAY':
        return 'cc-apple-pay';
      default:
        return 'credit-card';
    }
  }
}

class CreateCardRequest {
  final String number;
  final String expirationMonth;
  final String expirationYear;
  final String cvc;
  final String holderName;
  final String holderDocument;
  final String holderEmail;
  final String holderPhone;
  final String gateway;
  final String birthDate;

  CreateCardRequest({
    required this.number,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvc,
    required this.holderName,
    required this.holderDocument,
    required this.holderEmail,
    required this.holderPhone,
    required this.gateway,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'expirationMonth': expirationMonth,
      'expirationYear': expirationYear,
      'cvc': cvc,
      'holder': {
        'name': holderName,
        'document': holderDocument,
        'email': holderEmail,
        'phone': holderPhone,
        'birthDate': birthDate,
      },
      'gateway': gateway,
    };
  }
}

class CardSelectionState {
  final CreditCard? selectedCard;
  final List<CreditCard> cards;
  final bool isLoading;
  final String? error;

  CardSelectionState({
    this.selectedCard,
    this.cards = const [],
    this.isLoading = false,
    this.error,
  });

  CardSelectionState copyWith({
    CreditCard? selectedCard,
    List<CreditCard>? cards,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelectedCard = false,
  }) {
    return CardSelectionState(
      selectedCard:
          clearSelectedCard ? null : (selectedCard ?? this.selectedCard),
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
