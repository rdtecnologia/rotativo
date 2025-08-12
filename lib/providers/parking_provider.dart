import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parking_models.dart';
import '../services/parking_service.dart';

// Parking provider
class ParkingNotifier extends StateNotifier<ParkingState> {
  ParkingNotifier() : super(ParkingState());

  /// Get possible parking tickets for a license plate
  Future<PossibleParkingResponse> getPossibleParking({
    required String licensePlate,
    required String quantity,
  }) async {
    if (kDebugMode) {
      print('🚗 ParkingProvider.getPossibleParking - License: $licensePlate, Quantity: $quantity');
    }

    state = state.copyWith(isLoadingTickets: true, clearError: true);

    try {
      final response = await ParkingService.getPossibleParking(
        licensePlate: licensePlate,
        quantity: quantity,
      );
      
      if (kDebugMode) {
        print('🚗 ParkingProvider.getPossibleParking - Got ${response.tickets.length} tickets');
      }

      state = state.copyWith(
        ticketsAvailable: response,
        isLoadingTickets: false,
      );

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('🚗 ParkingProvider.getPossibleParking - Error: $e');
      }
      
      state = state.copyWith(
        isLoadingTickets: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Activate parking for a vehicle
  Future<ParkingResponse> activateParking({
    required String licensePlate,
    required List<int> ticketIds,
    required ParkingData parkingData,
  }) async {
    if (kDebugMode) {
      print('🚗 ParkingProvider.activateParking - License: $licensePlate');
    }

    state = state.copyWith(isLoadingParking: true, clearError: true);

    try {
      final response = await ParkingService.activateParking(
        licensePlate: licensePlate,
        ticketIds: ticketIds,
        parkingData: parkingData,
      );
      
      if (kDebugMode) {
        print('🚗 ParkingProvider.activateParking - Activated: ${response.id}');
      }

      state = state.copyWith(
        currentParking: response,
        isLoadingParking: false,
      );

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('🚗 ParkingProvider.activateParking - Error: $e');
      }
      
      state = state.copyWith(
        isLoadingParking: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Get activation detail by ID
  Future<ActivationDetail> getActivationDetail(String activationId) async {
    if (kDebugMode) {
      print('🚗 ParkingProvider.getActivationDetail - ID: $activationId');
    }

    state = state.copyWith(isLoadingActivationDetail: true, clearError: true);

    try {
      final response = await ParkingService.getActivationDetail(activationId);
      
      if (kDebugMode) {
        print('🚗 ParkingProvider.getActivationDetail - Loaded: ${response.id}');
      }

      state = state.copyWith(
        activationDetail: response,
        isLoadingActivationDetail: false,
      );

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('🚗 ParkingProvider.getActivationDetail - Error: $e');
      }
      
      state = state.copyWith(
        isLoadingActivationDetail: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Select parking time and credits
  void selectParkingTime(int time, int credits) {
    state = state.copyWith(
      selectedParkingTime: time,
      selectedCredits: credits,
      clearError: true,
    );

    if (kDebugMode) {
      print('🚗 ParkingProvider.selectParkingTime - Time: ${time}min, Credits: $credits');
    }
  }

  /// Reset parking state
  void reset() {
    state = ParkingState();
    
    if (kDebugMode) {
      print('🚗 ParkingProvider.reset - State reset');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider instance
final parkingProvider = StateNotifierProvider<ParkingNotifier, ParkingState>((ref) {
  return ParkingNotifier();
});

// Convenience providers
final ticketsAvailableProvider = Provider<PossibleParkingResponse?>((ref) {
  return ref.watch(parkingProvider).ticketsAvailable;
});

final currentParkingProvider = Provider<ParkingResponse?>((ref) {
  return ref.watch(parkingProvider).currentParking;
});

final activationDetailProvider = Provider<ActivationDetail?>((ref) {
  return ref.watch(parkingProvider).activationDetail;
});

final selectedParkingTimeProvider = Provider<int?>((ref) {
  return ref.watch(parkingProvider).selectedParkingTime;
});

final selectedCreditsProvider = Provider<int?>((ref) {
  return ref.watch(parkingProvider).selectedCredits;
});

final parkingLoadingProvider = Provider<bool>((ref) {
  final parkingState = ref.watch(parkingProvider);
  return parkingState.isLoadingTickets || 
         parkingState.isLoadingParking || 
         parkingState.isLoadingActivationDetail;
});

final parkingErrorProvider = Provider<String?>((ref) {
  return ref.watch(parkingProvider).error;
});
