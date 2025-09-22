import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/card_models.dart';
import '../../providers/card_provider.dart';
import '../../providers/card_ui_provider.dart';
import '../../providers/history_provider.dart';
import '../../utils/logger.dart';
import '../../utils/formatters.dart';

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  @override
  void initState() {
    super.initState();
    // Load cards and history when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardProvider.notifier).loadCards();
      ref.read(historyProvider.notifier).loadOrders(refresh: true);
    });
  }

  void _changeCardId(String id) {
    ref.read(cardUIProvider.notifier).showModal(id);
  }

  // TODO: Implement card usage history tracking when API supports it
  // This would require:
  // 1. Getting order details for each order
  // 2. Checking payment method information
  // 3. Matching card IDs with payment data

  @override
  Widget build(BuildContext context) {
    inspect('build');

    final cardsState = ref.watch(cardProvider);
    final cards = cardsState.cards;
    final isLoading = cardsState.isLoading;
    final error = cardsState.error;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text(
          'Meus Cartões',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header with instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Text(
                      'Clique em um cartão para seleciona-lo e usa-lo nas suas próximas compras',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Cards list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(cardProvider.notifier).loadCards();
                    await ref
                        .read(historyProvider.notifier)
                        .loadOrders(refresh: true);
                  },
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Erro ao carregar cartões',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    error,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => ref
                                        .read(cardProvider.notifier)
                                        .loadCards(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    child: const Text('Tentar Novamente'),
                                  ),
                                ],
                              ),
                            )
                          : cards.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.credit_card_outlined,
                                        size: 48,
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhum cartão adicionado',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Ao fazer compra com cartão, ele aparecerá aqui\n para que você possa selecioná-lo \n\nSeus cartões serão guardados de forma segura\n e não serão compartilhados com ninguém.',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.7),
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28),
                                  itemCount: cards.length,
                                  itemBuilder: (context, index) =>
                                      CardItemWidget(
                                    card: cards[index],
                                    onTap: _changeCardId,
                                  ),
                                ),
                ),
              ),
            ],
          ),

          // Modal overlay - agora usando Consumer para rebuild apenas quando necessário
          const CardModalOverlay(),
        ],
      ),
    );
  }
}

/// Widget separado para cada item de cartão que só é reconstruído quando necessário
class CardItemWidget extends ConsumerWidget {
  final CreditCard card;
  final Function(String) onTap;

