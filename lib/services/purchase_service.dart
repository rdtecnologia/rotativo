import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/purchase_models.dart';
import '../config/dynamic_app_config.dart';
import '../config/environment.dart';
import 'auth_service.dart';

class PurchaseService {
  static Dio? _dio;
  
  static void _clearDioInstance() {
    _dio = null;
  }

  static Future<Dio> _getDio() async {
    if (_dio != null) return _dio!;

    final baseUrl = Environment.transacionaApi;
    
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

      print('🛒 PurchaseService - Using TRANSACIONA API: $baseUrl');

      // Add response interceptor for detailed debugging
      _dio!.interceptors.add(InterceptorsWrapper(
        onResponse: (response, handler) {
          print('🌐 PurchaseService Response - Status: ${response.statusCode}');
          print('🌐 PurchaseService Response - URL: ${response.requestOptions.uri}');
          print('🌐 PurchaseService Response - Headers: ${response.headers}');
          print('🌐 PurchaseService Response - Data Type: ${response.data.runtimeType}');
          print('🌐 PurchaseService Response - Raw Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('🚨 PurchaseService Error - ${error.message}');
          print('🚨 PurchaseService Error - Response: ${error.response?.data}');
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
          print('🔐 PurchaseService - Added token to request: ${token?.substring(0, 20)}...');
          print('🔐 PurchaseService - Domain: $domain');
          print('🔐 PurchaseService - Request URL: ${options.baseUrl}${options.path}');
          print('🔐 PurchaseService - Request Method: ${options.method}');
          print('🔐 PurchaseService - All Headers: ${options.headers}');
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
        print('🛒 PurchaseService.createOrder - Order: ${order.toJson()}');
      }

      final dio = await _getDio();
      
      final response = await dio.post('/order', data: order.toJson());

      if (kDebugMode) {
        print('🛒 PurchaseService.createOrder - Response type: ${response.data.runtimeType}');
        print('🛒 PurchaseService.createOrder - Response data: ${response.data}');
        print('🛒 PurchaseService.createOrder - Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        final orderResponse = OrderResponse.fromJson(response.data as Map<String, dynamic>);
        
        if (kDebugMode) {
          print('🛒 PurchaseService.createOrder - Created order: ${orderResponse.id}');
        }
        
        return orderResponse;
      }

      throw Exception('Resposta da API inválida para criação de pedido');
    } catch (e) {
      if (kDebugMode) {
        print('🛒 PurchaseService.createOrder - Error: $e');
      }
      throw Exception('Erro ao criar pedido: $e');
    }
  }

  /// Load city configuration for purchase
  static Future<PurchaseConfig> loadCityConfig() async {
    try {
      final purchaseConfigJson = await DynamicAppConfig.purchase;
      
      if (kDebugMode) {
        print('🏙️ PurchaseService.loadCityConfig - Config loaded');
        print('🏙️ PurchaseService.loadCityConfig - Purchase config: $purchaseConfigJson');
      }

      return PurchaseConfig.fromJson(purchaseConfigJson);
    } catch (e) {
      if (kDebugMode) {
        print('🏙️ PurchaseService.loadCityConfig - Error: $e');
      }
      throw Exception('Erro ao carregar configuração da cidade: $e');
    }
  }

  /// Load parking rules for displaying pricing information
  static Future<Map<String, List<ParkingRule>>> loadParkingRules() async {
    try {
      final parkingRulesJson = await DynamicAppConfig.parkingRules;
      final parkingRules = <String, List<ParkingRule>>{};

      for (final entry in parkingRulesJson.entries) {
        final rulesList = (entry.value as List<dynamic>? ?? [])
            .map((rule) => ParkingRule.fromJson(rule as Map<String, dynamic>))
            .toList();
        parkingRules[entry.key] = rulesList;
      }

      if (kDebugMode) {
        print('🅿️ PurchaseService.loadParkingRules - Rules loaded: ${parkingRules.keys}');
      }

      return parkingRules;
    } catch (e) {
      if (kDebugMode) {
        print('🅿️ PurchaseService.loadParkingRules - Error: $e');
      }
      throw Exception('Erro ao carregar regras de estacionamento: $e');
    }
  }

  /// Get available vehicle types from city config
  static Future<List<int>> getAvailableVehicleTypes() async {
    try {
      final vehicleTypes = await DynamicAppConfig.vehicleTypes;

      if (kDebugMode) {
        print('🚗 PurchaseService.getAvailableVehicleTypes - Types: $vehicleTypes');
      }

      return vehicleTypes;
    } catch (e) {
      if (kDebugMode) {
        print('🚗 PurchaseService.getAvailableVehicleTypes - Error: $e');
      }
      throw Exception('Erro ao carregar tipos de veículos: $e');
    }
  }
}
