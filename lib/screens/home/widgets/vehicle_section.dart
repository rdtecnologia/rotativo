import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/vehicle_models.dart';
import '../../../providers/vehicle_provider.dart';
import '../../../widgets/vehicle_carousel.dart';

class VehicleSection extends ConsumerWidget {
  final Function(Vehicle) onVehicleTap;
  final Future<void> Function() onRefresh;

  const VehicleSection({
    super.key,
    required this.onVehicleTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 3,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        child: Center(
          child: Consumer(
            builder: (context, ref, child) {
              final vehicles = ref.watch(vehicleListProvider);
              final isLoading = ref.watch(vehicleLoadingProvider);
              final hasInitialized = ref.watch(vehicleProvider).hasInitialized;

              // Mostra loading enquanto está carregando E não tem dados iniciais
              if (isLoading && !hasInitialized) {
                return const VehicleLoadingWidget();
              }

              // Se não está carregando E não tem veículos E já foi inicializado, mostra card de "sem veículos"
              if (!isLoading && vehicles.isEmpty && hasInitialized) {
                return const NoVehiclesWidget();
              }

              // Mostra o carrossel se tiver veículos OU ainda está carregando com dados existentes
              return VehicleCarousel(
                vehicles: vehicles,
                onVehicleTap: onVehicleTap,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget de loading elegante para a seção de veículos
class VehicleLoadingWidget extends StatelessWidget {
  const VehicleLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Carregando veículos...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
