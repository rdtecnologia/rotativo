import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'environment.dart';

/// Dynamic app configuration that loads city config based on environment variables
class DynamicAppConfig {
  static Map<String, dynamic>? _cachedConfig;

  /// Flavor to city directory mapping
  static const Map<String, String> flavorToCityMapping = {
    'demo': 'Main',
    'ouroPreto': 'OuroPreto',
    'vicosa': 'Vicosa',
  };

  /// Load configuration based on current flavor
  static Future<Map<String, dynamic>> _loadConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;

    final flavor = Environment.flavor;
    final cityDirectory = flavorToCityMapping[flavor];

    if (kDebugMode) {
      print('🔍 DynamicAppConfig._loadConfig - Environment.flavor: $flavor');
      print(
          '🔍 DynamicAppConfig._loadConfig - Mapped cityDirectory: $cityDirectory');
      print(
          '🔍 DynamicAppConfig._loadConfig - Available flavors: ${flavorToCityMapping.keys.toList()}');
    }

    if (cityDirectory == null) {
      throw Exception('No city directory mapped for flavor: $flavor');
    }

    try {
      final configPath =
          'assets/config/cities/$cityDirectory/$cityDirectory.json';
      final configString = await rootBundle.loadString(configPath);
      _cachedConfig = jsonDecode(configString) as Map<String, dynamic>;

      // Debug log
      if (kDebugMode) {
        print('🏙️ DynamicAppConfig - Flavor: $flavor');
        print('🏙️ DynamicAppConfig - City Directory: $cityDirectory');
        print('🏙️ DynamicAppConfig - Config Path: $configPath');
        print('🏙️ DynamicAppConfig - Loaded city: ${_cachedConfig!['city']}');
        print(
            '🏙️ DynamicAppConfig - Loaded domain: ${_cachedConfig!['domain']}');
        print(
            '🏙️ DynamicAppConfig - Loaded primaryColor: ${_cachedConfig!['primaryColor']}');
        print(
            '🏙️ DynamicAppConfig - All config keys: ${_cachedConfig!.keys.toList()}');
      }

      return _cachedConfig!;
    } catch (e) {
      throw Exception(
          'Failed to load config for flavor $flavor (city: $cityDirectory): $e');
    }
  }

  /// Get city name from environment or config
  static Future<String> get cityName async {
    // If we have a city name from environment, use it
    if (Environment.isConfigured) {
      return Environment.cityName;
    }

    // Otherwise, load from config file
    final config = await _loadConfig();
    return config['city'] ?? 'Unknown City';
  }

  /// Get display name with prefix
  static Future<String> get displayName async {
    final city = await cityName;
    return 'Rotativo $city';
  }

  static Future<String> get domain async {
    final config = await _loadConfig();
    return config['domain'] ?? '';
  }

  static Future<double> get latitude async {
    final config = await _loadConfig();
    return (config['latitude'] ?? 0.0).toDouble();
  }

  static Future<double> get longitude async {
    final config = await _loadConfig();
    return (config['longitude'] ?? 0.0).toDouble();
  }

  static Future<String> get downloadLink async {
    final config = await _loadConfig();
    return config['downloadLink'] ?? '';
  }

  static Future<String?> get termsLink async {
    final config = await _loadConfig();
    return config['termsLink'];
  }

  static Future<String> get androidPackage async {
    final config = await _loadConfig();
    return config['androidPackage'] ?? '';
  }

  static Future<String> get iosPackage async {
    final config = await _loadConfig();
    return config['iosPackage'] ?? '';
  }

  static Future<String> get iosAppStoreId async {
    final config = await _loadConfig();
    return config['iosAppStoreId'] ?? '';
  }

  static Future<String?> get whatsapp async {
    final config = await _loadConfig();
    return config['whatsapp'];
  }

  static Future<String?> get chatBotURL async {
    final config = await _loadConfig();
    return config['chatBotURL'];
  }

  static Future<List<int>> get products async {
    final config = await _loadConfig();
    final productsList = config['products'] as List?;
    return productsList?.cast<int>() ?? [];
  }

  static Future<List<int>> get vehicleTypes async {
    final config = await _loadConfig();
    final vehicleTypesList = config['vehicleTypes'] as List?;
    return vehicleTypesList?.cast<int>() ?? [];
  }

  static Future<String> get mainLogo async {
    final config = await _loadConfig();
    return config['mainLogo'] ?? '';
  }

  static Future<String> get logoMenu async {
    final config = await _loadConfig();
    return config['logoMenu'] ?? '';
  }

  /// Get primary color from config
  static Future<String> get primaryColor async {
    final config = await _loadConfig();
    final color = config['primaryColor'] ?? '#074733'; // Default fallback color

    if (kDebugMode) {
      print('🎨 DynamicAppConfig.primaryColor - Loaded color: $color');
      print(
          '🎨 DynamicAppConfig.primaryColor - Config keys: ${config.keys.toList()}');
      print('🎨 DynamicAppConfig.primaryColor - Raw config: $config');
      print(
          '🎨 DynamicAppConfig.primaryColor - primaryColor type: ${config['primaryColor'].runtimeType}');
    }

    return color;
  }

  /// Get secondary color from config
  static Future<String> get secondaryColor async {
    final config = await _loadConfig();
    final color =
        config['secondaryColor'] ?? '#17428e'; // Default fallback color

    if (kDebugMode) {
      print('🎨 DynamicAppConfig.secondaryColor - Loaded color: $color');
      print(
          '🎨 DynamicAppConfig.secondaryColor - Config keys: ${config.keys.toList()}');
      print('🎨 DynamicAppConfig.secondaryColor - Raw config: $config');
      print(
          '🎨 DynamicAppConfig.secondaryColor - secondaryColor type: ${config['secondaryColor'].runtimeType}');
    }

    return color;
  }

  static Future<Map<String, dynamic>> get balance async {
    final config = await _loadConfig();
    return config['balance'] ?? {};
  }

  static Future<String?> get parkingRulesText async {
    final config = await _loadConfig();
    return config['parkingRulesText'];
  }

  static Future<Map<String, dynamic>> get parkingRules async {
    final config = await _loadConfig();
    final rules = config['parkingRules'] ?? {};

    // Debug log for parking rules
    if (kDebugMode) {
      print(
          '🏁 DynamicAppConfig.parkingRules - Current flavor: ${Environment.flavor}');
      print(
          '🏁 DynamicAppConfig.parkingRules - Loaded city: ${config['city']}');
      print('🏁 DynamicAppConfig.parkingRules - Parking rules: $rules');

      // Check specific rules for vehicle types
      final carRules = rules['1'] as List?;
      final motoRules = rules['2'] as List?;

      print('🏁 Car rules (type 1): $carRules');
      print('🏁 Moto rules (type 2): $motoRules');

      if (motoRules != null && motoRules.isNotEmpty) {
        final firstMotoRule = motoRules[0] as Map<String, dynamic>;
        print('🏁 First moto rule credits: ${firstMotoRule['credits']}');
      }
    }

    return rules;
  }

  static Future<Map<String, dynamic>> get purchase async {
    final config = await _loadConfig();
    return config['purchase'] ?? {};
  }

  static Future<List<Map<String, dynamic>>> get faq async {
    final config = await _loadConfig();
    final faqList = config['faq'] as List?;
    if (faqList != null) {
      return faqList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Clear cached config (useful for testing or switching flavors)
  static void clearCache() {
    _cachedConfig = null;
    if (kDebugMode) {
      print('🔄 DynamicAppConfig - Cache cleared');
    }
  }

  /// Get debug info
  static Future<Map<String, dynamic>> getDebugInfo() async {
    return {
      'flavor': Environment.flavor,
      'cityName': Environment.cityName,
      'isConfigured': Environment.isConfigured,
      'displayInfo': Environment.displayInfo,
      'configuredCityDirectory': flavorToCityMapping[Environment.flavor],
    };
  }
}
