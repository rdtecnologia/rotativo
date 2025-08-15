import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/dynamic_app_config.dart';
import '../config/environment.dart';
import '../models/purchase_models.dart';
import '../utils/logger.dart';
import 'auth_service.dart';

class PurchaseService {
  static Dio? _dio;
  
  static void _clearDioInstance() {
    _dio = null;
  }

  static Future<Dio> _getDio() async {
    if (_dio != null) return _dio!;

    final baseUrl = Environment.transacionaApi;
    
    AppLogger.purchase('Using TRANSACIONA API: $baseUrl');
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept-Version': '1.0.0',
        'Content-Type': 'application/json',
      },
    ));

    // Add logging in debug mode
    if (kDebugMode) {
      _dio!.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));

      // Add response interceptor for detailed debugging
      _dio!.interceptors.add(InterceptorsWrapper(
        onResponse: (response, handler) {
          AppLogger.api('Response - Status: ${response.statusCode}');
          AppLogger.api('Response - URL: ${response.requestOptions.uri}');
          AppLogger.api('Response - Headers: ${response.headers}');
          AppLogger.api('Response - Data Type: ${response.data.runtimeType}');
          AppLogger.api('Response - Raw Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error('Error - ${error.message}');
          AppLogger.error('Response: ${error.response?.data}');
          handler.next(error);
        },
      ));
    }

    // Add Domain and Authorization headers
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final domain = await DynamicAppConfig.domain;
        options.headers['Domain'] = domain;
        
        // Add auth token if available
        final token = await AuthService.getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Jwt $token';
        }

        if (kDebugMode) {
          AppLogger.auth('Added token to request: ${token?.substring(0, 20)}...');
          AppLogger.auth('Domain: $domain');
          AppLogger.auth('Request URL: ${options.baseUrl}${options.path}');
          AppLogger.auth('Request Method: ${options.method}');
          AppLogger.auth('All Headers: ${options.headers}');
        }
        
        handler.next(options);
      },
    ));

    return _dio!;
  }

  /// Create a new order (purchase)
  static Future<OrderResponse> createOrder(PurchaseOrder order) async {
    try {
      _clearDioInstance(); // Force clear cached Dio to use new PROD URL
      
      if (kDebugMode) {
        AppLogger.purchase('Order: ${order.toJson()}');
      }

      final dio = await _getDio();
      
      final response = await dio.post('/order', data: order.toJson());

      if (kDebugMode) {
        AppLogger.api('Response type: ${response.data.runtimeType}');
        AppLogger.api('Response data: ${response.data}');
        AppLogger.api('Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        final orderResponse = OrderResponse.fromJson(response.data as Map<String, dynamic>);
        
        if (kDebugMode) {
          AppLogger.purchase('Created order: ${orderResponse.id}');
        }
        
        return orderResponse;
      }

      throw Exception('Resposta da API inválida para criação de pedido');
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
      }
      throw Exception('Erro ao criar pedido: $e');
    }
  }

  /// Load city configuration for purchase
  static Future<PurchaseConfig> loadCityConfig() async {
    try {
      final purchaseConfigJson = await DynamicAppConfig.purchase;
      
      if (kDebugMode) {
        AppLogger.purchase('Config loaded');
        AppLogger.purchase('Purchase config: $purchaseConfigJson');
      }

      return PurchaseConfig.fromJson(purchaseConfigJson);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
      }
      throw Exception('Erro ao carregar configuração da cidade: $e');
    }
  }

  /// Load parking rules for the current city
  static Future<Map<String, List<ParkingRule>>> loadParkingRules() async {
    try {
      final rulesJson = await DynamicAppConfig.parkingRules;
      final parkingRules = <String, List<ParkingRule>>{};

      for (final entry in rulesJson.entries) {
        final rulesList = (entry.value as List<dynamic>? ?? [])
            .map((rule) => ParkingRule.fromJson(rule as Map<String, dynamic>))
            .toList();
        parkingRules[entry.key] = rulesList;
      }
      
      if (kDebugMode) {
        AppLogger.purchase('Rules loaded: ${parkingRules.keys}');
      }

      return parkingRules;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
      }
      throw Exception('Erro ao carregar regras de estacionamento: $e');
    }
  }

  /// Get available vehicle types for the current city
  static Future<List<int>> getAvailableVehicleTypes() async {
    try {
      final vehicleTypes = await DynamicAppConfig.vehicleTypes;
      
      if (kDebugMode) {
        AppLogger.purchase('Types: $vehicleTypes');
      }

      return vehicleTypes;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
      }
      throw Exception('Erro ao carregar tipos de veículo: $e');
    }
  }
}
