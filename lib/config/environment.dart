/// API Configuration class to define endpoints for different environments
class ApiConfig {
  final String register;
  final String autentica;
  final String transaciona;
  final String voucher;

  const ApiConfig({
    required this.register,
    required this.autentica,
    required this.transaciona,
    required this.voucher,
  });
}

/// Environment configuration class that manages all API endpoints and app configuration
class Environment {
  /// Current environment - change this to switch between dev/prod for entire app
  static String _currentEnvironment = 'dev';

  /// API endpoints configuration for different environments
  static const Map<String, ApiConfig> _apiConfigs = {
    'dev': ApiConfig(
      register: 'https://cadastrah.timob.com.br',
      autentica: 'https://autenticah.timob.com.br',
      transaciona: 'https://transacionah.timob.com.br',
      voucher: 'https://voucherh.timob.com.br',
    ),
    'prod': ApiConfig(
      register: 'https://cadastra.timob.com.br',
      autentica: 'https://autentica.timob.com.br',
      transaciona: 'https://transaciona.timob.com.br',
      voucher: 'https://voucher.timob.com.br',
    ),
    'offline': ApiConfig(
      register: 'http://localhost:8080',
      autentica: 'http://localhost:8081',
      transaciona: 'http://localhost:8082',
      voucher: 'http://localhost:8083',
    ),
  };

  /// Gets the current environment (dev/prod)
  static String get currentEnvironment => _currentEnvironment;

  /// Sets the current environment for the entire app
  static void setEnvironment(String env) {
    if (_apiConfigs.containsKey(env)) {
      _currentEnvironment = env;
    } else {
      throw ArgumentError(
          'Invalid environment: $env. Valid options: ${_apiConfigs.keys.join(', ')}');
    }
  }

  /// Gets the current API configuration based on selected environment
  static ApiConfig get apiConfig => _apiConfigs[_currentEnvironment]!;

  /// Individual API endpoint getters for easy access
  static String get registerApi => apiConfig.register;
  static String get autenticaApi => apiConfig.autentica;
  static String get transacionaApi => apiConfig.transaciona;
  static String get voucherApi => apiConfig.voucher;

  /// Gets the city name from dart-define
  /// Usage: String.fromEnvironment('CITY_NAME', defaultValue: 'Unknown City')
  static const String cityName = String.fromEnvironment(
    'CITY_NAME',
    defaultValue: 'Cidade não configurada',
  );

  /// Gets the flavor from dart-define
  /// Usage: String.fromEnvironment('FLAVOR', defaultValue: 'demo')
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'demo',
  );

  /// Check if environment variables are properly configured
  static bool get isConfigured => cityName != 'Cidade não configurada';

  /// Get display information
  static String get displayInfo =>
      'Cidade: $cityName (Flavor: $flavor) | Env: $_currentEnvironment';

  /// Get all available environments
  static List<String> get availableEnvironments => _apiConfigs.keys.toList();

  /// Debug method to print current configuration
  static void printCurrentConfig() {
    print('🌐 Environment Configuration:');
    print('  Current: $_currentEnvironment');
    print('  Register: ${registerApi}');
    print('  Autentica: ${autenticaApi}');
    print('  Transaciona: ${transacionaApi}');
    print('  Voucher: ${voucherApi}');
    print('  City: $cityName');
    print('  Flavor: $flavor');
  }
}
