import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment.dart';

/// Provider para gerenciar o estado do ambiente de forma reativa
final environmentProvider =
    StateNotifierProvider<EnvironmentNotifier, EnvironmentState>((ref) {
  return EnvironmentNotifier();
});

/// Estado do ambiente
class EnvironmentState {
  final String currentEnvironment;
  final bool isDebugMode;

  const EnvironmentState({
    required this.currentEnvironment,
    required this.isDebugMode,
  });

  EnvironmentState copyWith({
    String? currentEnvironment,
    bool? isDebugMode,
  }) {
    return EnvironmentState(
      currentEnvironment: currentEnvironment ?? this.currentEnvironment,
      isDebugMode: isDebugMode ?? this.isDebugMode,
    );
  }
}

/// Notifier para gerenciar mudanças no ambiente
class EnvironmentNotifier extends StateNotifier<EnvironmentState> {
  EnvironmentNotifier()
      : super(EnvironmentState(
          currentEnvironment: Environment.currentEnvironment,
          isDebugMode: true, // Sempre true para este provider
        ));

  /// Inicializa o provider com o ambiente atual
  void initialize() {
    state = state.copyWith(
      currentEnvironment: Environment.currentEnvironment,
      isDebugMode: true,
    );
  }

  /// Altera o ambiente atual
  void setEnvironment(String environment) {
    try {
      Environment.setEnvironment(environment);
      state = state.copyWith(currentEnvironment: environment);
    } catch (e) {
      // Em caso de erro, mantém o ambiente atual
      print('Erro ao alterar ambiente: $e');
    }
  }

  /// Obtém o ambiente atual
  String get currentEnvironment => state.currentEnvironment;

  /// Obtém a configuração da API atual
  ApiConfig get currentApiConfig => Environment.apiConfig;

  /// Obtém todos os ambientes disponíveis
  List<String> get availableEnvironments => Environment.availableEnvironments;

  /// Verifica se está no ambiente de desenvolvimento
  bool get isDev => currentEnvironment == 'dev';

  /// Verifica se está no ambiente de produção
  bool get isProd => currentEnvironment == 'prod';

  /// Verifica se está no ambiente offline
  bool get isOffline => currentEnvironment == 'offline';

  /// Obtém a cor do indicador de ambiente
  int get environmentColor {
    switch (currentEnvironment) {
      case 'dev':
        return 0xFFFF9800; // Laranja
      case 'prod':
        return 0xFF4CAF50; // Verde
      case 'offline':
        return 0xFF9E9E9E; // Cinza
      default:
        return 0xFF9E9E9E; // Cinza padrão
    }
  }

  /// Obtém o nome amigável do ambiente
  String get environmentDisplayName {
    switch (currentEnvironment) {
      case 'dev':
        return 'DEV';
      case 'prod':
        return 'PROD';
      case 'offline':
        return 'OFFLINE';
      default:
        return currentEnvironment.toUpperCase();
    }
  }
}
