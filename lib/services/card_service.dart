import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/card_models.dart';
import '../utils/logger.dart';
import '../config/environment.dart';
import '../config/dynamic_app_config.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class CardService {
  static Future<Dio> _getDio() async {
    final dio = Dio();
    
    // Add base URL and other configurations
    // Use registerApi like React app to get user data including cards
    final baseUrl = Environment.registerApi;
    dio.options.baseUrl = baseUrl;
    
    // Add Domain header and auth token like other services
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
    
    if (kDebugMode) {
      AppLogger.api('Using base URL: $baseUrl');
    }
    
    return dio;
  }

  /// Get all cards for the current user
  static Future<List<CreditCard>> getCards() async {
    try {
      if (kDebugMode) {
        AppLogger.api('Getting cards');
      }

      final dio = await _getDio();
      
      // Use /driver endpoint like React app to get user data including cards
      final response = await dio.get('/driver');

      if (kDebugMode) {
        AppLogger.api('Response type: ${response.data.runtimeType}');
        AppLogger.api('Response data: ${response.data}');
        AppLogger.api('Response status: ${response.statusCode}');
      }

      if (response.data is List) {
        final cards = (response.data as List)
            .map((json) => CreditCard.fromJson(json as Map<String, dynamic>))
            .toList();
        
        if (kDebugMode) {
          AppLogger.api('Parsed ${cards.length} cards');
        }
        
        return cards;
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('cards')) {
          final cardsList = data['cards'] as List;
          final cards = cardsList
              .map((json) => CreditCard.fromJson(json as Map<String, dynamic>))
              .toList();
          
          if (kDebugMode) {
            AppLogger.api('Parsed ${cards.length} cards from data.cards');
          }
          
          return cards;
        }
      }
      
      if (kDebugMode) {
        AppLogger.api('No cards found, returning empty list');
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error getting cards: $e');
      }
      
      String errorMessage = 'Erro ao buscar cartões';
      
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
        errorMessage = 'Erro ao buscar cartões: $e';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Create a new credit card
  static Future<CreditCard?> createCard(CreateCardRequest request) async {
    try {
      AppLogger.cards('Creating new card');
      AppLogger.cards('Creating card with number ending in ${request.number.substring(request.number.length - 4)}');
      
      // Use the same pattern as React app - create order with credit card
      final orderData = {
        'products': [
          {
            'productId': 13, // Default product ID
            'quantity': 1,
            'vehicleType': 1, // Default vehicle type
          }
        ],
        'payment': {
          'gateway': request.gateway,
          'data': {
            'method': 'CREDIT_CARD',
            'creditCard': {
              'number': request.number,
              'expirationMonth': request.expirationMonth,
              'expirationYear': request.expirationYear,
              'cvc': request.cvc,
              'holder': {
                'name': request.holderName,
                'document': request.holderDocument,
                'email': request.holderEmail,
                'mobile': request.holderPhone,
                'birthDate': request.birthDate,
              },
              'store': true,
            }
          }
        }
      };

      final dio = await _getDio();
      final response = await dio.post(
        '/order',
        data: orderData,
        options: Options(
          headers: {
            'Authorization': 'Jwt ${await AuthService.getStoredToken()}',
            'Domain': Environment.transacionaApi.split('/').last,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.cards('Card created successfully');
        // Return a mock card since the API doesn't return card details
        return CreditCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          number: request.number,
          brand: _detectCardBrand(request.number),
          gateway: request.gateway,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Error creating card: $e');
      
      // Use ErrorHandler to get meaningful error message
      final errorMessage = ErrorHandler.getErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  /// Delete a credit card
  static Future<void> deleteCard(String cardId, String gateway) async {
    try {
      if (kDebugMode) {
        AppLogger.api('Deleting card: $cardId from gateway: $gateway');
      }

      final dio = await _getDio();
      
      final response = await dio.delete('/driver/cards/$gateway/$cardId');

      if (kDebugMode) {
        AppLogger.api('Response status: ${response.statusCode}');
        AppLogger.api('Card deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting card: $e');
      }
      
      String errorMessage = 'Erro ao excluir cartão';
      
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
        errorMessage = 'Erro ao excluir cartão: $e';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Get card brands available
  static List<Map<String, String>> getCardBrands() {
    return [
      {'id': 'VISA', 'name': 'Visa', 'icon': 'cc-visa'},
      {'id': 'MASTER', 'name': 'Mastercard', 'icon': 'cc-mastercard'},
      {'id': 'AMEX', 'name': 'American Express', 'icon': 'cc-amex'},
      {'id': 'DINNERS', 'name': 'Diners Club', 'icon': 'cc-diners-club'},
      {'id': 'ELO', 'name': 'Elo', 'icon': 'credit-card'},
      {'id': 'HIPERCARD', 'name': 'Hipercard', 'icon': 'credit-card'},
    ];
  }

  /// Get gateway options
  static List<Map<String, String>> getGateways() {
    return [
      {'id': 'pagSeguro', 'name': 'PagSeguro'}, // Gateway padrão usado no React
      {'id': 'stripe', 'name': 'Stripe'},
      {'id': 'mercadopago', 'name': 'Mercado Pago'},
    ];
  }

  /// Get default gateway (same as React app)
  static String getDefaultGateway() {
    return 'pagSeguro';
  }

  /// Detect card brand based on number
  static String _detectCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    
    if (cleanNumber.startsWith('4')) return 'VISA';
    if (cleanNumber.startsWith('5')) return 'MASTER';
    if (cleanNumber.startsWith('3')) return 'AMEX';
    if (cleanNumber.startsWith('6')) return 'ELO';
    if (cleanNumber.startsWith('35') || cleanNumber.startsWith('36') || cleanNumber.startsWith('38')) return 'DINNERS';
    if (cleanNumber.startsWith('60') || cleanNumber.startsWith('65')) return 'HIPERCARD';
    
    return 'GENERIC';
  }
}
