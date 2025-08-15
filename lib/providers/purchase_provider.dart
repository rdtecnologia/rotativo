import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/purchase_models.dart';
import '../services/purchase_service.dart';
import '../utils/logger.dart';

// Purchase provider
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  PurchaseNotifier() : super(PurchaseState());

  /// Load city configuration
  Future<PurchaseConfig> loadCityConfig() async {
    try {
      final config = await PurchaseService.loadCityConfig();
      
      if (kDebugMode) {
        AppLogger.purchase('Loaded config');
      }

      return config;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.purchase('Error: $e');
      }
      
      state = state.copyWith(
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Load parking rules
  Future<Map<String, List<ParkingRule>>> loadParkingRules() async {
    try {
      final rules = await PurchaseService.loadParkingRules();
      
      if (kDebugMode) {
        AppLogger.purchase('Loaded ${rules.length} rule sets');
      }

      return rules;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.purchase('Error: $e');
      }
      
      state = state.copyWith(
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Get available vehicle types
  Future<List<int>> getAvailableVehicleTypes() async {
    try {
      final types = await PurchaseService.getAvailableVehicleTypes();
      
      if (kDebugMode) {
        AppLogger.purchase('Loaded ${types.length} types');
      }

      return types;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.purchase('Error: $e');
      }
      
      state = state.copyWith(
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Select vehicle type for purchase
  void selectVehicleType(int vehicleType) {
    state = state.copyWith(
      selectedVehicleType: vehicleType,
      selectedProduct: null, // Reset product selection
      clearError: true,
    );

    if (kDebugMode) {
      AppLogger.purchase('Selected: $vehicleType');
    }
  }

  /// Select product (credits/price package)
  void selectProduct(ProductOption product) {
    state = state.copyWith(
      selectedProduct: product,
      clearError: true,
    );

    if (kDebugMode) {
      AppLogger.purchase('Selected: ${product.credits} credits for R\$ ${product.price}');
    }
  }

  /// Select payment method
  void selectPaymentMethod(PaymentMethodType method) {
    state = state.copyWith(
      selectedPaymentMethod: method,
      clearError: true,
    );

    if (kDebugMode) {
      AppLogger.purchase('Selected: ${method.value}');
    }
  }

  /// Create order
  Future<OrderResponse> createOrder(PurchaseOrder order) async {
    if (kDebugMode) {
      AppLogger.purchase('Creating order');
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await PurchaseService.createOrder(order);
      
      if (kDebugMode) {
        AppLogger.purchase('Order created: ${response.id}');
      }

      state = state.copyWith(
        order: order,
        isLoading: false,
      );

      return response;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.purchase('Error: $e');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Reset purchase state
  void reset() {
    state = PurchaseState();
    
    if (kDebugMode) {
      AppLogger.purchase('State reset');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider instance
final purchaseProvider = StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  return PurchaseNotifier();
});

// Convenience providers
final selectedVehicleTypeProvider = Provider<int?>((ref) {
  return ref.watch(purchaseProvider).selectedVehicleType;
});

final selectedProductProvider = Provider<ProductOption?>((ref) {
  return ref.watch(purchaseProvider).selectedProduct;
});

final selectedPaymentMethodProvider = Provider<PaymentMethodType?>((ref) {
  return ref.watch(purchaseProvider).selectedPaymentMethod;
});

final purchaseLoadingProvider = Provider<bool>((ref) {
  return ref.watch(purchaseProvider).isLoading;
});

final purchaseErrorProvider = Provider<String?>((ref) {
  return ref.watch(purchaseProvider).error;
});

// City config provider (cached)
final cityConfigProvider = FutureProvider<PurchaseConfig>((ref) async {
  final notifier = ref.read(purchaseProvider.notifier);
  return await notifier.loadCityConfig();
});

// Parking rules provider (cached)
final parkingRulesProvider = FutureProvider<Map<String, List<ParkingRule>>>((ref) async {
  final notifier = ref.read(purchaseProvider.notifier);
  return await notifier.loadParkingRules();
});

// Vehicle types provider (cached)
final vehicleTypesProvider = FutureProvider<List<int>>((ref) async {
  final notifier = ref.read(purchaseProvider.notifier);
  return await notifier.getAvailableVehicleTypes();
});
