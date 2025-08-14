import 'package:flutter/material.dart';
import '../models/vehicle_models.dart';

class BalanceCard extends StatelessWidget {
  final Balance? balance;
  final bool isLoading;
  final VoidCallback onTap;
  final String displayType; // 'credits' or 'real'

  const BalanceCard({
    super.key,
    this.balance,
    this.isLoading = false,
    required this.onTap,
    this.displayType = 'credits',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12), // Reduzido de 16 para 12
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Reduzido de 12 para 10
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6, // Reduzido de 8 para 6
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Adicionado para otimizar espaço
          children: [
            if (isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text(
                'Carregando...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ] else ...[
              Icon(
                Icons.account_balance_wallet,
                size: 28, // Reduzido de 32 para 28
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 6), // Reduzido de 8 para 6
              // Available label (top)
              Text(
                'DISPONÍVEL',
                style: TextStyle(
                  fontSize: 9, // Reduzido de 10 para 9
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3, // Reduzido de 0.5 para 0.3
                ),
              ),
              const SizedBox(height: 2),
              // Real value
              Text(
                'R\$ ${balance?.realValue.toStringAsFixed(2).replaceAll('.', ',') ?? '0,00'}',
                style: TextStyle(
                  fontSize: 16, // Reduzido de 18 para 16
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 6), // Reduzido de 8 para 6
              // Credits (bottom, compact)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    balance?.credits.toStringAsFixed(0) ?? '0',
                    style: TextStyle(
                      fontSize: 14, // Reduzido de 16 para 16
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 3), // Reduzido de 4 para 3
                  Text(
                    'créditos',
                    style: TextStyle(
                      fontSize: 9, // Reduzido de 10 para 9
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.3, // Reduzido de 0.5 para 0.3
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }


}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const ActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final iColor = iconColor ?? Colors.white;
    final tColor = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12), // Reduzido de 16 para 12
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10), // Reduzido de 12 para 10
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 6, // Reduzido de 8 para 6
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Adicionado para otimizar espaço
          children: [
            Icon(
              icon,
              size: 28, // Reduzido de 32 para 28
              color: iColor,
            ),
            const SizedBox(height: 6), // Reduzido de 8 para 6
            Flexible( // Adicionado para evitar overflow
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11, // Reduzido de 12 para 11
                  fontWeight: FontWeight.bold,
                  color: tColor,
                  letterSpacing: 0.5, // Reduzido de 1 para 0.5
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Permite até 2 linhas
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}