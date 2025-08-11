// Purchase models following React Native patterns

enum PaymentMethodType {
  creditCard('CREDIT_CARD'),
  boleto('BOLETO'),
  pix('PIX');

  const PaymentMethodType(this.value);
  final String value;
}

class PurchaseProduct {
  final int productId;
  final int quantity;
  final int vehicleType;

  PurchaseProduct({
    required this.productId,
    required this.quantity,
    required this.vehicleType,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'vehicleType': vehicleType,
    };
  }
}

class HolderCard {
  final String name;
  final String document;
  final String email;
  final String mobile;

  HolderCard({
    required this.name,
    required this.document,
    required this.email,
    required this.mobile,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'document': document,
      'email': email,
      'mobile': mobile,
    };
  }
}

class CreditCardOrder {
  final String number;
  final String expirationMonth;
  final String expirationYear;
  final String cvc;
  final bool store;
  final HolderCard holder;

  CreditCardOrder({
    required this.number,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvc,
    required this.store,
    required this.holder,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'expirationMonth': expirationMonth,
      'expirationYear': expirationYear,
      'cvc': cvc,
      'store': store,
      'holder': holder.toJson(),
    };
  }
}

class StoredCreditCard {
  final String id;

  StoredCreditCard({required this.id});

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class PaymentData {
  final PaymentMethodType method;
  final dynamic creditCard; // Can be CreditCardOrder or StoredCreditCard

  PaymentData({
    required this.method,
    this.creditCard,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'method': method.value,
    };

    if (creditCard != null) {
      data['creditCard'] = creditCard.toJson();
    }

    return data;
  }
}

class Payment {
  final String gateway;
  final PaymentData data;

  Payment({
    required this.gateway,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'gateway': gateway,
      'data': data.toJson(),
    };
  }
}

class PurchaseOrder {
  final List<PurchaseProduct> products;
  final Payment payment;
  final String origin;

  PurchaseOrder({
    required this.products,
    required this.payment,
    this.origin = 'APP',
  });

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'payment': payment.toJson(),
      'origin': origin,
    };
  }
}

// City configuration models
class ProductOption {
  final int credits;
  final double price;

  ProductOption({
    required this.credits,
    required this.price,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      credits: json['credits'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class ParkingRule {
  final int time; // minutes
  final double price;
  final int credits;

  ParkingRule({
    required this.time,
    required this.price,
    required this.credits,
  });

  factory ParkingRule.fromJson(Map<String, dynamic> json) {
    return ParkingRule(
      time: json['time'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      credits: json['credits'] ?? 0,
    );
  }

  String get formattedTime {
    if (time < 60) {
      return '${time}min';
    } else {
      final hours = time ~/ 60;
      final minutes = time % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}min';
      }
    }
  }
}

class PaymentOptions {
  final bool creditCard;
  final bool billet;
  final bool pix;

  PaymentOptions({
    required this.creditCard,
    required this.billet,
    required this.pix,
  });

  factory PaymentOptions.fromJson(Map<String, dynamic> json) {
    return PaymentOptions(
      creditCard: json['creditCard'] ?? false,
      billet: json['billet'] ?? false,
      pix: json['pix'] ?? false,
    );
  }

  List<PaymentMethodType> get availableMethods {
    final methods = <PaymentMethodType>[];
    if (creditCard) methods.add(PaymentMethodType.creditCard);
    if (billet) methods.add(PaymentMethodType.boleto);
    if (pix) methods.add(PaymentMethodType.pix);
    return methods;
  }
}

class PurchaseConfig {
  final int vehicleTypeDefault;
  final String showBy;
  final bool chargeback;
  final Map<String, int> minCreditsByVehicle;
  final Map<String, List<ProductOption>> products;
  final PaymentOptions payment;

  PurchaseConfig({
    required this.vehicleTypeDefault,
    required this.showBy,
    required this.chargeback,
    required this.minCreditsByVehicle,
    required this.products,
    required this.payment,
  });

  factory PurchaseConfig.fromJson(Map<String, dynamic> json) {
    final productsMap = <String, List<ProductOption>>{};
    final productsJson = json['products'] as Map<String, dynamic>? ?? {};
    
    for (final entry in productsJson.entries) {
      final productList = (entry.value as List<dynamic>? ?? [])
          .map((p) => ProductOption.fromJson(p as Map<String, dynamic>))
          .toList();
      productsMap[entry.key] = productList;
    }

    final minCreditsMap = <String, int>{};
    final minCreditsJson = json['minCreditsByVehicle'] as Map<String, dynamic>? ?? {};
    for (final entry in minCreditsJson.entries) {
      minCreditsMap[entry.key] = entry.value as int? ?? 0;
    }

    return PurchaseConfig(
      vehicleTypeDefault: json['vehicleTypeDefault'] ?? 1,
      showBy: json['showBy'] ?? 'real',
      chargeback: json['chargeback'] ?? false,
      minCreditsByVehicle: minCreditsMap,
      products: productsMap,
      payment: PaymentOptions.fromJson(json['payment'] ?? {}),
    );
  }

  List<ProductOption> getProductsForVehicleType(int vehicleType) {
    return products[vehicleType.toString()] ?? [];
  }

  int getMinCreditsForVehicleType(int vehicleType) {
    return minCreditsByVehicle[vehicleType.toString()] ?? 0;
  }
}

// Purchase state
class PurchaseState {
  final int? selectedVehicleType;
  final ProductOption? selectedProduct;
  final PaymentMethodType? selectedPaymentMethod;
  final PurchaseOrder? order;
  final bool isLoading;
  final String? error;

  PurchaseState({
    this.selectedVehicleType,
    this.selectedProduct,
    this.selectedPaymentMethod,
    this.order,
    this.isLoading = false,
    this.error,
  });

  PurchaseState copyWith({
    int? selectedVehicleType,
    ProductOption? selectedProduct,
    PaymentMethodType? selectedPaymentMethod,
    PurchaseOrder? order,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PurchaseState(
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Order response models
class OrderResponse {
  final String id;
  final String status;
  final double value;
  final DateTime createdAt;
  final String? paymentUrl; // For PIX QR Code or Billet URL

  OrderResponse({
    required this.id,
    required this.status,
    required this.value,
    required this.createdAt,
    this.paymentUrl,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      value: (json['value'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      paymentUrl: json['paymentUrl']?.toString(),
    );
  }
}
