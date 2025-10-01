import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/balance_provider.dart';
import '../../../providers/color_scheme_provider.dart';
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
    return ref.watch(appColorsProvider).when(
          data: (appColors) => _buildActions(context, ref, appColors),
          loading: () => _buildActions(context, ref, null),
          error: (_, __) => _buildActions(context, ref, null),
        );
  }

  Widget _buildActions(
      BuildContext context, WidgetRef ref, AppColors? appColors) {
    final primaryColor = appColors?.primary ?? Theme.of(context).primaryColor;
    final secondaryColor =
        appColors?.secondary ?? Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          // Purchase card - Primary color
          Expanded(
            child: ActionCard(
              icon: Icons.shopping_cart,
              label: 'COMPRAR',
              onTap: onPurchaseTap,
              backgroundColor: primaryColor,
            ),
          ),

          const SizedBox(width: 8),

          // Balance card - Secondary color
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
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                );
              },
            ),
          ),

          const SizedBox(width: 8),

          // History card - Primary color
          Expanded(
            child: ActionCard(
              icon: Icons.history,
              label: 'HISTÓRICO',
              onTap: onHistoryTap,
              backgroundColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
