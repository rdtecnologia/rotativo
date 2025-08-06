import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/dynamic_app_config.dart';
import '../models/auth_models.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  
  // Environment configuration - default to production
  static String _currentEnvironment = 'prod';
  
  // API endpoints configuration
  static const Map<String, ApiConfig> _apiConfigs = {
    'dev': ApiConfig(
      register: 'https://cadastrah.timob.com.br',
      autentica: 'https://autenticah.timob.com.br',
      transaciona: 'https://transacionah.timob.com.br',
      voucher: 'https://voucherh.timob.com.br',
    ),
    'prod': ApiConfig(
      register: 'https://cadastra.timob.com.br',
      autentica: 'https://autentica.timob.com.br',
      transaciona: 'https://transaciona.timob.com.br',
      voucher: 'https://voucher.timob.com.br',
    ),
  };

  static ApiConfig get _currentApiConfig => _apiConfigs[_currentEnvironment]!;

  static void changeEnvironment(String environment) {
    _currentEnvironment = environment;
  }

  // Create Dio instance for login/register operations
  static Dio _createLoginRegisterDio(String apiType) {
    final config = _currentApiConfig;
    String baseUrl;
    
    switch (apiType) {
      case 'LOGIN':
        baseUrl = config.autentica;
        break;
      case 'REGISTER':
        baseUrl = config.register;
        break;
      case 'TRANSACIONA':
        baseUrl = config.transaciona;
        break;
      case 'VOUCHER':
        baseUrl = config.voucher;
        break;
      default:
        baseUrl = config.register;
    }

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept-Version': '1.0.0',
        'Authorization': 'Jwt eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYjJiIiwid2hvIjoiYXBwLWNvbmR1dG9yLXBhdG9zIiwiaWF0IjoxNTQ3MTUxMDYwLCJleHAiOjQ3MDA3NTEwNjB9.W9eJgLTZD_YBgz9fSX8DbACsfrUbw1gniEU1Rzkc3BI',
      },
    ));

    // Add logging interceptor (only in debug mode)
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: false,
        maxWidth: 90,
      ));
    }

    // Request interceptor to add domain header
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final domain = await DynamicAppConfig.domain;
          options.headers['Domain'] = domain;
        } catch (e) {
          // If we can't get domain, continue without it
        }
        handler.next(options);
      },
    ));

    return dio;
  }

  // Create Dio instance for authenticated requests
  static Dio _createAuthenticatedDio(String apiType) {
    final config = _currentApiConfig;
    String baseUrl;
    
    switch (apiType) {
      case 'REGISTER':
        baseUrl = config.register;
        break;
      case 'TRANSACIONA':
        baseUrl = config.transaciona;
        break;
      case 'VOUCHER':
        baseUrl = config.voucher;
        break;
      default:
        baseUrl = config.register;
    }

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept-Version': '1.0.0',
      },
    ));

    // Add logging interceptor (only in debug mode)
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: false,
        maxWidth: 90,
      ));
    }

    // Request interceptor to add token and domain headers
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await getStoredToken();
          final domain = await DynamicAppConfig.domain;
          
          if (token != null) {
            options.headers['Authorization'] = 'Jwt $token';
          }
          options.headers['Domain'] = domain;
        } catch (e) {
          // Continue without headers if error
        }
        handler.next(options);
      },
    ));

    return dio;
  }

  // Check if CPF exists
  static Future<CheckCPFResponse> checkCPFExists(String cpf) async {
    try {
      final dio = _createLoginRegisterDio('REGISTER');
      final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await dio.get('/driver/check/$cleanCpf');
      
      return CheckCPFResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro ao verificar CPF: $e');
    }
  }

  // Login
  static Future<User> login(String username, String password) async {
    try {
      final dio = _createLoginRegisterDio('LOGIN');
      final cleanUsername = username.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await dio.post(
        '/driver/login',
        queryParameters: {
          'username': cleanUsername,
          'password': password,
        },
      );

      final user = User.fromJson(response.data);
      
      // Store user data and token
      if (user.token != null) {
        await _storeUserData(user);
        await _storeToken(user.token!);
      }
      
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  // Register user
  static Future<User> register(RegisterRequest request) async {
    try {
      final dio = _createLoginRegisterDio('REGISTER');
      
      final response = await dio.post(
        '/driver',
        queryParameters: request.toJson(),
      );

      final user = User.fromJson(response.data);
      
      // Store user data and token
      if (user.token != null) {
        await _storeUserData(user);
        await _storeToken(user.token!);
      }
      
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro ao registrar usuário: $e');
    }
  }

  // Forgot password
  static Future<ForgotPasswordResponse> forgotPassword(String cpf) async {
    try {
      final dio = _createLoginRegisterDio('LOGIN');
      final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
      
      final response = await dio.post('/driver/forgotPassword/$cleanCpf');
      
      return ForgotPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro ao recuperar senha: $e');
    }
  }

  // Get current user data
  static Future<User?> getCurrentUser() async {
    try {
      final dio = _createAuthenticatedDio('REGISTER');
      
      final response = await dio.get('/driver');
      
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expired or invalid, clear stored data
        await logout();
        return null;
      }
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro ao obter dados do usuário: $e');
    }
  }

  // Change password
  static Future<void> changePassword(String newPassword) async {
    try {
      final dio = _createAuthenticatedDio('REGISTER');
      
      await dio.post('/driver/changePassword', data: {
        'password': newPassword,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro ao alterar senha: $e');
    }
  }

  // Logout
  static Future<void> logout() async {
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _tokenKey);
  }

  // Storage methods
  static Future<void> _storeUserData(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  static Future<void> _storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<User?> getStoredUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<String?> getStoredToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  // Error handling
  static String _handleDioError(DioException e) {
    if (e.response?.data != null && e.response!.data['message'] != null) {
      return e.response!.data['message'];
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão esgotado. Verifique sua internet.';
      case DioExceptionType.connectionError:
        return 'Erro de conexão. Verifique sua internet.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'CPF ou senha inválidos.';
        } else if (e.response?.statusCode == 404) {
          return 'Serviço não encontrado.';
        } else if (e.response?.statusCode == 500) {
          return 'Erro interno do servidor.';
        }
        return 'Erro no servidor: ${e.response?.statusCode}';
      default:
        return 'Erro inesperado: ${e.message}';
    }
  }

  // Create auth interceptor for external services
  static Future<InterceptorsWrapper> createAuthInterceptor() async {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add domain header
        final domain = await DynamicAppConfig.domain;
        options.headers['Domain'] = domain;
        
        // Add auth token if available
        final token = await getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Jwt $token';
        }
        
        handler.next(options);
      },
    );
  }
}