import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/history_models.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState());

  /// Load order history
  Future<void> loadOrders({
    bool refresh = false,
    HistoryFilter? filters,
  }) async {
    try {
      if (kDebugMode) {
        print('📱 HistoryProvider.loadOrders - refresh: $refresh');
      }

      if (refresh) {
        state = state.copyWith(
          orders: [],
          currentPage: 0,
          hasMoreData: true,
          clearError: true,
        );
      }

      if (!state.hasMoreData && !refresh) {
        if (kDebugMode) {
          print('📱 HistoryProvider.loadOrders - No more data available');
        }
        return;
      }

      state = state.copyWith(isLoadingOrders: true, clearError: true);

      final offset = refresh ? 0 : state.orders.length;
      const limit = 100; // Match React Native behavior

      if (kDebugMode) {
        print(
            '📱 HistoryProvider.loadOrders - Calling service with offset: $offset, limit: $limit');

        // Debug user authentication
        final user = await AuthService.getStoredUser();
        final token = await AuthService.getStoredToken();
        if (user != null) {
          print(
              '📱 HistoryProvider.loadOrders - Current user: ${user.name} (CPF: ${user.cpf})');
        }
        if (token != null) {
          print(
              '📱 HistoryProvider.loadOrders - Token available: ${token.substring(0, 20)}...');
        }
      }

      final newOrders = await HistoryService.getOrders(
        offset: offset,
        limit: limit,
        // Don't pass filters like React Native (it passes undefined)
      );

      if (kDebugMode) {
        print(
            '📱 HistoryProvider.loadOrders - Service returned ${newOrders.length} orders');
      }

      List<OrderHistory> allOrders;
      if (refresh) {
        allOrders = newOrders;
      } else {
        allOrders = [...state.orders, ...newOrders];
      }

      state = state.copyWith(
        orders: allOrders,
        isLoadingOrders: false,
        hasMoreData: newOrders.length == limit,
        currentPage: refresh ? 1 : state.currentPage + 1,
      );

      if (kDebugMode) {
        print(
            '📱 HistoryProvider.loadOrders - State updated with ${allOrders.length} total orders');
      }
    } catch (e) {
      if (kDebugMode) {
        print('📱 HistoryProvider.loadOrders - Error: $e');
      }
      state = state.copyWith(
        isLoadingOrders: false,
        error: e.toString(),
      );
    }
  }

  /// Load activation history
  Future<void> loadActivations({
    bool refresh = false,
    HistoryFilter? filters,
  }) async {
    try {
      if (kDebugMode) {
        print('📱 HistoryProvider.loadActivations - refresh: $refresh');
      }

      if (refresh) {
        state = state.copyWith(
          activations: [],
          currentPage: 0,
          hasMoreData: true,
          clearError: true,
        );
      }

      if (!state.hasMoreData && !refresh) {
        if (kDebugMode) {
          print('📱 HistoryProvider.loadActivations - No more data available');
        }
        return;
      }

      state = state.copyWith(isLoadingActivations: true, clearError: true);

      final offset = refresh ? 0 : state.activations.length;
      const limit = 100; // Match React Native behavior

      if (kDebugMode) {
        print(
            '📱 HistoryProvider.loadActivations - Calling service with offset: $offset, limit: $limit');
      }

      final newActivations = await HistoryService.getActivations(
        offset: offset,
        limit: limit,
        // Don't pass filters like React Native (it passes undefined)
      );

      if (kDebugMode) {
        print(
            '📱 HistoryProvider.loadActivations - Service returned ${newActivations.length} activations');
      }

      List<ActivationHistory> allActivations;
      if (refresh) {
        allActivations = newActivations;
      } else {
        allActivations = [...state.activations, ...newActivations];
      }

      // Process activations to mark superseded ones
      final processedActivations = _markSupersededActivations(allActivations);

      if (kDebugMode) {
        print(
            '📱 HistoryProvider.loadActivations - Processed ${processedActivations.length} activations with correct status');
      }

      state = state.copyWith(
        activations: processedActivations,
        isLoadingActivations: false,
        hasMoreData: newActivations.length == limit,
        currentPage: refresh ? 1 : state.currentPage + 1,
      );

      if (kDebugMode) {
        print(
            '📱 HistoryProvider.loadActivations - State updated with ${processedActivations.length} total activations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('📱 HistoryProvider.loadActivations - Error: $e');
      }
      state = state.copyWith(
        isLoadingActivations: false,
        error: e.toString(),
      );
    }
  }

  /// Mark activations as superseded when there are multiple valid activations for the same vehicle
  /// Only the most recent valid activation should remain as "active", others become "superseded"
  List<ActivationHistory> _markSupersededActivations(
      List<ActivationHistory> activations) {
    // Group activations by license plate
    final Map<String, List<ActivationHistory>> activationsByPlate = {};

    for (final activation in activations) {
      final plate = activation.licensePlate.toUpperCase();
      activationsByPlate.putIfAbsent(plate, () => []);
      activationsByPlate[plate]!.add(activation);
    }

    final List<ActivationHistory> processedActivations = [];

    // Process each vehicle's activations
    for (final plateActivations in activationsByPlate.values) {
      // Sort by activation date (most recent first)
      plateActivations.sort((a, b) => b.activatedAt.compareTo(a.activatedAt));

      // Find all currently valid (not expired) activations for this vehicle
      final validActivations =
          plateActivations.where((activation) => activation.isActive).toList();

      // Process each activation
      for (int i = 0; i < plateActivations.length; i++) {
        final activation = plateActivations[i];

        if (activation.isActive) {
          // If this is a valid activation but not the most recent valid one, mark as superseded
          if (validActivations.isNotEmpty &&
              validActivations.first.id != activation.id) {
            // Create a copy with superseded status
            processedActivations.add(_createSupersededActivation(activation));
          } else {
            // This is the most recent valid activation, keep as active
            processedActivations.add(activation);
          }
        } else {
          // Expired activations remain as they are
          processedActivations.add(activation);
        }
      }
    }

    // Sort all activations by activation date (most recent first)
    processedActivations.sort((a, b) => b.activatedAt.compareTo(a.activatedAt));

    return processedActivations;
  }

  /// Create a copy of activation with superseded status
  ActivationHistory _createSupersededActivation(ActivationHistory original) {
    return ActivationHistory(
      id: original.id,
      licensePlate: original.licensePlate,
      parkingTime: original.parkingTime,
      activatedAt: original.activatedAt,
      expiresAt: original.expiresAt,
      status: 'superseded', // Mark as superseded
      location: original.location,
      vehicleType: original.vehicleType,
    );
  }

  /// Delete an order
  Future<bool> deleteOrder(String orderId, String value) async {
    try {
      state = state.copyWith(clearError: true);

      final success = await HistoryService.deleteOrder(orderId, value);

      if (success) {
        // Remove the order from the local state
        final updatedOrders =
            state.orders.where((order) => order.id != orderId).toList();

        state = state.copyWith(orders: updatedOrders);
      }

      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Get order details
  Future<OrderHistory?> getOrderDetails(String orderId) async {
    try {
      state = state.copyWith(clearError: true);

      return await HistoryService.getOrderDetails(orderId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Get activation details
  Future<ActivationHistory?> getActivationDetails(String activationId) async {
    try {
      state = state.copyWith(clearError: true);

      return await HistoryService.getActivationDetails(activationId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Main provider
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(),
);

// Helper providers for specific parts of the state
final ordersProvider = Provider<List<OrderHistory>>((ref) {
  return ref.watch(historyProvider).orders;
});

final activationsProvider = Provider<List<ActivationHistory>>((ref) {
  return ref.watch(historyProvider).activations;
});

final historyLoadingOrdersProvider = Provider<bool>((ref) {
  return ref.watch(historyProvider).isLoadingOrders;
});

final historyLoadingActivationsProvider = Provider<bool>((ref) {
  return ref.watch(historyProvider).isLoadingActivations;
});

final historyErrorProvider = Provider<String?>((ref) {
  return ref.watch(historyProvider).error;
});

final historyHasMoreDataProvider = Provider<bool>((ref) {
  return ref.watch(historyProvider).hasMoreData;
});