  const CardItemWidget({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCard = ref.watch(selectedCardProvider);
    final isSelected = selectedCard?.id == card.id;

    if (kDebugMode) {
      AppLogger.api(
          'Building card item for ${card.id}, isSelected: $isSelected, selectedCardId: ${selectedCard?.id}');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onTap(card.id),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [Colors.blue.shade700, Colors.blue.shade900]
                    : [Colors.grey.shade600, Colors.grey.shade800],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Brand and action button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card brand icon
                      Icon(
                        _getCardBrandIcon(card.brand),
                        size: 32,
                        color: Colors.white,
                      ),

                      // Action button (three dots)
                      IconButton(
                        onPressed: () => onTap(card.id),
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Card number
                  Text(
                    card.maskedNumber,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom row: Brand name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand name
                      Text(
                        card.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),

                      // Selection indicator
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'SELECIONADO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Additional info
                  if (card.createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Cadastrado em ${AppFormatters.formatDate(card.createdAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCardBrandIcon(String brand) {
    switch (brand.toUpperCase()) {
      case 'VISA':
        return Icons.credit_card;
      case 'MASTER':
      case 'MASTERCARD':
        return Icons.credit_card;
      case 'AMEX':
      case 'AMERICAN EXPRESS':
        return Icons.credit_card;
      case 'DINNERS':
      case 'DINERS CLUB':
        return Icons.credit_card;
      case 'ELO':
        return Icons.credit_card;
      case 'HIPERCARD':
        return Icons.credit_card;
      case 'STRIPE':
        return Icons.credit_card;
      case 'APPLE PAY':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}

/// Widget separado para o modal overlay que só é reconstruído quando necessário
class CardModalOverlay extends ConsumerWidget {
  const CardModalOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showModal = ref.watch(showModalProvider);
    final selectedCardId = ref.watch(selectedCardIdForModalProvider);

    if (!showModal) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => ref.read(cardUIProvider.notifier).hideModal(),
        child: Container(
          color: Colors.black54,
          child: _buildModalOptions(context, ref, selectedCardId),
        ),
      ),
    );
  }

  Widget _buildModalOptions(
      BuildContext context, WidgetRef ref, String? selectedCardId) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: const Offset(0, 0),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  child: Text(
                    'Ações do Cartão',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Action buttons
                if (selectedCardId != null) ...[
                  _buildModalButton(
                    'Selecionar Cartão',
                    Icons.check_circle_outline,
                    () => _selectCard(context, ref, selectedCardId),
                    iconColor: Colors.green,
                  ),
                  _buildModalButton(
                    'Limpar Seleção',
                    Icons.clear,
                    () => _clearCardSelection(context, ref),
                    iconColor: Colors.blue,
                  ),
                  _buildModalButton(
                    'Excluir Cartão',
                    Icons.delete_outline,
                    () => _deleteCard(context, ref, selectedCardId),
                    isDestructive: true,
                  ),
                ],

                _buildModalButton(
                  'Fechar',
                  Icons.close,
                  () => ref.read(cardUIProvider.notifier).hideModal(),
                  iconColor: Colors.grey,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalButton(String text, IconData icon, VoidCallback onPressed,
      {bool isDestructive = false, Color? iconColor}) {
    final buttonColor =
        isDestructive ? Colors.red : iconColor ?? Colors.black87;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: buttonColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: buttonColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectCard(BuildContext context, WidgetRef ref, String id) {
    final card = ref.read(cardProvider).cards.firstWhere((c) => c.id == id);
    ref.read(cardProvider.notifier).selectCard(card);
    ref.read(cardUIProvider.notifier).hideModal();

    if (kDebugMode) {
      AppLogger.api('Card selected: $id');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cartão selecionado!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearCardSelection(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      AppLogger.api('Starting clear card selection...');
      AppLogger.api(
          'Current selected card: ${ref.read(cardProvider).selectedCard?.id}');
      AppLogger.api(
          'Current selected card masked: ${ref.read(cardProvider).selectedCard?.maskedNumber}');
    }

    ref.read(cardProvider.notifier).clearSelectedCard();

    if (kDebugMode) {
      AppLogger.api('After clearSelectedCard call');
      AppLogger.api(
          'New selected card: ${ref.read(cardProvider).selectedCard?.id}');
      AppLogger.api(
          'New selected card masked: ${ref.read(cardProvider).selectedCard?.maskedNumber}');

      // Verificar o estado diretamente do provider
      final currentState = ref.read(cardProvider);
      AppLogger.api(
          'Provider state - selectedCard: ${currentState.selectedCard?.id}');
      AppLogger.api(
          'Provider state - cards count: ${currentState.cards.length}');
    }

    ref.read(cardUIProvider.notifier).hideModal();

    if (kDebugMode) {
      AppLogger.api('Card selection cleared');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seleção de cartão removida!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteCard(BuildContext context, WidgetRef ref, String id) {
    final card = ref.read(cardProvider).cards.firstWhere((c) => c.id == id);
    ref.read(cardUIProvider.notifier).hideModal();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Tem certeza que deseja excluir o cartão final ${card.lastFourDigits}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final success = await ref
                    .read(cardProvider.notifier)
                    .deleteCard(card.id, card.gateway);

                // Use a post-frame callback to avoid BuildContext issues
                if (context.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cartão excluído com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao excluir cartão'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  });
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
