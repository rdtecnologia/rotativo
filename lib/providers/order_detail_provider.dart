import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_models.dart';
import '../services/history_service.dart';

// Copy message state
class CopyMessageState {
  final String message;
  final bool isVisible;

  CopyMessageState({
    this.message = '',
    this.isVisible = false,
  });

  CopyMessageState copyWith({
    String? message,
    bool? isVisible,
  }) {
    return CopyMessageState(
      message: message ?? this.message,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

// Copy message notifier
class CopyMessageNotifier extends StateNotifier<CopyMessageState> {
  CopyMessageNotifier() : super(CopyMessageState());

  void showMessage(String message) {
    state = state.copyWith(message: message, isVisible: true);

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (state.isVisible) {
        hideMessage();
      }
    });
  }

  void hideMessage() {
    state = state.copyWith(isVisible: false);
  }
}

// Copy message provider
final copyMessageProvider =
    StateNotifierProvider<CopyMessageNotifier, CopyMessageState>((ref) {
  return CopyMessageNotifier();
});

// Order detail state
class OrderDetailState {
  final OrderDetail? orderDetail;
  final bool isLoading;
  final String? error;

  OrderDetailState({
    this.orderDetail,
    this.isLoading = false,
    this.error,
  });

  OrderDetailState copyWith({
    OrderDetail? orderDetail,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrderDetailState(
      orderDetail: orderDetail ?? this.orderDetail,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Order detail provider
class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  OrderDetailNotifier() : super(OrderDetailState());

  /// Load order details by ID
  Future<void> loadOrderDetail(String orderId) async {
    if (kDebugMode) {
      print('📋 OrderDetailProvider.loadOrderDetail - orderId: $orderId');
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final orderDetail = await HistoryService.getOrderDetail(orderId);

      if (kDebugMode) {
        print(
            '📋 OrderDetailProvider.loadOrderDetail - Loaded order: ${orderDetail.id}');
        print(
            '📋 OrderDetailProvider.loadOrderDetail - Status: ${orderDetail.status}');
        print(
            '📋 OrderDetailProvider.loadOrderDetail - Value: ${orderDetail.value}');
        print(
            '📋 OrderDetailProvider.loadOrderDetail - Payments: ${orderDetail.payments.length}');
      }

      state = state.copyWith(
        orderDetail: orderDetail,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('📋 OrderDetailProvider.loadOrderDetail - Error: $e');
      }

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear current order detail
  void clearOrderDetail() {
    state = OrderDetailState();
  }

  /// Refresh order detail (re-fetch current order)
  Future<void> refreshOrderDetail() async {
    if (state.orderDetail != null) {
      await loadOrderDetail(state.orderDetail!.id);
    }
  }
}

// Provider instance
final orderDetailProvider =
    StateNotifierProvider<OrderDetailNotifier, OrderDetailState>((ref) {
  return OrderDetailNotifier();
});

// Convenience provider for easy access to order detail
final currentOrderDetailProvider = Provider<OrderDetail?>((ref) {
  return ref.watch(orderDetailProvider).orderDetail;
});

// Convenience provider for loading state
final orderDetailLoadingProvider = Provider<bool>((ref) {
  return ref.watch(orderDetailProvider).isLoading;
});

// Convenience provider for error state
final orderDetailErrorProvider = Provider<String?>((ref) {
  return ref.watch(orderDetailProvider).error;
});
