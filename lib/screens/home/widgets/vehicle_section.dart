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

              if (isLoading) {
                return const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                );
              }

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
