import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationSettingsState {
  final bool shareLocation;
  final bool highAccuracy;
  final bool backgroundLocation;
  final bool automaticParking;
  final String currentLocation;
  final String locationStatus;
  final bool isLoading;

  const LocationSettingsState({
    this.shareLocation = false,
    this.highAccuracy = true,
    this.backgroundLocation = false,
    this.automaticParking = true,
    this.currentLocation = 'Carregando...',
    this.locationStatus = 'Permissão não concedida',
    this.isLoading = false,
  });

  LocationSettingsState copyWith({
    bool? shareLocation,
    bool? highAccuracy,
    bool? backgroundLocation,
    bool? automaticParking,
    String? currentLocation,
    String? locationStatus,
    bool? isLoading,
  }) {
    return LocationSettingsState(
      shareLocation: shareLocation ?? this.shareLocation,
      highAccuracy: highAccuracy ?? this.highAccuracy,
      backgroundLocation: backgroundLocation ?? this.backgroundLocation,
      automaticParking: automaticParking ?? this.automaticParking,
      currentLocation: currentLocation ?? this.currentLocation,
      locationStatus: locationStatus ?? this.locationStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationSettingsNotifier extends StateNotifier<LocationSettingsState> {
  LocationSettingsNotifier() : super(const LocationSettingsState()) {
    _checkLocationStatus();
  }

  void setHighAccuracy(bool value) {
    state = state.copyWith(highAccuracy: value);
  }

  void setBackgroundLocation(bool value) {
    state = state.copyWith(backgroundLocation: value);
  }

  void setAutomaticParking(bool value) {
    state = state.copyWith(automaticParking: value);
  }

  Future<void> toggleLocationSharing(bool value) async {
    if (value) {
      final hasPermission = await _requestLocationPermission();
      if (hasPermission) {
        state = state.copyWith(
          shareLocation: true,
          locationStatus: 'Ativo',
        );
        await _getCurrentLocation();
      }
    } else {
      state = state.copyWith(
        shareLocation: false,
        locationStatus: 'Desativado',
        currentLocation: 'Localização desativada',
      );
    }
  }

  Future<void> _checkLocationStatus() async {
    state = state.copyWith(
      locationStatus: 'Verificando...',
      isLoading: true,
    );

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        state = state.copyWith(
          locationStatus: 'Serviços de localização desabilitados',
          currentLocation: 'Ative a localização nas configurações',
          isLoading: false,
        );
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      switch (permission) {
        case LocationPermission.denied:
          state = state.copyWith(
            locationStatus: 'Permissão negada',
            currentLocation: 'Permissão necessária para funcionar',
            isLoading: false,
          );
          break;
        case LocationPermission.deniedForever:
          state = state.copyWith(
            locationStatus: 'Permissão negada permanentemente',
            currentLocation: 'Configure nas configurações do app',
            isLoading: false,
          );
          break;
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          state = state.copyWith(
            locationStatus: 'Permissão concedida',
            shareLocation: true,
            isLoading: false,
          );
          await _getCurrentLocation();
          break;
        case LocationPermission.unableToDetermine:
          state = state.copyWith(
            locationStatus: 'Não foi possível determinar',
            currentLocation: 'Erro ao verificar permissões',
            isLoading: false,
          );
          break;
      }
    } catch (e) {
      state = state.copyWith(
        locationStatus: 'Erro ao verificar',
        currentLocation: 'Erro desconhecido',
        isLoading: false,
      );
    }
  }

  Future<bool> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        try {
          permission = await Geolocator.requestPermission();
        } catch (e) {
          return false;
        }

        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    state = state.copyWith(
      currentLocation: 'Obtendo localização...',
      isLoading: true,
    );

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: state.highAccuracy
            ? LocationAccuracy.high
            : LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      state = state.copyWith(
        currentLocation:
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Erro ao obter localização';

      if (e.toString().contains('Location service is disabled')) {
        errorMessage = 'Serviços de localização desabilitados';
      } else if (e.toString().contains('Location permission denied')) {
        errorMessage = 'Permissão de localização negada';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Timeout ao obter localização';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Erro de rede';
      }

      state = state.copyWith(
        currentLocation: errorMessage,
        isLoading: false,
      );
    }
  }

  Future<void> testLocation() async {
    await _getCurrentLocation();
  }
}

final locationSettingsProvider =
    StateNotifierProvider<LocationSettingsNotifier, LocationSettingsState>(
  (ref) => LocationSettingsNotifier(),
);
