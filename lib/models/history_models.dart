class OrderHistory {
  final String id;
  final String licensePlate;
  final double value;
  final DateTime createdAt;
  final String status;
  final String? description;

  OrderHistory({
    required this.id,
    required this.licensePlate,
    required this.value,
    required this.createdAt,
    required this.status,
    this.description,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'].toString(),
      licensePlate: json['licensePlate'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}

class ActivationHistory {
  final String id;
  final String licensePlate;
  final int quantity;
  final DateTime activatedAt;
  final DateTime? expiresAt;
  final String status;
  final String? location;

  ActivationHistory({
    required this.id,
    required this.licensePlate,
    required this.quantity,
    required this.activatedAt,
    this.expiresAt,
    required this.status,
    this.location,
  });

  factory ActivationHistory.fromJson(Map<String, dynamic> json) {
    return ActivationHistory(
      id: json['id'].toString(),
      licensePlate: json['licensePlate'] ?? '',
      quantity: json['quantity'] ?? 0,
      activatedAt: DateTime.parse(json['activatedAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      status: json['status'] ?? '',
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'quantity': quantity,
      'activatedAt': activatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
      'location': location,
    };
  }
}

class HistoryFilter {
  final String? licensePlate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  HistoryFilter({
    this.licensePlate,
    this.startDate,
    this.endDate,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    
    if (licensePlate != null && licensePlate!.isNotEmpty) {
      map['licensePlate'] = licensePlate;
    }
    if (startDate != null) {
      map['startDate'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      map['endDate'] = endDate!.toIso8601String();
    }
    if (status != null && status!.isNotEmpty) {
      map['status'] = status;
    }
    
    return map;
  }
}

class HistoryState {
  final List<OrderHistory> orders;
  final List<ActivationHistory> activations;
  final bool isLoadingOrders;
  final bool isLoadingActivations;
  final String? error;
  final int currentPage;
  final bool hasMoreData;

  HistoryState({
    this.orders = const [],
    this.activations = const [],
    this.isLoadingOrders = false,
    this.isLoadingActivations = false,
    this.error,
    this.currentPage = 0,
    this.hasMoreData = true,
  });

  HistoryState copyWith({
    List<OrderHistory>? orders,
    List<ActivationHistory>? activations,
    bool? isLoadingOrders,
    bool? isLoadingActivations,
    String? error,
    int? currentPage,
    bool? hasMoreData,
    bool clearError = false,
  }) {
    return HistoryState(
      orders: orders ?? this.orders,
      activations: activations ?? this.activations,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      isLoadingActivations: isLoadingActivations ?? this.isLoadingActivations,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}