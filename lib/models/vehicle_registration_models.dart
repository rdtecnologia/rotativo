class VehicleType {
  final int id;
  final String name;
  final String icon;

  VehicleType({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}

class VehicleRegistration {
  final String licensePlate;
  final String model;
  final int type;

  VehicleRegistration({
    required this.licensePlate,
    required this.model,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'licensePlate': licensePlate,
      'model': model,
      'type': type,
    };
  }
}

class GetModelVehicleResponse {
  final String? model;
  final bool success;
  final String? message;

  GetModelVehicleResponse({
    this.model,
    required this.success,
    this.message,
  });

  factory GetModelVehicleResponse.fromJson(Map<String, dynamic> json) {
    return GetModelVehicleResponse(
      model: json['model'],
      success: json['success'] ?? true,
      message: json['message'],
    );
  }
}

class VehicleRegistrationState {
  final List<VehicleType> vehicleTypes;
  final bool isLoading;
  final String? error;
  final GetModelVehicleResponse? modelResponse;

  VehicleRegistrationState({
    this.vehicleTypes = const [],
    this.isLoading = false,
    this.error,
    this.modelResponse,
  });

  VehicleRegistrationState copyWith({
    List<VehicleType>? vehicleTypes,
    bool? isLoading,
    String? error,
    GetModelVehicleResponse? modelResponse,
    bool clearError = false,
    bool clearModelResponse = false,
  }) {
    return VehicleRegistrationState(
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      modelResponse: clearModelResponse ? null : (modelResponse ?? this.modelResponse),
    );
  }
}