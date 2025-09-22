import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_models.dart';
import '../providers/active_activations_provider.dart';
import '../utils/formatters.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode

class ParkingTimer extends ConsumerWidget {
  final Vehicle vehicle;
  final double? width;
  final double? height;

  const ParkingTimer({
    super.key,
    required this.vehicle,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeActivation =
        ref.watch(vehicleActiveActivationProvider(vehicle));
    // Observa mudanças no tempo global para forçar rebuild quando necessário
    ref.watch(timeUpdateProvider);

    if (activeActivation == null) {
      return const SizedBox.shrink(); // Não mostra nada se não há ativação
    }

    // SEMPRE mostra a ativação se ela existir, independentemente do status
    final isActive = activeActivation.isActive;

    // DEBUG DETALHADO para entender o problema
    if (kDebugMode) {
      final now = DateTime.now();
      final expirationTime = activeActivation.expiresAt ??
          activeActivation.activatedAt
              .add(Duration(minutes: activeActivation.parkingTime));

      debugPrint('🅿️ ParkingTimer DEBUG para ${vehicle.licensePlate}:');
      debugPrint('  - ID: ${activeActivation.id}');
      debugPrint('  - Status: ${activeActivation.status}');
      debugPrint('  - ParkingTime: ${activeActivation.parkingTime} minutos');
      debugPrint('  - ActivatedAt: ${activeActivation.activatedAt}');
      debugPrint('  - ExpiresAt: ${activeActivation.expiresAt}');
      debugPrint('  - Calculated Expiration: $expirationTime');
      debugPrint('  - Now: $now');
      debugPrint('  - IsActive: $isActive');
      debugPrint('  - RemainingMinutes: ${activeActivation.remainingMinutes}');
      debugPrint(
          '  - Time difference: ${expirationTime.difference(now).inMinutes} minutos');
    }

    final remainingMinutes = activeActivation.remainingMinutes;
    final totalMinutes = activeActivation.parkingTime;
    final progress = remainingMinutes / totalMinutes;

    // Calcula a hora de expiração
    final expirationTime = activeActivation.expiresAt ??
        activeActivation.activatedAt.add(Duration(minutes: totalMinutes));

    // Formata o tempo restante
    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;
    String timeText;
    if (hours > 0) {
      timeText = '${hours}h ${minutes}min';
    } else {
      timeText = '${minutes}min';
    }

    // Define a cor baseada no status da ativação
    Color timerColor;

    if (!isActive) {
      // Ativação expirada mas recente (últimas 24h)
      timerColor = Colors.grey;
    } else if (remainingMinutes <= 5) {
      timerColor = Colors.red;
    } else if (remainingMinutes <= 15) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.green;
    }

    return Container(
      width: width,
      height: height,
      constraints: const BoxConstraints(
        minHeight: 70, // Reduzido de 90 para 70
        maxHeight: 90, // Reduzido de 120 para 90
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6), // Reduzido vertical de 8 para 6
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: timerColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tempo restante com ícone na frente
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: timerColor,
                size: 14, // Reduzido de 16 para 14
              ),
              const SizedBox(width: 4),
              Text(
                timeText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15, // Reduzido de 16 para 15
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Barra de progresso
          SizedBox(
            width: double.infinity,
            child: LinearProgressIndicator(
              value: !isActive ? 0.0 : progress, // 0 para ativações expiradas
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              minHeight: 4, // Reduzido de 5 para 4
            ),
          ),

          // Status e hora de expiração
          Text(
            !isActive
                ? 'Ativado às ${AppFormatters.formatTime(activeActivation.activatedAt)}'
                : 'Expira às ${AppFormatters.formatTime(expirationTime)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 1),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Status adicional para ativações expiradas
          if (!isActive) ...[
            const SizedBox(height: 2),
            Text(
              'Expirado',
              style: TextStyle(
                color: const Color.fromARGB(255, 227, 65, 65),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget compacto para mostrar apenas o tempo restante
class CompactParkingTimer extends ConsumerWidget {
  final Vehicle vehicle;
  final double? size;

  const CompactParkingTimer({
    super.key,
    required this.vehicle,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeActivation =
        ref.watch(vehicleActiveActivationProvider(vehicle));

    if (activeActivation == null || !activeActivation.isActive) {
      return const SizedBox.shrink();
    }

    final remainingMinutes = activeActivation.remainingMinutes;

    // Define a cor baseada no tempo restante
    Color timerColor;
    if (remainingMinutes <= 5) {
      timerColor = Colors.red;
    } else if (remainingMinutes <= 15) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.green;
    }

    // Formata o tempo restante de forma compacta
    String timeText;
    if (remainingMinutes >= 60) {
      final hours = remainingMinutes ~/ 60;
      final minutes = remainingMinutes % 60;
      timeText = minutes > 0 ? '${hours}h${minutes}m' : '${hours}h';
    } else {
      timeText = '${remainingMinutes}m';
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: timerColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          timeText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
