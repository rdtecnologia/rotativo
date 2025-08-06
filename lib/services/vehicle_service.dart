import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/dynamic_app_config.dart';
import '../models/vehicle_models.dart';
import 'auth_service.dart';

class VehicleService {
  static Dio? _dio;

  static Future<Dio> _getDio() async {
    if (_dio != null) return _dio!;

    final config = await _getApiConfig();
    
    _dio = Dio(BaseOptions(
      baseUrl: config['register']!,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept-Version': '1.0.0',
        'Content-Type': 'application/json',
      },
    ));

    // Add Domain header
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final domain = await DynamicAppConfig.domain;
        options.headers['Domain'] = domain;
        
        // Add auth token if available
        final token = await AuthService.getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Jwt $token';
        }
        
        handler.next(options);
      },
    ));

    // Add logging only in debug mode
    if (kDebugMode) {
      _dio!.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));
    }

    return _dio!;
  }

  static Future<Map<String, String>> _getApiConfig() async {
    // TODO: Get from environment configuration
    // For now, using hardcoded values based on React app
    return {
      'register': 'https://cadastra.timob.com.br',
      'transaciona': 'https://autentica.timob.com.br',
    };
  }

  /// Get user vehicles
  static Future<List<Vehicle>> getVehicles() async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/driver/vehicle');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['driver'] != null && data['driver']['vehicles'] != null) {
          final vehiclesList = data['driver']['vehicles'] as List;
          return vehiclesList.map((json) => Vehicle.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Erro ao buscar veículos: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar veículos: $e');
    }
  }

  /// Create a new vehicle
  static Future<Vehicle> createVehicle(VehicleCreateRequest request) async {
    try {
      final dio = await _getDio();
      final response = await dio.post('/driver/vehicle', data: request.toJson());
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Vehicle.fromJson(response.data);
      } else {
        throw Exception('Erro ao cadastrar veículo: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao cadastrar veículo: $e');
    }
  }

  /// Update a vehicle
  static Future<Vehicle> updateVehicle(String licensePlate, VehicleUpdateRequest request) async {
    try {
      final dio = await _getDio();
      final response = await dio.put('/driver/vehicle/$licensePlate', data: request.toJson());
      
      if (response.statusCode == 200) {
        return Vehicle.fromJson(response.data);
      } else {
        throw Exception('Erro ao atualizar veículo: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar veículo: $e');
    }
  }

  /// Delete a vehicle
  static Future<void> deleteVehicle(String licensePlate) async {
    try {
      final dio = await _getDio();
      final response = await dio.delete('/driver/vehicle/$licensePlate');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao excluir veículo: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir veículo: $e');
    }
  }
}

class VehicleCreateRequest {
  final String licensePlate;
  final String? model;
  final String? brand;
  final String? color;
  final int? year;

  const VehicleCreateRequest({
    required this.licensePlate,
    this.model,
    this.brand,
    this.color,
    this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'licensePlate': licensePlate,
      'model': model,
      'brand': brand,
      'color': color,
      'year': year,
    };
  }
}

class VehicleUpdateRequest {
  final String? model;
  final String? brand;
  final String? color;
  final int? year;

  const VehicleUpdateRequest({
    this.model,
    this.brand,
    this.color,
    this.year,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (model != null) json['model'] = model;
    if (brand != null) json['brand'] = brand;
    if (color != null) json['color'] = color;
    if (year != null) json['year'] = year;
    return json;
  }
}