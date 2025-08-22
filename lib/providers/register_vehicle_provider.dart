import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vehicle_models.dart';

// Estado da tela de registro de veículos
class RegisterVehicleState {
  final int selectedVehicleType;
  final bool isEditing;
  final String? editingLicensePlate;
  final bool isRetrying;
  final bool isSubmitting;

  const RegisterVehicleState({
    this.selectedVehicleType = 1,
    this.isEditing = false,
    this.editingLicensePlate,
    this.isRetrying = false,
    this.isSubmitting = false,
  });

  RegisterVehicleState copyWith({
    int? selectedVehicleType,
    bool? isEditing,
    String? editingLicensePlate,
    bool? isRetrying,
    bool? isSubmitting,
  }) {
    return RegisterVehicleState(
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      isEditing: isEditing ?? this.isEditing,
      editingLicensePlate: editingLicensePlate ?? this.editingLicensePlate,
      isRetrying: isRetrying ?? this.isRetrying,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// Provider para gerenciar o estado da tela de registro de veículos
class RegisterVehicleNotifier extends StateNotifier<RegisterVehicleState> {
  RegisterVehicleNotifier() : super(const RegisterVehicleState());

  // Selecionar tipo de veículo
  void selectVehicleType(int typeId) {
    state = state.copyWith(selectedVehicleType: typeId);
  }

  // Iniciar edição de veículo
  void startEditing(Vehicle vehicle) {
    state = state.copyWith(
      isEditing: true,
      editingLicensePlate: vehicle.licensePlate,
      selectedVehicleType: vehicle.type,
    );
  }

  // Cancelar edição
  void cancelEditing() {
    state = state.copyWith(
      isEditing: false,
      editingLicensePlate: null,
      selectedVehicleType: 1,
    );
  }

  // Definir estado de retry
  void setRetrying(bool isRetrying) {
    state = state.copyWith(isRetrying: isRetrying);
  }

  // Definir estado de submissão
  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  // Resetar formulário
  void resetForm() {
    state = state.copyWith(
      isEditing: false,
      editingLicensePlate: null,
      selectedVehicleType: 1,
      isRetrying: false,
      isSubmitting: false,
    );
  }
}

// Provider principal
final registerVehicleProvider =
    StateNotifierProvider<RegisterVehicleNotifier, RegisterVehicleState>(
  (ref) => RegisterVehicleNotifier(),
);

// Providers específicos para otimizar rebuilds
final selectedVehicleTypeProvider = Provider<int>((ref) {
  return ref.watch(registerVehicleProvider).selectedVehicleType;
});

final isEditingProvider = Provider<bool>((ref) {
  return ref.watch(registerVehicleProvider).isEditing;
});

final editingLicensePlateProvider = Provider<String?>((ref) {
  return ref.watch(registerVehicleProvider).editingLicensePlate;
});

final isRetryingProvider = Provider<bool>((ref) {
  return ref.watch(registerVehicleProvider).isRetrying;
});

final isSubmittingProvider = Provider<bool>((ref) {
  return ref.watch(registerVehicleProvider).isSubmitting;
});

final canSubmitProvider = Provider<bool>((ref) {
  final isSubmitting = ref.watch(isSubmittingProvider);
  final isRetrying = ref.watch(isRetryingProvider);
  return !isSubmitting && !isRetrying;
});
