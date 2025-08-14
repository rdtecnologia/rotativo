// Parking and activation models following React Native patterns
import '../utils/date_utils.dart' as AppDateUtils;

class Product {
  final String? id;
  final String description;
  final double price;
  final int? vehicleType;
  final String? vehicleTypeDescription;

  Product({
    this.id,
    required this.description,
    required this.price,
    this.vehicleType,
    this.vehicleTypeDescription,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      vehicleType: json['vehicleType'] as int?,
      vehicleTypeDescription: json['vehicleTypeDescription']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'price': price,
      'vehicleType': vehicleType,
      'vehicleTypeDescription': vehicleTypeDescription,
    };
  }
}

class Ticket {
  final List<int> tickets;
  final String id;
  final String description;
  final double price;
  final bool canBePurchased;

  Ticket({
    required this.tickets,
    required this.id,
    required this.description,
    required this.price,
    required this.canBePurchased,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      tickets: (json['tickets'] as List<dynamic>? ?? [])
          .map((t) => int.tryParse(t.toString()) ?? 0)
          .toList(),
      id: json['id']?.toString() ?? '0',
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      canBePurchased: json['canBePurchased'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tickets': tickets,
      'id': id,
      'description': description,
      'price': price,
      'canBePurchased': canBePurchased,
    };
  }
}

class PossibleParkingResponse {
  final String? message;
  final List<Ticket> tickets;

  PossibleParkingResponse({
    this.message,
    required this.tickets,
  });

  factory PossibleParkingResponse.fromJson(Map<String, dynamic> json) {
    return PossibleParkingResponse(
      message: json['message']?.toString(),
      tickets: (json['tickets'] as List<dynamic>? ?? [])
          .map((t) => Ticket.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'tickets': tickets.map((t) => t.toJson()).toList(),
    };
  }
}

class ParkingData {
  final String latitude;
  final String longitude;
  final String device;
  final int parkingTime;

  ParkingData({
    required this.latitude,
    required this.longitude,
    required this.device,
    required this.parkingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'device': device,
      'parkingTime': parkingTime,
    };
  }
}

class ParkingRequest {
  final String licensePlate;
  final List<int> tickets;
  final ParkingData data;

  ParkingRequest({
    required this.licensePlate,
    required this.tickets,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'licensePlate': licensePlate,
      'tickets': tickets,
      'data': data.toJson(),
    };
  }
}

class ParkingResponse {
  final String id;
  final int parkingTime;
  final DateTime? scheduledAt;

  ParkingResponse({
    required this.id,
    required this.parkingTime,
    this.scheduledAt,
  });

  factory ParkingResponse.fromJson(Map<String, dynamic> json) {
    return ParkingResponse(
      id: json['id']?.toString() ?? '',
      parkingTime: json['parkingTime'] ?? 0,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parkingTime': parkingTime,
      'scheduledAt': scheduledAt?.toIso8601String(),
    };
  }
}

class Activation {
  final String id;
  final String licensePlate;
  final int parkingTime;
  final String origin;
  final Product product;
  final DateTime activatedAt;

  Activation({
    required this.id,
    required this.licensePlate,
    required this.parkingTime,
    required this.origin,
    required this.product,
    required this.activatedAt,
  });

  factory Activation.fromJson(Map<String, dynamic> json) {
    return Activation(
      id: json['id']?.toString() ?? '',
      licensePlate: json['licensePlate']?.toString() ?? '',
      parkingTime: json['parkingTime'] ?? 0,
      origin: json['origin']?.toString() ?? '',
      product: Product.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
      activatedAt: AppDateUtils.DateUtils.parseUtcDate(json['activatedAt']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'parkingTime': parkingTime,
      'origin': origin,
      'product': product.toJson(),
      'activatedAt': activatedAt.toIso8601String(),
    };
  }
}

class ActivationDetail {
  final String id;
  final String origin;
  final Product product;
  final String licensePlate;
  final int parkingTime;
  final String device;
  final String? latitude;
  final String? longitude;
  final DateTime? scheduledAt;
  final String? area;
  final DateTime transactionDate;

  ActivationDetail({
    required this.id,
    required this.origin,
    required this.product,
    required this.licensePlate,
    required this.parkingTime,
    required this.device,
    this.latitude,
    this.longitude,
    this.scheduledAt,
    this.area,
    required this.transactionDate,
  });

  factory ActivationDetail.fromJson(Map<String, dynamic> json) {
    return ActivationDetail(
      id: json['id']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      product: Product.fromJson(json['product'] as Map<String, dynamic>? ?? {}),
      licensePlate: json['licensePlate']?.toString() ?? '',
      parkingTime: json['parkingTime'] ?? 0,
      device: json['device']?.toString() ?? '',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      scheduledAt: json['scheduledAt'] != null
          ? AppDateUtils.DateUtils.parseUtcDate(json['scheduledAt'])
          : null,
      area: json['area']?.toString(),
      transactionDate: AppDateUtils.DateUtils.parseUtcDate(json['transactionDate']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'product': product.toJson(),
      'licensePlate': licensePlate,
      'parkingTime': parkingTime,
      'device': device,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'area': area,
      'transactionDate': transactionDate.toIso8601String(),
    };
  }

  bool get hasLocation => latitude != null && longitude != null;
  
  double? get latitudeDouble => latitude != null ? double.tryParse(latitude!) : null;
  double? get longitudeDouble => longitude != null ? double.tryParse(longitude!) : null;
}

// Parking state
class ParkingState {
  final PossibleParkingResponse? ticketsAvailable;
  final ParkingResponse? currentParking;
  final ActivationDetail? activationDetail;
  final int? selectedParkingTime;
  final int? selectedCredits;
  final bool isLoadingTickets;
  final bool isLoadingParking;
  final bool isLoadingActivationDetail;
  final String? error;

  ParkingState({
    this.ticketsAvailable,
    this.currentParking,
    this.activationDetail,
    this.selectedParkingTime,
    this.selectedCredits,
    this.isLoadingTickets = false,
    this.isLoadingParking = false,
    this.isLoadingActivationDetail = false,
    this.error,
  });

  ParkingState copyWith({
    PossibleParkingResponse? ticketsAvailable,
    ParkingResponse? currentParking,
    ActivationDetail? activationDetail,
    int? selectedParkingTime,
    int? selectedCredits,
    bool? isLoadingTickets,
    bool? isLoadingParking,
    bool? isLoadingActivationDetail,
    String? error,
    bool clearError = false,
  }) {
    return ParkingState(
      ticketsAvailable: ticketsAvailable ?? this.ticketsAvailable,
      currentParking: currentParking ?? this.currentParking,
      activationDetail: activationDetail ?? this.activationDetail,
      selectedParkingTime: selectedParkingTime ?? this.selectedParkingTime,
      selectedCredits: selectedCredits ?? this.selectedCredits,
      isLoadingTickets: isLoadingTickets ?? this.isLoadingTickets,
      isLoadingParking: isLoadingParking ?? this.isLoadingParking,
      isLoadingActivationDetail: isLoadingActivationDetail ?? this.isLoadingActivationDetail,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
