import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_models.dart';
import '../services/balance_service.dart';

// Balance state
class BalanceState {
  final Balance? balance;
  final BalanceDetail? balanceDetail;
  final bool isLoading;
  final String? error;

  const BalanceState({
    this.balance,
    this.balanceDetail,
    this.isLoading = false,
    this.error,
  });

  BalanceState copyWith({
    Balance? balance,
    BalanceDetail? balanceDetail,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BalanceState(
      balance: balance ?? this.balance,
      balanceDetail: balanceDetail ?? this.balanceDetail,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Balance notifier
class BalanceNotifier extends StateNotifier<BalanceState> {
  BalanceNotifier() : super(const BalanceState());

  Future<void> loadBalance() async {
    try {
      if (kDebugMode) {
        print('🔍 BalanceProvider - Starting loadBalance');
      }
      
      state = state.copyWith(isLoading: true, clearError: true);
      final balance = await BalanceService.getBalance();
      
      if (kDebugMode) {
        print('🔍 BalanceProvider - Received balance: ${balance.credits} credits, ${balance.realValue} real');
      }
      
      state = state.copyWith(
        balance: balance,
        isLoading: false,
      );
      
      if (kDebugMode) {
        print('🔍 BalanceProvider - State updated with balance: ${state.balance?.credits} credits');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ BalanceProvider - Error loading balance: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBalanceDetails() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final balanceDetail = await BalanceService.getBalanceDetails();
      state = state.copyWith(
        balanceDetail: balanceDetail,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearBalance() {
    state = const BalanceState();
  }
}

// Providers
final balanceProvider = StateNotifierProvider<BalanceNotifier, BalanceState>((ref) {
  return BalanceNotifier();
});

final currentBalanceProvider = Provider<Balance?>((ref) {
  return ref.watch(balanceProvider).balance;
});

final balanceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(balanceProvider).isLoading;
});

final balanceErrorProvider = Provider<String?>((ref) {
  return ref.watch(balanceProvider).error;
});

final balanceDetailProvider = Provider<BalanceDetail?>((ref) {
  return ref.watch(balanceProvider).balanceDetail;
});