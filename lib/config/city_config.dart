import 'dart:convert';
import 'package:flutter/services.dart';

/// Base city configuration loader
class CityConfigLoader {
  static Future<Map<String, dynamic>> loadConfig(String cityName) async {
    final String configPath = 'assets/config/cities/$cityName/$cityName.json';
    
    try {
      final String configString = await rootBundle.loadString(configPath);
      return jsonDecode(configString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load config for $cityName: $e');
    }
  }

  static Future<Map<String, dynamic>> loadMainConfig() async {
    return loadConfig('Main');
  }

  static Future<Map<String, dynamic>> loadPatosConfig() async {
    return loadConfig('PatosDeMinas');
  }

  static Future<Map<String, dynamic>> loadJanaubaConfig() async {
    return loadConfig('Janauba');
  }

  static Future<Map<String, dynamic>> loadLafaieteConfig() async {
    return loadConfig('ConselheiroLafaiete');
  }

  static Future<Map<String, dynamic>> loadCapaoConfig() async {
    return loadConfig('CapaoBonito');
  }

  static Future<Map<String, dynamic>> loadMonlevadeConfig() async {
    return loadConfig('JoaoMonlevade');
  }

  static Future<Map<String, dynamic>> loadItarareConfig() async {
    return loadConfig('Itarare');
  }

  static Future<Map<String, dynamic>> loadPassosConfig() async {
    return loadConfig('Passos');
  }

  static Future<Map<String, dynamic>> loadNevesConfig() async {
    return loadConfig('RibeiraoDasNeves');
  }

  static Future<Map<String, dynamic>> loadIgarapeConfig() async {
    return loadConfig('Igarape');
  }

  static Future<Map<String, dynamic>> loadOuroPretoConfig() async {
    return loadConfig('OuroPreto');
  }
}

/// Vehicle types enum
class VehicleTypes {
  static const Map<int, String> types = {
    1: 'Carro',
    2: 'Moto',
    3: 'Caminhão',
    4: 'Motofrete C/D',
    5: 'Carga e Descarga',
  };
}

/// Product definitions
class Products {
  static const Map<String, Map<String, dynamic>> products = {
    '1': {
      'description': 'ROTATIVO',
      'price': 4.4,
      'vehicleType': 1,
    },
    '2': {
      'description': 'BONUS',
      'price': 0,
      'vehicleType': 1,
    },
    '3': {'description': 'GRATUITO', 'price': 0},
    '4': {'description': 'SEM BÔNUS', 'price': 4.4},
    '5': {'description': 'ZONA AZUL', 'price': 1.5, 'vehicleType': 1},
    '6': {'description': 'CREDITOS', 'price': 0.0, 'vehicleType': 1},
    '7': {'description': 'ROTATIVO', 'price': 2.0, 'vehicleType': 1},
    '8': {'description': 'ROTATIVO', 'price': 1.0, 'vehicleType': 2},
    '10': {'description': 'MOTOFRETE C/D', 'price': 0, 'vehicleType': 4},
    '11': {'description': 'CARGA E DESCARGA', 'price': 0, 'vehicleType': 5},
    '12': {'description': 'ROTATIVO', 'price': 1.5, 'vehicleType': 1},
    '13': {'description': 'ROTATIVO', 'price': 0.5},
    '14': {'description': 'ROTATIVO', 'price': 1.75, 'vehicleType': 1},
    '15': {'description': 'ROTATIVO', 'price': 2.5, 'vehicleType': 1},
    '16': {'description': 'ROTATIVO', 'price': 1.0, 'vehicleType': 1},
  };
}