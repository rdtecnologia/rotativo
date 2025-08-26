import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/purchase_models.dart';

// Estado da tela de detalhes de pagamento
class PaymentDetailState {
  final OrderResponse? orderResponse;
  final bool isProcessing;
  final String? error;

  const PaymentDetailState({
    this.orderResponse,
    this.isProcessing = false,
    this.error,
  });

  PaymentDetailState copyWith({
    OrderResponse? orderResponse,
    bool? isProcessing,
    String? error,
  }) {
    return PaymentDetailState(
      orderResponse: orderResponse ?? this.orderResponse,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }
}

// Provider para gerenciar o estado da tela de detalhes de pagamento
class PaymentDetailNotifier extends StateNotifier<PaymentDetailState> {
  PaymentDetailNotifier() : super(const PaymentDetailState());

  // Iniciar processamento do pedido
  void startProcessing() {
    state = state.copyWith(
      isProcessing: true,
      error: null,
    );
  }

  // Finalizar processamento com sucesso
  void setOrderResponse(OrderResponse orderResponse) {
    state = state.copyWith(
      orderResponse: orderResponse,
      isProcessing: false,
      error: null, // IMPORTANTE: Limpar o erro ao definir resposta de sucesso
    );
  }

  // Definir erro
  void setError(String error) {
    state = state.copyWith(
      error: error,
      isProcessing: false,
      orderResponse: null, // IMPORTANTE: Limpar resposta ao definir erro
    );
  }

  // Resetar estado
  void reset() {
    state = const PaymentDetailState();
  }
}

// Provider principal
final paymentDetailProvider =
    StateNotifierProvider<PaymentDetailNotifier, PaymentDetailState>((ref) {
  return PaymentDetailNotifier();
});

// Providers específicos para partes do estado
final orderResponseProvider = Provider<OrderResponse?>((ref) {
  return ref.watch(paymentDetailProvider).orderResponse;
});

final isProcessingProvider = Provider<bool>((ref) {
  return ref.watch(paymentDetailProvider).isProcessing;
});

final errorProvider = Provider<String?>((ref) {
  return ref.watch(paymentDetailProvider).error;
});
