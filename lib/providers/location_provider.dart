import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// Estado da localização
class LocationState {
  final Position? currentPosition;
  final bool isGettingLocation;
  final String? error;

  const LocationState({
    this.currentPosition,
    this.isGettingLocation = false,
    this.error,
  });

  LocationState copyWith({
    Position? currentPosition,
    bool? isGettingLocation,
    String? error,
    bool clearError = false,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() {
    return 'LocationState(currentPosition: ${currentPosition?.latitude}, ${currentPosition?.longitude}, isGettingLocation: $isGettingLocation, error: $error)';
  }
}

// Notifier para gerenciar a localização
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  /// Obtém a localização atual
  Future<void> getCurrentLocation() async {
    if (kDebugMode) {
      print('📍 LocationProvider.getCurrentLocation - Iniciando...');
      print('📍 LocationProvider.getCurrentLocation - Estado atual: ${state.toString()}');
    }
    
    state = state.copyWith(isGettingLocation: true, clearError: true);

    try {
      if (kDebugMode) {
        print('📍 LocationProvider.getCurrentLocation - Verificando permissões...');
      }
      
      // Verifica permissões de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (kDebugMode) {
        print('📍 LocationProvider.getCurrentLocation - Permissão atual: $permission');
      }
      
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('📍 LocationProvider.getCurrentLocation - Solicitando permissão...');
        }
        permission = await Geolocator.requestPermission();
        if (kDebugMode) {
          print('📍 LocationProvider.getCurrentLocation - Nova permissão: $permission');
        }
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      if (kDebugMode) {
        print('📍 LocationProvider.getCurrentLocation - Obtendo posição...');
      }
      
      // Obtém a posição atual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (kDebugMode) {
        print('📍 LocationProvider.getCurrentLocation - Posição obtida: ${position.latitude}, ${position.longitude}');
      }

      state = state.copyWith(
        currentPosition: position,
        isGettingLocation: false,
      );

      if (kDebugMode) {
        print('📍 LocationProvider.getCurrentLocation - Estado atualizado: ${state.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LocationProvider.getCurrentLocation - Erro: $e');
      }
      
      state = state.copyWith(
        isGettingLocation: false,
        error: e.toString(),
      );
      
      if (kDebugMode) {
        print('❌ LocationProvider.getCurrentLocation - Estado após erro: ${state.toString()}');
      }
    }
  }

  /// Limpa o erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reseta o estado
  void reset() {
    state = const LocationState();
  }
}

// Provider principal
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

// Providers de conveniência
final currentPositionProvider = Provider<Position?>((ref) {
  return ref.watch(locationProvider).currentPosition;
});

final isGettingLocationProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).isGettingLocation;
});

final locationErrorProvider = Provider<String?>((ref) {
  return ref.watch(locationProvider).error;
});
