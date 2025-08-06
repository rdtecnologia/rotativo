import 'package:dio/dio.dart';
import '../models/history_models.dart';
import '../config/environment.dart';
import 'auth_service.dart';

class HistoryService {
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

    // Add auth interceptor
    _dio!.interceptors.add(await AuthService.createAuthInterceptor());

    return _dio!;
  }

  static Future<Map<String, dynamic>> _getApiConfig() async {
    final env = Environment.flavor;
    
    return {
      'transaciona': env == 'prod'
          ? 'https://transaciona.timob.com.br'
          : 'https://transacionah.timob.com.br',
    };
  }

  /// Get order history with pagination and filters
  static Future<List<OrderHistory>> getOrders({
    int offset = 0,
    int limit = 20,
    HistoryFilter? filters,
  }) async {
    try {
      final dio = await _getDio();
      
      String url = '/history/orders/$offset/$limit';
      
      // Add filters as query parameters
      if (filters != null) {
        final filterMap = filters.toJson();
        if (filterMap.isNotEmpty) {
          final queryParams = filterMap.entries
              .map((e) => 'filters[${e.key}]=${e.value}')
              .join('&');
          url += '?$queryParams';
        }
      }

      final response = await dio.get(url);
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => OrderHistory.fromJson(json))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw Exception('Erro ao buscar histórico de compras: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar histórico: $e');
    }
  }

  /// Get activation history with pagination and filters
  static Future<List<ActivationHistory>> getActivations({
    int offset = 0,
    int limit = 20,
    HistoryFilter? filters,
  }) async {
    try {
      final dio = await _getDio();
      
      String url = '/history/activations/$offset/$limit';
      
      // Add filters as query parameters
      if (filters != null) {
        final filterMap = filters.toJson();
        if (filterMap.isNotEmpty) {
          final queryParams = filterMap.entries
              .map((e) => 'filters[${e.key}]=${e.value}')
              .join('&');
          url += '?$queryParams';
        }
      }

      final response = await dio.get(url);
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => ActivationHistory.fromJson(json))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw Exception('Erro ao buscar histórico de ativações: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar ativações: $e');
    }
  }

  /// Get specific order details
  static Future<OrderHistory?> getOrderDetails(String orderId) async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/order/$orderId');

      return OrderHistory.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Erro ao buscar detalhes da compra: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar detalhes: $e');
    }
  }

  /// Get specific activation details
  static Future<ActivationHistory?> getActivationDetails(String activationId) async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/activation/$activationId');

      return ActivationHistory.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Erro ao buscar detalhes da ativação: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar detalhes: $e');
    }
  }

  /// Delete an order
  static Future<bool> deleteOrder(String orderId, String value) async {
    try {
      final dio = await _getDio();
      await dio.delete('/order/$orderId?value=$value');

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Compra não encontrada');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Não é possível cancelar esta compra');
      }
      throw Exception('Erro ao cancelar compra: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao cancelar: $e');
    }
  }
}