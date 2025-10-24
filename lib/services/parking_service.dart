import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/parking_models.dart';
import '../config/dynamic_app_config.dart';
import '../config/environment.dart';
import '../utils/logger.dart';
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

      AppLogger.api('Using TRANSACIONA API: $baseUrl');

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
          AppLogger.auth(
              'Added token to request: ${token?.substring(0, 20)}...');
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

  /// Get possible parking tickets for a license plate
  static Future<PossibleParkingResponse> getPossibleParking({
    required String licensePlate,
    required String quantity,
  }) async {
    try {
      _clearDioInstance(); // Force clear cached Dio to use new PROD URL

      if (kDebugMode) {
        AppLogger.parking('License: $licensePlate, Quantity: $quantity');
      }

      final dio = await _getDio();

      final response = await dio.get(
        '/ticket/activate/$licensePlate',
        queryParameters: {'quantity': quantity},
      );

      if (kDebugMode) {
        AppLogger.api('Response type: ${response.data.runtimeType}');
        AppLogger.api('Response data: ${response.data}');
        AppLogger.api('Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        final parkingResponse = PossibleParkingResponse.fromJson(
            response.data as Map<String, dynamic>);

        if (kDebugMode) {
          AppLogger.parking('Parsed ${parkingResponse.tickets.length} tickets');
        }

        return parkingResponse;
      }

      throw Exception('Resposta da API inválida para tickets disponíveis');
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
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
    required int parkingTime,
    required String latitude,
    required String longitude,
    required String device,
  }) async {
    try {
      if (kDebugMode) {
        AppLogger.parking('License: $licensePlate');
        AppLogger.parking('Tickets: $ticketIds');
        AppLogger.parking('ParkingTime: $parkingTime minutos');
        AppLogger.parking('Latitude: $latitude');
        AppLogger.parking('Longitude: $longitude');
        AppLogger.parking('Device: $device');
      }

      final dio = await _getDio();

      // Simplified URL without ticket IDs
      final url = '/ticket/activate/$licensePlate';

      if (kDebugMode) {
        AppLogger.parking('Request URL: $url');
      }

      // Create ParkingData with ticket IDs in body
      final parkingData = ParkingData(
        latitude: latitude,
        longitude: longitude,
        device: device,
        parkingTime: parkingTime,
        tickets: ticketIds,
      );

      if (kDebugMode) {
        AppLogger.parking('Request data: ${parkingData.toJson()}');
      }

      final response = await dio.post(
        url,
        data: parkingData.toJson(),
      );

      if (kDebugMode) {
        AppLogger.api('Response type: ${response.data.runtimeType}');
        AppLogger.api('Response data: ${response.data}');
        AppLogger.api('Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        final parkingResponse =
            ParkingResponse.fromJson(response.data as Map<String, dynamic>);

        if (kDebugMode) {
          AppLogger.parking('Activated parking: ${parkingResponse.id}');
        }

        return parkingResponse;
      }

      throw Exception(
          'Resposta da API inválida para ativação de estacionamento');
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
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
  static Future<ActivationDetail> getActivationDetail(
      String activationId) async {
    try {
      _clearDioInstance(); // Force clear cached Dio to use new PROD URL

      if (kDebugMode) {
        AppLogger.parking('ID: $activationId');
      }

      final dio = await _getDio();

      final response = await dio.get('/activation/$activationId');

      if (kDebugMode) {
        AppLogger.api('Response type: ${response.data.runtimeType}');
        AppLogger.api('Response data: ${response.data}');
        AppLogger.api('Response status: ${response.statusCode}');
      }

      if (response.data is Map<String, dynamic>) {
        final activationDetail =
            ActivationDetail.fromJson(response.data as Map<String, dynamic>);

        if (kDebugMode) {
          AppLogger.parking('Loaded activation: ${activationDetail.id}');
        }

        return activationDetail;
      }

      throw Exception('Resposta da API inválida para detalhes de ativação');
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error: $e');
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
