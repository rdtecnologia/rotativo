import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/parking_models.dart';
import '../services/parking_service.dart';
import '../utils/logger.dart';

// Parking provider
class ParkingNotifier extends StateNotifier<ParkingState> {
  ParkingNotifier() : super(ParkingState());

  /// Get possible parking tickets for a license plate
  Future<PossibleParkingResponse> getPossibleParking({
    required String licensePlate,
    required String quantity,
  }) async {
    if (kDebugMode) {
      AppLogger.parking('License: $licensePlate, Quantity: $quantity');
    }

    state = state.copyWith(isLoadingTickets: true, clearError: true);

    try {
      final response = await ParkingService.getPossibleParking(
        licensePlate: licensePlate,
        quantity: quantity,
      );

      if (kDebugMode) {
        AppLogger.parking('Got ${response.tickets.length} tickets');
      }

      state = state.copyWith(
        ticketsAvailable: response,
        isLoadingTickets: false,
      );

      return response;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
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
  }) async {
    if (kDebugMode) {
      AppLogger.parking('License: $licensePlate');
    }

    state = state.copyWith(isLoadingParking: true, clearError: true);

    try {
      // Get the selected parking time from state
      final parkingTime = state.selectedParkingTime;
      if (parkingTime == null || parkingTime <= 0) {
        throw Exception('Tempo de estacionamento não selecionado');
      }

      if (kDebugMode) {
        AppLogger.parking('Selected parking time: $parkingTime minutos');
      }

      final response = await ParkingService.activateParking(
        licensePlate: licensePlate,
        ticketIds: ticketIds,
        parkingTime: parkingTime, // Passar o tempo selecionado
      );

      if (kDebugMode) {
        AppLogger.parking('Activated: ${response.id}');
      }

      state = state.copyWith(
        currentParking: response,
        isLoadingParking: false,
      );

      return response;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
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
      AppLogger.parking('ID: $activationId');
    }

    state = state.copyWith(isLoadingActivationDetail: true, clearError: true);

    try {
      final response = await ParkingService.getActivationDetail(activationId);

      if (kDebugMode) {
        AppLogger.parking('ID: $activationId');
      }

      state = state.copyWith(
        activationDetail: response,
        isLoadingActivationDetail: false,
      );

      return response;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
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
    // Log previous state before updating
    if (kDebugMode) {
      print(
          '🎯 ParkingProvider.selectParkingTime - Previous state: Time: ${state.selectedParkingTime}min, Credits: ${state.selectedCredits}');
    }

    state = state.copyWith(
      selectedParkingTime: time,
      selectedCredits: credits,
      clearError: true,
    );

    if (kDebugMode) {
      AppLogger.parking(
          '🎯 selectParkingTime called - Time: ${time}min, Credits: $credits');
      print(
          '🎯 ParkingProvider.selectParkingTime - New state: Time: ${time}min, Credits: $credits');
    }
  }

  /// Reset parking state
  void reset() {
    state = ParkingState();

    if (kDebugMode) {
      AppLogger.parking('State reset');
    }
  }

  /// Clear selected parking time and credits (useful when switching vehicles)
  void clearSelection() {
    state = state.copyWith(
      selectedParkingTime: null,
      selectedCredits: null,
      clearError: true,
    );

    if (kDebugMode) {
      AppLogger.parking('Selection cleared - Time and credits reset');
      print('🎯 ParkingProvider.clearSelection - Selection cleared');
    }
  }

  /// Force clear all state (useful for complete reset)
  void forceClear() {
    state = ParkingState();

    if (kDebugMode) {
      AppLogger.parking('Force clear - All state reset');
      print('🎯 ParkingProvider.forceClear - All state reset');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider instance
final parkingProvider =
    StateNotifierProvider<ParkingNotifier, ParkingState>((ref) {
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
