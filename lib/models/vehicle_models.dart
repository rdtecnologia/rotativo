class Vehicle {
  final String licensePlate;
  final String? model;
  final String? brand;
  final String? color;
  final int? year;
  final bool isActive;

  const Vehicle({
    required this.licensePlate,
    this.model,
    this.brand,
    this.color,
    this.year,
    this.isActive = true,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      licensePlate: json['licensePlate'] ?? '',
      model: json['model'],
      brand: json['brand'],
      color: json['color'],
      year: json['year'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licensePlate': licensePlate,
      'model': model,
      'brand': brand,
      'color': color,
      'year': year,
      'isActive': isActive,
    };
  }

  Vehicle copyWith({
    String? licensePlate,
    String? model,
    String? brand,
    String? color,
    int? year,
    bool? isActive,
  }) {
    return Vehicle(
      licensePlate: licensePlate ?? this.licensePlate,
      model: model ?? this.model,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      year: year ?? this.year,
      isActive: isActive ?? this.isActive,
    );
  }
}

class Balance {
  final double credits;
  final double realValue;
  final List<BalanceItem> items;

  const Balance({
    required this.credits,
    required this.realValue,
    required this.items,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      credits: (json['credits'] ?? 0).toDouble(),
      realValue: (json['realValue'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => BalanceItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class BalanceItem {
  final int quantity;
  final Product product;

  const BalanceItem({
    required this.quantity,
    required this.product,
  });

  factory BalanceItem.fromJson(Map<String, dynamic> json) {
    return BalanceItem(
      quantity: json['quantity'] ?? 0,
      product: Product.fromJson(json['product'] ?? {}),
    );
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final int duration; // em minutos

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
    );
  }
}