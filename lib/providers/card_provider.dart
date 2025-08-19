import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_models.dart';
import '../services/card_service.dart';
import '../utils/logger.dart';

class CardNotifier extends StateNotifier<CardSelectionState> {
  CardNotifier() : super(CardSelectionState());

  /// Load all cards for the current user
  Future<void> loadCards() async {
    if (kDebugMode) {
      AppLogger.api('Loading cards');
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final cards = await CardService.getCards();
      
      if (kDebugMode) {
        AppLogger.api('Loaded ${cards.length} cards');
      }

      // If a selected card no longer exists, clear the selection
      CreditCard? updatedSelected = state.selectedCard;
      if (updatedSelected != null &&
          !cards.any((c) => c.id == updatedSelected!.id)) {
        if (kDebugMode) {
          AppLogger.api('Previously selected card not found. Clearing selection');
        }
        updatedSelected = null;
      }

      state = state.copyWith(
        cards: cards,
        isLoading: false,
        selectedCard: updatedSelected,
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error loading cards: $e');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Select a card for payments
  void selectCard(CreditCard card) {
    if (kDebugMode) {
      AppLogger.api('Selected card: ${card.id}');
    }

    state = state.copyWith(
      selectedCard: card,
      clearError: true,
    );
  }

  /// Clear selected card
  void clearSelectedCard() {
    if (kDebugMode) {
      AppLogger.api('Cleared selected card');
    }

    state = state.copyWith(
      selectedCard: null,
      clearError: true,
    );
  }

  /// Create a new credit card
  Future<CreditCard?> createCard(CreateCardRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final card = await CardService.createCard(request);
      
      if (card != null) {
        // Add the new card to the list
        final updatedCards = List<CreditCard>.from(state.cards)..add(card);
        state = state.copyWith(
          cards: updatedCards,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Falha ao criar cartão',
        );
      }
      
      return card;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete a credit card
  Future<bool> deleteCard(String cardId, String gateway) async {
    if (kDebugMode) {
      AppLogger.api('Deleting card: $cardId');
    }

    try {
      await CardService.deleteCard(cardId, gateway);
      
      if (kDebugMode) {
        AppLogger.api('Card deleted successfully');
      }

      // Remove card from the list
      final updatedCards = state.cards.where((card) => card.id != cardId).toList();
      
      // If deleted card was selected, clear selection
      CreditCard? updatedSelectedCard = state.selectedCard;
      if (state.selectedCard?.id == cardId) {
        updatedSelectedCard = null;
      }
      
      state = state.copyWith(
        cards: updatedCards,
        selectedCard: updatedSelectedCard,
        clearError: true,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting card: $e');
      }
      
      state = state.copyWith(
        error: e.toString(),
      );
      
      return false;
    }
  }

  /// Get card by ID
  CreditCard? getCardById(String cardId) {
    try {
      return state.cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a card is selected
  bool isCardSelected(String cardId) {
    return state.selectedCard?.id == cardId;
  }

  /// Get available card brands
  List<Map<String, String>> getCardBrands() {
    return CardService.getCardBrands();
  }

  /// Get available gateways
  List<Map<String, String>> getGateways() {
    return CardService.getGateways();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = CardSelectionState();
  }
}

// Provider instance
final cardProvider = StateNotifierProvider<CardNotifier, CardSelectionState>((ref) {
  return CardNotifier();
});

// Convenience providers
final cardsProvider = Provider<List<CreditCard>>((ref) {
  return ref.watch(cardProvider).cards;
});

final selectedCardProvider = Provider<CreditCard?>((ref) {
  return ref.watch(cardProvider).selectedCard;
});

final cardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(cardProvider).isLoading;
});

final cardErrorProvider = Provider<String?>((ref) {
  return ref.watch(cardProvider).error;
});

final hasCardsProvider = Provider<bool>((ref) {
  final cards = ref.watch(cardProvider).cards;
  return cards.isNotEmpty;
});

final canMakePaymentProvider = Provider<bool>((ref) {
  final selectedCard = ref.watch(cardProvider).selectedCard;
  return selectedCard != null;
});
