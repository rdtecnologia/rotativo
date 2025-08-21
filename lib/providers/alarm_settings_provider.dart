import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo para as configurações de alarme
class AlarmSettings {
  final bool parkingExpiration;
  final bool paymentReminders;
  final bool promotions;
  final bool systemUpdates;
  final int reminderMinutes;

  const AlarmSettings({
    this.parkingExpiration = true,
    this.paymentReminders = true,
    this.promotions = false,
    this.systemUpdates = true,
    this.reminderMinutes = 15,
  });

  AlarmSettings copyWith({
    bool? parkingExpiration,
    bool? paymentReminders,
    bool? promotions,
    bool? systemUpdates,
    int? reminderMinutes,
  }) {
    return AlarmSettings(
      parkingExpiration: parkingExpiration ?? this.parkingExpiration,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      promotions: promotions ?? this.promotions,
      systemUpdates: systemUpdates ?? this.systemUpdates,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}

// Provider para as configurações de alarme
final alarmSettingsProvider =
    StateNotifierProvider<AlarmSettingsNotifier, AlarmSettings>((ref) {
  return AlarmSettingsNotifier();
});

class AlarmSettingsNotifier extends StateNotifier<AlarmSettings> {
  AlarmSettingsNotifier() : super(const AlarmSettings());

  // Atualiza a configuração de vencimento do estacionamento
  void updateParkingExpiration(bool value) {
    state = state.copyWith(parkingExpiration: value);
  }

  // Atualiza a configuração de lembretes de pagamento
  void updatePaymentReminders(bool value) {
    state = state.copyWith(paymentReminders: value);
  }

  // Atualiza a configuração de promoções
  void updatePromotions(bool value) {
    state = state.copyWith(promotions: value);
  }

  // Atualiza a configuração de atualizações do sistema
  void updateSystemUpdates(bool value) {
    state = state.copyWith(systemUpdates: value);
  }

  // Atualiza o tempo de antecedência
  void updateReminderMinutes(int minutes) {
    state = state.copyWith(reminderMinutes: minutes);
  }

  // Reseta todas as configurações para os valores padrão
  void resetToDefaults() {
    state = const AlarmSettings();
  }

  // Lista de opções de tempo disponíveis
  List<int> get reminderOptions => [5, 10, 15, 30, 60];
}
