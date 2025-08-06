import 'dart:convert';
import 'package:flutter/services.dart';
import 'environment.dart';

/// Dynamic app configuration that loads city config based on environment variables
class DynamicAppConfig {
  static Map<String, dynamic>? _cachedConfig;
  
  /// Flavor to city directory mapping
  static const Map<String, String> flavorToCityMapping = {
    'demo': 'Main',
    'patosDeMinas': 'PatosDeMinas',
    'janauba': 'Janauba',
    'conselheiroLafaiete': 'ConselheiroLafaiete',
    'capaoBonito': 'CapaoBonito',
    'joaoMonlevade': 'JoaoMonlevade',
    'itarare': 'Itarare',
    'passos': 'Passos',
    'ribeiraoDasNeves': 'RibeiraoDasNeves',
    'igarape': 'Igarape',
    'ouroPreto': 'OuroPreto',
  };

  /// Load configuration based on current flavor
  static Future<Map<String, dynamic>> _loadConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;

    final flavor = Environment.flavor;
    final cityDirectory = flavorToCityMapping[flavor];
    
    if (cityDirectory == null) {
      throw Exception('No city directory mapped for flavor: $flavor');
    }

    try {
      final configPath = 'assets/config/cities/$cityDirectory/$cityDirectory.json';
      final configString = await rootBundle.loadString(configPath);
      _cachedConfig = jsonDecode(configString) as Map<String, dynamic>;
      return _cachedConfig!;
    } catch (e) {
      throw Exception('Failed to load config for flavor $flavor (city: $cityDirectory): $e');
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
    return config['parkingRules'] ?? {};
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