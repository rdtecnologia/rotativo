import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardUIState {
  final bool showModal;
  final String? selectedCardIdForModal;

  const CardUIState({
    this.showModal = false,
    this.selectedCardIdForModal,
  });

  CardUIState copyWith({
    bool? showModal,
    String? selectedCardIdForModal,
  }) {
    return CardUIState(
      showModal: showModal ?? this.showModal,
      selectedCardIdForModal:
          selectedCardIdForModal ?? this.selectedCardIdForModal,
    );
  }
}

class CardUINotifier extends StateNotifier<CardUIState> {
  CardUINotifier() : super(const CardUIState());

  void toggleModal() {
    state = state.copyWith(showModal: !state.showModal);
  }

  void showModal(String cardId) {
    state = state.copyWith(
      showModal: true,
      selectedCardIdForModal: cardId,
    );
  }

  void hideModal() {
    state = state.copyWith(
      showModal: false,
      selectedCardIdForModal: null,
    );
  }

  void clearSelectedCardForModal() {
    state = state.copyWith(selectedCardIdForModal: null);
  }
}

final cardUIProvider =
    StateNotifierProvider<CardUINotifier, CardUIState>((ref) {
  return CardUINotifier();
});

// Convenience providers
final showModalProvider = Provider<bool>((ref) {
  return ref.watch(cardUIProvider).showModal;
});

final selectedCardIdForModalProvider = Provider<String?>((ref) {
  return ref.watch(cardUIProvider).selectedCardIdForModal;
});
