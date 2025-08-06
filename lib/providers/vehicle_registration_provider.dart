import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_registration_models.dart';
import '../services/vehicle_registration_service.dart';

class VehicleRegistrationNotifier extends StateNotifier<VehicleRegistrationState> {
  VehicleRegistrationNotifier() : super(VehicleRegistrationState());

  /// Load vehicle types
  Future<void> loadVehicleTypes() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      
      final vehicleTypes = await VehicleRegistrationService.getVehicleTypes();
      
      state = state.copyWith(
        vehicleTypes: vehicleTypes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get vehicle model by license plate
  Future<void> getModelByPlate(String licensePlate) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      
      final response = await VehicleRegistrationService.getModelByPlate(licensePlate);
      
      state = state.copyWith(
        modelResponse: response,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Register a new vehicle
  Future<bool> registerVehicle(VehicleRegistration vehicle) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      
      final success = await VehicleRegistrationService.registerVehicle(vehicle);
      
      state = state.copyWith(isLoading: false);
      
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear model response
  void clearModelResponse() {
    state = state.copyWith(clearModelResponse: true);
  }
}

// Main provider
final vehicleRegistrationProvider = 
    StateNotifierProvider<VehicleRegistrationNotifier, VehicleRegistrationState>(
  (ref) => VehicleRegistrationNotifier(),
);

// Helper providers for specific parts of the state
final vehicleTypesProvider = Provider<List<VehicleType>>((ref) {
  return ref.watch(vehicleRegistrationProvider).vehicleTypes;
});

final vehicleRegistrationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(vehicleRegistrationProvider).isLoading;
});

final vehicleRegistrationErrorProvider = Provider<String?>((ref) {
  return ref.watch(vehicleRegistrationProvider).error;
});

final vehicleModelResponseProvider = Provider<GetModelVehicleResponse?>((ref) {
  return ref.watch(vehicleRegistrationProvider).modelResponse;
});