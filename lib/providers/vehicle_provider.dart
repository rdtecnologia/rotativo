import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_models.dart';
import '../services/vehicle_service.dart';

// Vehicle state
class VehicleState {
  final List<Vehicle> vehicles;
  final bool isLoading;
  final bool hasInitialized; // Novo campo para controlar se já foi inicializado
  final String? error;

  const VehicleState({
    this.vehicles = const [],
    this.isLoading = false,
    this.hasInitialized = false,
    this.error,
  });

  VehicleState copyWith({
    List<Vehicle>? vehicles,
    bool? isLoading,
    bool? hasInitialized,
    String? error,
    bool clearError = false,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      hasInitialized: hasInitialized ?? this.hasInitialized,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Vehicle notifier
class VehicleNotifier extends StateNotifier<VehicleState> {
  VehicleNotifier() : super(const VehicleState());

  Future<void> loadVehicles() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final vehicles = await VehicleService.getVehicles();
      state = state.copyWith(
        vehicles: vehicles,
        isLoading: false,
        hasInitialized:
            true, // Marca como inicializado após o primeiro carregamento
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasInitialized: true, // Marca como inicializado mesmo em caso de erro
        error: e.toString(),
      );
    }
  }

  Future<void> createVehicle(VehicleCreateRequest request) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final newVehicle = await VehicleService.createVehicle(request);
      final updatedVehicles = [...state.vehicles, newVehicle];
      state = state.copyWith(
        vehicles: updatedVehicles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateVehicle(
      String licensePlate, VehicleUpdateRequest request) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final updatedVehicle =
          await VehicleService.updateVehicle(licensePlate, request);
      final updatedVehicles = state.vehicles.map((vehicle) {
        return vehicle.licensePlate == licensePlate ? updatedVehicle : vehicle;
      }).toList();
      state = state.copyWith(
        vehicles: updatedVehicles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteVehicle(String licensePlate) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await VehicleService.deleteVehicle(licensePlate);
      final updatedVehicles = state.vehicles
          .where(
            (vehicle) => vehicle.licensePlate != licensePlate,
          )
          .toList();
      state = state.copyWith(
        vehicles: updatedVehicles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearVehicles() {
    state = const VehicleState();
  }
}

// Providers
final vehicleProvider =
    StateNotifierProvider<VehicleNotifier, VehicleState>((ref) {
  return VehicleNotifier();
});

final vehicleListProvider = Provider<List<Vehicle>>((ref) {
  return ref.watch(vehicleProvider).vehicles;
});

final vehicleLoadingProvider = Provider<bool>((ref) {
  return ref.watch(vehicleProvider).isLoading;
});

final vehicleErrorProvider = Provider<String?>((ref) {
  return ref.watch(vehicleProvider).error;
});
