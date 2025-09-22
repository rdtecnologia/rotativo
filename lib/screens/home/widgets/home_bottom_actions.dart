import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/balance_provider.dart';
import '../../../widgets/balance_card.dart';

class HomeBottomActions extends ConsumerWidget {
  final VoidCallback onPurchaseTap;
  final VoidCallback onBalanceTap;
  final VoidCallback onHistoryTap;

  const HomeBottomActions({
    super.key,
    required this.onPurchaseTap,
    required this.onBalanceTap,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          // Purchase card
          Expanded(
            child: ActionCard(
              icon: Icons.shopping_cart,
              label: 'COMPRAR',
              onTap: onPurchaseTap,
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 1),
            ),
          ),

          const SizedBox(width: 8),

          // Balance card
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final balance = ref.watch(currentBalanceProvider);
                final isLoading = ref.watch(balanceLoadingProvider);

                return BalanceCard(
                  balance: balance,
                  isLoading: isLoading,
                  onTap: onBalanceTap,
                  displayType: 'credits',
                );
              },
            ),
          ),

          const SizedBox(width: 8),

          // History card
          Expanded(
            child: ActionCard(
              icon: Icons.history,
              label: 'HISTÓRICO',
              onTap: onHistoryTap,
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 1),
            ),
          ),
        ],
      ),
    );
  }
}
