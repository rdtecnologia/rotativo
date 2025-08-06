import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/dynamic_app_config.dart';
import '../models/vehicle_models.dart';
import 'auth_service.dart';

class BalanceService {
  static Dio? _dio;

  static Future<Dio> _getDio() async {
    if (_dio != null) return _dio!;

    final config = await _getApiConfig();
    
    _dio = Dio(BaseOptions(
      baseUrl: config['transaciona']!,
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

  /// Get user balance
  static Future<Balance> getBalance() async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/ticket/balance');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          return Balance.fromJson(data);
        }
        return const Balance(credits: 0, realValue: 0, items: []);
      } else {
        throw Exception('Erro ao buscar saldo: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar saldo: $e');
    }
  }

  /// Get balance details
  static Future<BalanceDetail> getBalanceDetails() async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/ticket/balance/details');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          return BalanceDetail.fromJson(data);
        }
        return const BalanceDetail(balance: [], vehicles: []);
      } else {
        throw Exception('Erro ao buscar detalhes do saldo: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar detalhes do saldo: $e');
    }
  }
}

class BalanceDetail {
  final List<BalanceItem> balance;
  final List<Vehicle> vehicles;

  const BalanceDetail({
    required this.balance,
    required this.vehicles,
  });

  factory BalanceDetail.fromJson(Map<String, dynamic> json) {
    return BalanceDetail(
      balance: (json['balance'] as List<dynamic>?)
          ?.map((item) => BalanceItem.fromJson(item))
          .toList() ?? [],
      vehicles: (json['vehicles'] as List<dynamic>?)
          ?.map((item) => Vehicle.fromJson(item))
          .toList() ?? [],
    );
  }
}