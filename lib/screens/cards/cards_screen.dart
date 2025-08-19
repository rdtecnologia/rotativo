import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/card_models.dart';
import '../../providers/card_provider.dart';
import '../../providers/history_provider.dart';
import '../../utils/logger.dart';
import '../../utils/formatters.dart';
import 'new_card_screen.dart';

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  String? selectedCardId;
  bool showModal = false;

  @override
  void initState() {
    super.initState();
    // Load cards and history when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardProvider.notifier).loadCards();
      ref.read(historyProvider.notifier).loadOrders(refresh: true);
    });
  }

  void _toggleModal() {
    setState(() {
      showModal = !showModal;
    });
  }

  void _changeCardId(String id) {
    setState(() {
      selectedCardId = id;
      showModal = true;
    });
  }

  void _selectCard(String id) {
    final card = ref.read(cardProvider).cards.firstWhere((c) => c.id == id);
    ref.read(cardProvider.notifier).selectCard(card);
    _toggleModal();
    
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

  void _clearCardSelection() {
    ref.read(cardProvider.notifier).clearSelectedCard();
    
    // Clear local selectedCardId as well
    setState(() {
      selectedCardId = null;
    });
    
    _toggleModal();
    
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

  void _deleteCard(String id) {
    final card = ref.read(cardProvider).cards.firstWhere((c) => c.id == id);
    _toggleModal();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o cartão final ${card.lastFourDigits}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                final success = await ref.read(cardProvider.notifier).deleteCard(card.id, card.gateway);
                
                // Use a post-frame callback to avoid BuildContext issues
                if (mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
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

  // TODO: Implement card usage history tracking when API supports it
  // This would require:
  // 1. Getting order details for each order
  // 2. Checking payment method information
  // 3. Matching card IDs with payment data

  Widget _buildCardItem(CreditCard card) {
    final isSelected = ref.watch(cardProvider.notifier).isCardSelected(card.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _changeCardId(card.id),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
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
                        onPressed: () => _changeCardId(card.id),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildModalOptions() {
    if (!showModal) return const SizedBox.shrink();
    
    return Modal(
      onClose: _toggleModal,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Text(
                'Ações',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Action buttons
            if (selectedCardId != null) ...[
              _buildModalButton(
                'Selecionar',
                Icons.check_circle_outline,
                () => _selectCard(selectedCardId!),
              ),
              _buildModalButton(
                'Limpar Seleção',
                Icons.clear,
                () => _clearCardSelection(),
              ),
              _buildModalButton(
                'Excluir',
                Icons.delete_outline,
                () => _deleteCard(selectedCardId!),
                isDestructive: true,
              ),
            ],
            
            _buildModalButton(
              'Fechar',
              Icons.close,
              _toggleModal,
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModalButton(String text, IconData icon, VoidCallback onPressed, {bool isDestructive = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: isDestructive ? Colors.red : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.red : Colors.black87,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewCardScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Cartão',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header with instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                child: Text(
                  'Clique em um cartão para seleciona-lo e usa-lo nas suas próximas compras',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Cards list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(cardProvider.notifier).loadCards();
                    await ref.read(historyProvider.notifier).loadOrders(refresh: true);
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
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    error,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => ref.read(cardProvider.notifier).loadCards(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Theme.of(context).primaryColor,
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
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhum cartão cadastrado',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Adicione um cartão para facilitar suas compras',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const NewCardScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Theme.of(context).primaryColor,
                                        ),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Adicionar Cartão'),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 28),
                                  itemCount: cards.length,
                                  itemBuilder: (context, index) => _buildCardItem(cards[index]),
                                ),
                ),
              ),
            ],
          ),
          
          // Modal overlay
          if (showModal)
            GestureDetector(
              onTap: _toggleModal,
              child: Container(
                color: Colors.black54,
                child: _buildModalOptions(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom Modal widget for bottom sheet
class Modal extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const Modal({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: child,
    );
  }
}

