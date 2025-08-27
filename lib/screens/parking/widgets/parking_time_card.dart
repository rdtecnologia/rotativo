import 'package:flutter/material.dart';
import '../../../utils/formatters.dart';

class ParkingTimeCard extends StatelessWidget {
  final int time;
  final int credits;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;
  final double? availableCredits;

  const ParkingTimeCard({
    super.key,
    required this.time,
    required this.credits,
    required this.price,
    required this.isSelected,
    required this.onTap,
    this.availableCredits,
  });

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasEnoughCredits =
        availableCredits == null || availableCredits! >= credits;

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : !hasEnoughCredits
                ? BorderSide(color: Colors.grey.shade100, width: 2)
                : BorderSide.none,
      ),
      color: !hasEnoughCredits ? Colors.grey[100] : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasEnoughCredits ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : null,
          ),
          child: Row(
            children: [
              // Time and credits info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : !hasEnoughCredits
                                  ? Colors.grey.shade500
                                  : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(time),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : !hasEnoughCredits
                                    ? Colors.grey.shade500
                                    : Colors.black87,
                          ),
                        ),
                        if (!hasEnoughCredits) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              'Créditos insuficientes',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          color: !hasEnoughCredits
                              ? Colors.grey.shade500
                              : Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$credits créditos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: hasEnoughCredits
                                      ? Colors.grey[600]
                                      : Colors.grey.shade500,
                                  fontWeight: hasEnoughCredits
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${AppFormatters.formatCurrency(price)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : !hasEnoughCredits
                              ? Colors.grey.shade500
                              : Colors.black87,
                    ),
                  ),
                  Text(
                    'valor',
                    style: TextStyle(
                      fontSize: 12,
                      color: !hasEnoughCredits
                          ? Colors.grey.shade500
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : !hasEnoughCredits
                            ? Colors.grey.shade400
                            : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : !hasEnoughCredits
                          ? Colors.grey.shade100
                          : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : !hasEnoughCredits
                        ? Icon(
                            Icons.block,
                            color: Colors.red.shade600,
                            size: 16,
                          )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
