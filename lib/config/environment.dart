/// Environment configuration class that reads dart-define values
class Environment {
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
  static String get displayInfo => 'Cidade: $cityName (Flavor: $flavor)';
}