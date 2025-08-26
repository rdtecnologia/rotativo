import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo para as configurações de alarme
class AlarmSettings {
  final bool parkingExpiration;
  final bool paymentReminders;
  final bool promotions;
  final bool systemUpdates;
  final int reminderMinutes;
  final bool localNotificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool lightsEnabled;

  const AlarmSettings({
    this.parkingExpiration = true,
    this.paymentReminders = true,
    this.promotions = false,
    this.systemUpdates = true,
    this.reminderMinutes = 15,
    this.localNotificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.lightsEnabled = true,
  });

  AlarmSettings copyWith({
    bool? parkingExpiration,
    bool? paymentReminders,
    bool? promotions,
    bool? systemUpdates,
    int? reminderMinutes,
    bool? localNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? lightsEnabled,
  }) {
    return AlarmSettings(
      parkingExpiration: parkingExpiration ?? this.parkingExpiration,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      promotions: promotions ?? this.promotions,
      systemUpdates: systemUpdates ?? this.systemUpdates,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      localNotificationsEnabled:
          localNotificationsEnabled ?? this.localNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      lightsEnabled: lightsEnabled ?? this.lightsEnabled,
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

  // Atualiza a configuração de notificações locais
  void updateLocalNotificationsEnabled(bool value) {
    state = state.copyWith(localNotificationsEnabled: value);
  }

  // Atualiza a configuração de som
  void updateSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
  }

  // Atualiza a configuração de vibração
  void updateVibrationEnabled(bool value) {
    state = state.copyWith(vibrationEnabled: value);
  }

  // Atualiza a configuração de luzes
  void updateLightsEnabled(bool value) {
    state = state.copyWith(lightsEnabled: value);
  }

  // Reseta todas as configurações para os valores padrão
  void resetToDefaults() {
    state = const AlarmSettings();
  }

  // Lista de opções de tempo disponíveis
  List<int> get reminderOptions => [5, 10, 15, 30, 60];
}
