class Vehicle {
  final String licensePlate;
  final String? model;
  final String? brand;
  final String? color;
  final int? year;
  final int type;
  final bool isActive;

  const Vehicle({
    required this.licensePlate,
    this.model,
    this.brand,
    this.color,
    this.year,
    required this.type,
    this.isActive = true,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      licensePlate: json['licensePlate'] ?? '',
      model: json['model'],
      brand: json['brand'],
      color: json['color'],
      year: json['year'],
      type: json['type'] ?? 1,
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
      'type': type,
      'isActive': isActive,
    };
  }

  Vehicle copyWith({
    String? licensePlate,
    String? model,
    String? brand,
    String? color,
    int? year,
    int? type,
    bool? isActive,
  }) {
    return Vehicle(
      licensePlate: licensePlate ?? this.licensePlate,
      model: model ?? this.model,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      year: year ?? this.year,
      type: type ?? this.type,
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
              .toList() ??
          [],
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
  final String id; // Changed from int to String since API returns string
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
      id: json['id']?.toString() ?? '0', // Convert to string safely
      name: json['description'] ?? '', // API returns 'description' not 'name'
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
    };
  }
}

/// Informações do modelo do veículo retornadas pela API de busca por placa
class VehicleModelInfo {
  final String? model;
  final String? color;
  final String? manufactureYear;
  final String? modelYear;

  const VehicleModelInfo({
    this.model,
    this.color,
    this.manufactureYear,
    this.modelYear,
  });

  factory VehicleModelInfo.fromJson(Map<String, dynamic> json) {
    return VehicleModelInfo(
      model: json['model'],
      color: json['color'],
      manufactureYear: json['manufactureYear'],
      modelYear: json['modelYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'color': color,
      'manufactureYear': manufactureYear,
      'modelYear': modelYear,
    };
  }

  VehicleModelInfo copyWith({
    String? model,
    String? color,
    String? manufactureYear,
    String? modelYear,
  }) {
    return VehicleModelInfo(
      model: model ?? this.model,
      color: color ?? this.color,
      manufactureYear: manufactureYear ?? this.manufactureYear,
      modelYear: modelYear ?? this.modelYear,
    );
  }
}
