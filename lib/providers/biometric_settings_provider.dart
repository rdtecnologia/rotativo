import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';

class BiometricSettingsState {
  final bool biometricAvailable;
  final List<BiometricType> availableBiometrics;
  final bool isLoading;
  final bool hasStoredCredentials;

  const BiometricSettingsState({
    this.biometricAvailable = false,
    this.availableBiometrics = const [],
    this.isLoading = false,
    this.hasStoredCredentials = false,
  });

  BiometricSettingsState copyWith({
    bool? biometricAvailable,
    List<BiometricType>? availableBiometrics,
    bool? isLoading,
    bool? hasStoredCredentials,
  }) {
    return BiometricSettingsState(
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
      isLoading: isLoading ?? this.isLoading,
      hasStoredCredentials: hasStoredCredentials ?? this.hasStoredCredentials,
    );
  }
}

class BiometricSettingsNotifier extends StateNotifier<BiometricSettingsState> {
  BiometricSettingsNotifier() : super(const BiometricSettingsState()) {
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      final available = await BiometricService.isBiometricAvailable();
      final biometrics = await BiometricService.getAvailableBiometrics();

      // Verificar se há credenciais biométricas válidas
      final hasCredentials = await AuthService.hasValidBiometricCredentials();

      state = state.copyWith(
        biometricAvailable: available,
        availableBiometrics: biometrics,
        hasStoredCredentials: hasCredentials,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshBiometricStatus() async {
    await _checkBiometricStatus();
  }
}

final biometricSettingsProvider =
    StateNotifierProvider<BiometricSettingsNotifier, BiometricSettingsState>(
  (ref) => BiometricSettingsNotifier(),
);
