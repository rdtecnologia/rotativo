import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/vehicle_models.dart';
import '../../parking/parking_screen.dart';
import '../../purchase/choose_value_screen.dart';
import '../../history/history_screen.dart';

mixin HomeNavigationMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Future<void> navigateToParking(Vehicle vehicle, Future<void> Function() updateBalance) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingScreen(vehicle: vehicle),
      ),
    );
    await updateBalance();
  }

  Future<void> navigateToPurchase(Future<void> Function() updateBalance) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseValueScreen(vehicleType: 1),
      ),
    );
    await updateBalance();
  }

  Future<void> navigateToHistory(Future<void> Function() updateBalance) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
    await updateBalance();
  }
}
