import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/dynamic_app_config.dart';
import '../config/environment.dart';
import '../models/vehicle_models.dart';
import '../utils/logger.dart';
import 'auth_service.dart';

class BalanceService {
  static Future<Dio> _getDio() async {
    // Always get the current environment URL to ensure it's up to date
    final baseUrl = Environment.transacionaApi;

    // Create new Dio instance each time to ensure environment changes are applied
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept-Version': '1.0.0',
        'Content-Type': 'application/json',
      },
    ));

    // Add Domain header
    dio.interceptors.add(InterceptorsWrapper(
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
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));
    }

    return dio;
  }

  /// Get user balance
  static Future<Balance> getBalance() async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/ticket/balance');

      if (response.statusCode == 200) {
        final data = response.data;
        if (kDebugMode) {
          AppLogger.balance('Raw API response: $data');
        }

        if (data != null && data is List) {
          // API returns array of balance items, we need to calculate totals
          final items = data;
          double totalCredits = 0;
          double totalRealValue = 0;

          if (kDebugMode) {
            AppLogger.balance('Processing ${items.length} items');
          }

          for (final item in items) {
            if (item is Map<String, dynamic>) {
              final quantity = (item['quantity'] ?? 0) as int;
              final product = item['product'] as Map<String, dynamic>?;
              final price = (product?['price'] ?? 0) as num;

              if (kDebugMode) {
                AppLogger.balance('Item: quantity=$quantity, price=$price');
              }

              totalCredits += quantity;
              totalRealValue += quantity * price;
            }
          }

          if (kDebugMode) {
            AppLogger.balance(
                'Calculated totals: credits=$totalCredits, realValue=$totalRealValue');
          }

          final balance = Balance(
            credits: totalCredits,
            realValue: totalRealValue,
            items: items.map((item) => BalanceItem.fromJson(item)).toList(),
          );

          if (kDebugMode) {
            AppLogger.balance(
                'Created Balance object: ${balance.credits} credits, ${balance.realValue} real');
          }

          return balance;
        }
        return const Balance(credits: 0, realValue: 0, items: []);
      } else {
        throw Exception('Erro ao buscar saldo: ${response.statusMessage}');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
      }
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
        throw Exception(
            'Erro ao buscar detalhes do saldo: ${response.statusMessage}');
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
              .toList() ??
          [],
      vehicles: (json['vehicles'] as List<dynamic>?)
              ?.map((item) => Vehicle.fromJson(item))
              .toList() ??
          [],
    );
  }
}
