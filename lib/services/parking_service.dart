import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/parking_models.dart';
import '../config/dynamic_app_config.dart';
import '../config/environment.dart';
import 'auth_service.dart';

class ParkingService {
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

      print('🚗 ParkingService - Using TRANSACIONA API: $baseUrl');

      // Add response interceptor for detailed debugging
      _dio!.interceptors.add(InterceptorsWrapper(
        onResponse: (response, handler) {
          print('🌐 ParkingService Response - Status: ${response.statusCode}');
          print('🌐 ParkingService Response - URL: ${response.requestOptions.uri}');
          print('🌐 ParkingService Response - Headers: ${response.headers}');
          print('🌐 ParkingService Response - Data Type: ${response.data.runtimeType}');
          print('🌐 ParkingService Response - Raw Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('🚨 ParkingService Error - ${error.message}');
          print('🚨 ParkingService Error - Response: ${error.response?.data}');
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
          print('🔐 ParkingService - Added token to request: ${token?.substring(0, 20)}...');
          print('🔐 ParkingService - Domain: $domain');
          print('🔐 ParkingService - Request URL: ${options.baseUrl}${options.path}');
          print('🔐 ParkingService - Request Method: ${options.method}');
          print('🔐 ParkingService - All Headers: ${options.headers}');
        }
        
        handler.next(options);
      },
    ));

    return _dio!;
  }

  /// Get possible parking tickets for a license plate
  static Future<PossibleParkingResponse> getPossibleParking({
    required String licensePlate,
    required String quantity,
  }) async {
    try {
      _clearDioInstance(); // Force clear cached Dio to use new PROD URL
      
      if (kDebugMode) {
        print('🚗 ParkingService.getPossibleParking - License: $licensePlate, Quantity: $quantity');
      }

      final dio = await _getDio();
      
      final response = await dio.get(
        '/ticket/activate/$licensePlate',
        queryParameters: {'quantity': quantity},
      );

      if (kDebugMode) {
        print('🚗 ParkingService.getPossibleParking - Response type: ${response.data.runtimeType}');
        print('🚗 ParkingService.getPossibleParking - Response data: ${response.data}');
        print('🚗 ParkingService.getPossibleParking - Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        final parkingResponse = PossibleParkingResponse.fromJson(response.data as Map<String, dynamic>);
        
        if (kDebugMode) {
          print('🚗 ParkingService.getPossibleParking - Parsed ${parkingResponse.tickets.length} tickets');
        }
        
        return parkingResponse;
      }

      throw Exception('Resposta da API inválida para tickets disponíveis');
    } catch (e) {
      if (kDebugMode) {
        print('🚗 ParkingService.getPossibleParking - Error: $e');
      }
      
      // Extract error message from DioException if available
      String errorMessage = 'Erro ao buscar tickets disponíveis';
      
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final apiMessage = errorData['message'] as String?;
        final apiCode = errorData['code'] as String?;
        
        if (apiMessage != null && apiMessage.isNotEmpty) {
          errorMessage = apiMessage;
        } else if (apiCode != null && apiCode.isNotEmpty) {
          errorMessage = 'Erro: $apiCode';
        }
      } else if (e is DioException) {
        errorMessage = 'Erro de conexão: ${e.message}';
      } else {
        errorMessage = 'Erro ao buscar tickets disponíveis: $e';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Activate parking for a vehicle
  static Future<ParkingResponse> activateParking({
    required String licensePlate,
    required List<int> ticketIds,
    required ParkingData parkingData,
  }) async {
    try {
      _clearDioInstance(); // Force clear cached Dio to use new PROD URL
      
      if (kDebugMode) {
        print('🚗 ParkingService.activateParking - License: $licensePlate');
        print('🚗 ParkingService.activateParking - Tickets: $ticketIds');
        print('🚗 ParkingService.activateParking - Data: ${parkingData.toJson()}');
      }

      final dio = await _getDio();
      
      // Create request body with tickets and parking data
      final requestBody = {
        'tickets': ticketIds,
        ...parkingData.toJson(),
      };
      
      final url = '/ticket/activate/$licensePlate';
      
      final response = await dio.post(url, data: requestBody);

      if (kDebugMode) {
        print('🚗 ParkingService.activateParking - Response type: ${response.data.runtimeType}');
        print('🚗 ParkingService.activateParking - Response data: ${response.data}');
        print('🚗 ParkingService.activateParking - Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        // Add parkingTime from request data to response
        final responseData = response.data as Map<String, dynamic>;
        responseData['parkingTime'] = parkingData.parkingTime;
        
        final parkingResponse = ParkingResponse.fromJson(responseData);
        
        if (kDebugMode) {
          print('🚗 ParkingService.activateParking - Activated parking: ${parkingResponse.id}');
        }
        
        return parkingResponse;
      }

      throw Exception('Resposta da API inválida para ativação de estacionamento');
    } catch (e) {
      if (kDebugMode) {
        print('🚗 ParkingService.activateParking - Error: $e');
      }
      
      // Extract error message from DioException if available
      String errorMessage = 'Erro ao ativar estacionamento';
      
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final apiMessage = errorData['message'] as String?;
        final apiCode = errorData['code'] as String?;
        
        if (apiMessage != null && apiMessage.isNotEmpty) {
          errorMessage = apiMessage;
        } else if (apiCode != null && apiCode.isNotEmpty) {
          errorMessage = 'Erro: $apiCode';
        }
      } else if (e is DioException) {
        errorMessage = 'Erro de conexão: ${e.message}';
      } else {
        errorMessage = 'Erro ao ativar estacionamento: $e';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Get activation detail by ID
  static Future<ActivationDetail> getActivationDetail(String activationId) async {
    try {
      _clearDioInstance(); // Force clear cached Dio to use new PROD URL
      
      if (kDebugMode) {
        print('🚗 ParkingService.getActivationDetail - ID: $activationId');
      }

      final dio = await _getDio();
      
      final response = await dio.get('/activation/$activationId');

      if (kDebugMode) {
        print('🚗 ParkingService.getActivationDetail - Response type: ${response.data.runtimeType}');
        print('🚗 ParkingService.getActivationDetail - Response data: ${response.data}');
        print('🚗 ParkingService.getActivationDetail - Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        final activationDetail = ActivationDetail.fromJson(response.data as Map<String, dynamic>);
        
        if (kDebugMode) {
          print('🚗 ParkingService.getActivationDetail - Loaded activation: ${activationDetail.id}');
        }
        
        return activationDetail;
      }

      throw Exception('Resposta da API inválida para detalhes de ativação');
    } catch (e) {
      if (kDebugMode) {
        print('🚗 ParkingService.getActivationDetail - Error: $e');
      }
      
      // Extract error message from DioException if available
      String errorMessage = 'Erro ao buscar detalhes da ativação';
      
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final apiMessage = errorData['message'] as String?;
        final apiCode = errorData['code'] as String?;
        
        if (apiMessage != null && apiMessage.isNotEmpty) {
          errorMessage = apiMessage;
        } else if (apiCode != null && apiCode.isNotEmpty) {
          errorMessage = 'Erro: $apiCode';
        }
      } else if (e is DioException) {
        errorMessage = 'Erro de conexão: ${e.message}';
      } else {
        errorMessage = 'Erro ao buscar detalhes da ativação: $e';
      }
      
      throw Exception(errorMessage);
    }
  }
}
