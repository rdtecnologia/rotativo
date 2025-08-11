import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/history_models.dart';
import '../config/environment.dart';
import 'auth_service.dart';

class HistoryService {
  static Dio? _dio;
  
  /// Force recreate Dio instance (for fixing API URL)
  static void _clearDioInstance() {
    _dio = null;
  }

  static Future<Dio> _getDio() async {
    if (_dio != null) return _dio!;

    final baseUrl = _getTransacionaUrl();
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept-Version': '1.0.0',
        'Content-Type': 'application/json',
      },
    ));

    // Add logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio!.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: false,
        maxWidth: 90,
      ));
      
      print('🌐 HistoryService - Using TRANSACIONA API: $baseUrl');
    }

    // Add auth interceptor
    _dio!.interceptors.add(await AuthService.createAuthInterceptor());

    // Add response interceptor to debug API responses
    if (kDebugMode) {
      _dio!.interceptors.add(InterceptorsWrapper(
        onResponse: (response, handler) {
          print('🌐 HistoryService Response - Status: ${response.statusCode}');
          print('🌐 HistoryService Response - URL: ${response.requestOptions.uri}');
          print('🌐 HistoryService Response - Headers: ${response.headers}');
          print('🌐 HistoryService Response - Data Type: ${response.data.runtimeType}');
          print('🌐 HistoryService Response - Data Length: ${response.data is List ? (response.data as List).length : 'N/A'}');
          print('🌐 HistoryService Response - Raw Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('🚨 HistoryService Error - ${error.message}');
          print('🚨 HistoryService Error - Response: ${error.response?.data}');
          handler.next(error);
        },
      ));
    }

    return _dio!;
  }

  static String _getTransacionaUrl() {
    final url = Environment.transacionaApi;
    
    if (kDebugMode) {
      print('🌐 HistoryService - Environment: ${Environment.currentEnvironment}');
      print('🌐 HistoryService - Transaciona URL: $url');
      Environment.printCurrentConfig();
    }
    
    return url;
  }



  /// Get order history with pagination and filters
  static Future<List<OrderHistory>> getOrders({
    int offset = 0,
    int limit = 100, // Match React Native default
    Map<String, dynamic>? filters, // Match React Native signature
  }) async {
    try {
      // Force clear cached Dio to use new PROD URL
      _clearDioInstance();
      
      if (kDebugMode) {
        print('🛒 HistoryService.getOrders - offset: $offset, limit: $limit');
      }
      
      final dio = await _getDio();
      
      String url = '/history/orders/$offset/$limit';
      
      // Add filters as query parameters (like React Native)
      // React Native always adds "?" even when filters is undefined
      final filterParams = filters != null ? _createFilters('filters', filters) : '';
      url += '?$filterParams';
      
      if (kDebugMode) {
        print('🛒 HistoryService.getOrders - Original filters: $filters');
        print('🛒 HistoryService.getOrders - Filter params: "$filterParams"');
      }

      if (kDebugMode) {
        print('🛒 HistoryService.getOrders - URL: $url');
        print('🛒 HistoryService.getOrders - Base URL: ${dio.options.baseUrl}');
        print('🛒 HistoryService.getOrders - Full URL: ${dio.options.baseUrl}$url');
      }

      final response = await dio.get(url);
      
      if (kDebugMode) {
        print('🛒 HistoryService.getOrders - Response type: ${response.data.runtimeType}');
        print('🛒 HistoryService.getOrders - Response data: ${response.data}');
        print('🛒 HistoryService.getOrders - Response status: ${response.statusCode}');
      }
      
      // Handle different response formats
      dynamic data = response.data;
      List<dynamic>? ordersList;
      
      if (data is List) {
        ordersList = data;
      } else if (data is Map<String, dynamic>) {
        // Check if response is wrapped in an object
        if (data.containsKey('orders')) {
          ordersList = data['orders'] as List<dynamic>?;
        } else if (data.containsKey('data')) {
          var nestedData = data['data'];
          if (nestedData is List) {
            ordersList = nestedData;
          } else if (nestedData is Map && nestedData.containsKey('orders')) {
            ordersList = nestedData['orders'] as List<dynamic>?;
          }
        }
      }
      
      if (ordersList != null) {
        final orders = ordersList
            .map((json) => OrderHistory.fromJson(json as Map<String, dynamic>))
            .toList();
        
        if (kDebugMode) {
          print('🛒 HistoryService.getOrders - Parsed ${orders.length} orders');
        }
        
        return orders;
      }
      
      if (kDebugMode) {
        print('🛒 HistoryService.getOrders - Could not extract orders list from response, returning empty list');
      }
      
      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        print('🛒 HistoryService.getOrders - DioException: ${e.message}');
        print('🛒 HistoryService.getOrders - Response: ${e.response?.data}');
      }
      throw Exception('Erro ao buscar histórico de compras: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('🛒 HistoryService.getOrders - Exception: $e');
      }
      throw Exception('Erro inesperado ao buscar histórico: $e');
    }
  }

  /// Get activation history with pagination and filters
  static Future<List<ActivationHistory>> getActivations({
    int offset = 0,
    int limit = 100, // Match React Native default
    Map<String, dynamic>? filters, // Match React Native signature
  }) async {
    try {
      // Force clear cached Dio to use new PROD URL
      _clearDioInstance();
      
      if (kDebugMode) {
        print('🅿️ HistoryService.getActivations - offset: $offset, limit: $limit');
      }
      
      final dio = await _getDio();
      
      String url = '/history/activations/$offset/$limit';
      
      // Add filters as query parameters (like React Native)
      // React Native always adds "?" even when filters is undefined
      final filterParams = filters != null ? _createFilters('filters', filters) : '';
      url += '?$filterParams';
      
      if (kDebugMode) {
        print('🅿️ HistoryService.getActivations - Original filters: $filters');
        print('🅿️ HistoryService.getActivations - Filter params: "$filterParams"');
      }

      if (kDebugMode) {
        print('🅿️ HistoryService.getActivations - URL: $url');
      }

      final response = await dio.get(url);
      
      if (kDebugMode) {
        print('🅿️ HistoryService.getActivations - Response type: ${response.data.runtimeType}');
        print('🅿️ HistoryService.getActivations - Response data: ${response.data}');
        print('🅿️ HistoryService.getActivations - Response status: ${response.statusCode}');
      }
      
      // Handle different response formats
      dynamic data = response.data;
      List<dynamic>? activationsList;
      
      if (data is List) {
        activationsList = data;
      } else if (data is Map<String, dynamic>) {
        // Check if response is wrapped in an object
        if (data.containsKey('activations')) {
          activationsList = data['activations'] as List<dynamic>?;
        } else if (data.containsKey('data')) {
          var nestedData = data['data'];
          if (nestedData is List) {
            activationsList = nestedData;
          } else if (nestedData is Map && nestedData.containsKey('activations')) {
            activationsList = nestedData['activations'] as List<dynamic>?;
          }
        }
      }
      
      if (activationsList != null) {
        final activations = activationsList
            .map((json) => ActivationHistory.fromJson(json as Map<String, dynamic>))
            .toList();
        
        if (kDebugMode) {
          print('🅿️ HistoryService.getActivations - Parsed ${activations.length} activations');
        }
        
        return activations;
      }
      
      if (kDebugMode) {
        print('🅿️ HistoryService.getActivations - Could not extract activations list from response, returning empty list');
      }
      
      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        print('🅿️ HistoryService.getActivations - DioException: ${e.message}');
        print('🅿️ HistoryService.getActivations - Response: ${e.response?.data}');
      }
      throw Exception('Erro ao buscar histórico de ativações: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('🅿️ HistoryService.getActivations - Exception: $e');
      }
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

  /// Get order details by ID
  static Future<OrderDetail> getOrderDetail(String orderId) async {
    try {
      _clearDioInstance(); // Force clear cached Dio to use new PROD URL
      
      if (kDebugMode) {
        print('📋 HistoryService.getOrderDetail - orderId: $orderId');
      }

      final dio = await _getDio();
      
      String url = '/order/$orderId';
      
      if (kDebugMode) {
        print('📋 HistoryService.getOrderDetail - URL: $url');
        print('📋 HistoryService.getOrderDetail - Base URL: ${dio.options.baseUrl}');
        print('📋 HistoryService.getOrderDetail - Full URL: ${dio.options.baseUrl}$url');
      }

      final response = await dio.get(url);

      if (kDebugMode) {
        print('📋 HistoryService.getOrderDetail - Response type: ${response.data.runtimeType}');
        print('📋 HistoryService.getOrderDetail - Response data: ${response.data}');
        print('📋 HistoryService.getOrderDetail - Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        final orderDetail = OrderDetail.fromJson(response.data as Map<String, dynamic>);
        
        if (kDebugMode) {
          print('📋 HistoryService.getOrderDetail - Parsed order detail: ${orderDetail.id}');
        }
        
        return orderDetail;
      }

      throw Exception('Resposta da API inválida para detalhes do pedido');
    } catch (e) {
      if (kDebugMode) {
        print('📋 HistoryService.getOrderDetail - Error: $e');
      }
      throw Exception('Erro ao carregar detalhes do pedido: $e');
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

  /// Create filter parameters like React Native does
  static String _createFilters(String prefix, Map<String, dynamic> data) {
    return data.entries
        .where((entry) => entry.value != null)
        .map((entry) => '$prefix[${entry.key}]=${entry.value}')
        .join('&');
  }
}