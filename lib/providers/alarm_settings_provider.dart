import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

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

  // Converte para JSON para persistência
  Map<String, dynamic> toJson() {
    return {
      'parkingExpiration': parkingExpiration,
      'paymentReminders': paymentReminders,
      'promotions': promotions,
      'systemUpdates': systemUpdates,
      'reminderMinutes': reminderMinutes,
      'localNotificationsEnabled': localNotificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'lightsEnabled': lightsEnabled,
    };
  }

  // Cria a partir de JSON para carregamento
  factory AlarmSettings.fromJson(Map<String, dynamic> json) {
    return AlarmSettings(
      parkingExpiration: json['parkingExpiration'] ?? true,
      paymentReminders: json['paymentReminders'] ?? true,
      promotions: json['promotions'] ?? false,
      systemUpdates: json['systemUpdates'] ?? true,
      reminderMinutes: json['reminderMinutes'] ?? 15,
      localNotificationsEnabled: json['localNotificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      lightsEnabled: json['lightsEnabled'] ?? true,
    );
  }
}

// Provider para as configurações de alarme
final alarmSettingsProvider =
    StateNotifierProvider<AlarmSettingsNotifier, AlarmSettings>((ref) {
  return AlarmSettingsNotifier();
});

class AlarmSettingsNotifier extends StateNotifier<AlarmSettings> {
  static const String _storageKey = 'alarm_settings';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  AlarmSettingsNotifier() : super(const AlarmSettings()) {
    _loadSettings();
  }

  // Carrega as configurações salvas
  Future<void> _loadSettings() async {
    try {
      final savedSettings = await _storage.read(key: _storageKey);
      if (savedSettings != null) {
        final json = jsonDecode(savedSettings);
        state = AlarmSettings.fromJson(json);
      }
    } catch (e) {
      // Se houver erro ao carregar, mantém as configurações padrão
      print('Erro ao carregar configurações de alarme: $e');
    }
  }

  // Salva as configurações
  Future<void> _saveSettings() async {
    try {
      final json = jsonEncode(state.toJson());
      await _storage.write(key: _storageKey, value: json);
    } catch (e) {
      print('Erro ao salvar configurações de alarme: $e');
    }
  }

  // Atualiza a configuração de vencimento do estacionamento
  Future<void> updateParkingExpiration(bool value) async {
    state = state.copyWith(parkingExpiration: value);
    await _saveSettings();
  }

  // Atualiza a configuração de lembretes de pagamento
  Future<void> updatePaymentReminders(bool value) async {
    state = state.copyWith(paymentReminders: value);
    await _saveSettings();
  }

  // Atualiza a configuração de promoções
  Future<void> updatePromotions(bool value) async {
    state = state.copyWith(promotions: value);
    await _saveSettings();
  }

  // Atualiza a configuração de atualizações do sistema
  Future<void> updateSystemUpdates(bool value) async {
    state = state.copyWith(systemUpdates: value);
    await _saveSettings();
  }

  // Atualiza o tempo de antecedência
  Future<void> updateReminderMinutes(int minutes) async {
    state = state.copyWith(reminderMinutes: minutes);
    await _saveSettings();
  }

  // Atualiza a configuração de notificações locais
  Future<void> updateLocalNotificationsEnabled(bool value) async {
    state = state.copyWith(localNotificationsEnabled: value);
    await _saveSettings();
  }

  // Atualiza a configuração de som
  Future<void> updateSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await _saveSettings();
  }

  // Atualiza a configuração de vibração
  Future<void> updateVibrationEnabled(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await _saveSettings();
  }

  // Atualiza a configuração de luzes
  Future<void> updateLightsEnabled(bool value) async {
    state = state.copyWith(lightsEnabled: value);
    await _saveSettings();
  }

  // Reseta todas as configurações para os valores padrão
  Future<void> resetToDefaults() async {
    state = const AlarmSettings();
    await _saveSettings();
  }

  // Lista de opções de tempo disponíveis
  List<int> get reminderOptions => [5, 10, 15, 30, 60];
}
