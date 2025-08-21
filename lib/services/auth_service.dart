import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/dynamic_app_config.dart';
import '../config/environment.dart';
import '../models/auth_models.dart';
import '../utils/logger.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _storedCredentialsKey = 'stored_credentials';

  // Environment configuration - default to production
  // Removed: Now using centralized Environment configuration

  // Get API configuration from centralized Environment
  static ApiConfig get _currentApiConfig => Environment.apiConfig;

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
        'Authorization':
            'Jwt eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYjJiIiwid2hvIjoiYXBwLWNvbmR1dG9yLXBhdG9zIiwiaWF0IjoxNTQ3MTUxMDYwLCJleHAiOjQ3MDA3NTEwNjB9.W9eJgLTZD_YBgz9fSX8DbACsfrUbw1gniEU1Rzkc3BI',
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

        // Store credentials for biometric authentication
        await _storeCredentialsForBiometrics(cleanUsername, password);
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
  static Future<void> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final dio = _createAuthenticatedDio('REGISTER');

      await dio.post('/driver/changePassword', data: {
        'password': {
          'old': oldPassword,
          'new': newPassword,
        },
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro ao alterar senha: $e');
    }
  }

  // Storage methods
  static Future<void> _storeUserData(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  static Future<void> _storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Armazena credenciais para autenticação biométrica
  static Future<void> _storeCredentialsForBiometrics(
      String username, String password) async {
    try {
      final credentials = {
        'cpf': username,
        'password': password,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _storage.write(
        key: _storedCredentialsKey,
        value: jsonEncode(credentials),
      );

      // Credenciais armazenadas para biometria
    } catch (e) {
      // Erro ao armazenar credenciais para biometria: $e
      // Não falha o login se não conseguir armazenar credenciais
    }
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

  //Logout - clear stored data
  static Future<void> logout() async {
    try {
      // Clear stored user data
      await _storage.delete(key: _userKey);
      // Clear stored token
      await _storage.delete(key: _tokenKey);

      if (kDebugMode) {
        AppLogger.auth('User logged out successfully - cleared stored data');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error during logout: $e');
      }
      // Even if there's an error, we want to clear the data
      // so the user can't access the app
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _tokenKey);
    }
  }

  /// Habilita autenticação biométrica para o usuário
  static Future<bool> enableBiometricAuth() async {
    try {
      // Verifica se já existem credenciais armazenadas
      final credentials = await getStoredCredentials();
      if (credentials == null) {
        // Se não há credenciais armazenadas, verifica se há usuário logado
        // para tentar restaurar as credenciais
        final user = await getStoredUser();
        if (user != null && user.cpf != null) {
          // Tenta restaurar credenciais do usuário logado
          // Nota: A senha não pode ser restaurada, então o usuário precisará
          // fazer login novamente para reabilitar a biometria
          return false;
        }
        // Nenhuma credencial armazenada para habilitar biometria
        return false;
      }

      // Habilita a biometria
      await _storage.write(
        key: _biometricEnabledKey,
        value: 'true',
      );

      // Biometria habilitada com sucesso
      return true;
    } catch (e) {
      // Erro ao habilitar biometria: $e
      return false;
    }
  }

  /// Desabilita autenticação biométrica
  /// Mantém as credenciais armazenadas para reabilitação futura
  static Future<bool> disableBiometricAuth() async {
    try {
      // Apenas desabilita o uso da biometria
      // NÃO exclui as credenciais armazenadas
      await _storage.write(
        key: _biometricEnabledKey,
        value: 'false',
      );
      return true;
    } catch (e) {
      debugPrint('Erro ao desabilitar biometria: $e');
      return false;
    }
  }

  /// Limpa credenciais biométricas e desabilita biometria
  /// Usado quando a senha é alterada por segurança
  static Future<bool> clearBiometricCredentials() async {
    try {
      // Desabilita a biometria
      await _storage.write(
        key: _biometricEnabledKey,
        value: 'false',
      );

      // Remove as credenciais armazenadas
      await _storage.delete(key: _storedCredentialsKey);

      debugPrint('Credenciais biométricas limpas com sucesso');
      return true;
    } catch (e) {
      debugPrint('Erro ao limpar credenciais biométricas: $e');
      return false;
    }
  }

  /// Verifica se a biometria está habilitada
  static Future<bool> isBiometricEnabled() async {
    // Verificando se biometria está habilitada...
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey);
      // Valor da chave biometric_enabled: $enabled
      final result = enabled == 'true';
      // Biometria habilitada: $result
      return result;
    } catch (e) {
      // Erro ao verificar biometria habilitada: $e
      return false;
    }
  }

  /// Obtém credenciais armazenadas para login biométrico
  static Future<Map<String, dynamic>?> getStoredCredentials() async {
    // Verificando credenciais armazenadas...
    try {
      final credentialsData = await _storage.read(key: _storedCredentialsKey);
      // Dados brutos das credenciais: $credentialsData

      if (credentialsData != null) {
        final credentials = jsonDecode(credentialsData);
        // Credenciais decodificadas: $credentials
        return credentials;
      }

      // Nenhuma credencial armazenada encontrada
      return null;
    } catch (e) {
      // Erro ao obter credenciais armazenadas: $e
      debugPrint('Erro ao obter credenciais armazenadas: $e');
      return null;
    }
  }

  /// Login usando biometria (usa credenciais armazenadas)
  static Future<Map<String, dynamic>?> loginWithBiometrics() async {
    // Iniciando login biométrico...
    try {
      // Obtendo credenciais armazenadas...
      final credentials = await getStoredCredentials();
      if (credentials == null) {
        // Credenciais biométricas não encontradas
        throw Exception('Credenciais biométricas não encontradas');
      }

      // Credenciais obtidas com sucesso
      return credentials;
    } catch (e) {
      // Erro no login biométrico: $e
      rethrow;
    }
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
        try {
          // Add domain header
          final domain = await DynamicAppConfig.domain;
          options.headers['Domain'] = domain;

          // Add auth token if available
          final token = await getStoredToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Jwt $token';

            if (kDebugMode) {
              AppLogger.auth(
                  'Added token to request: ${token.substring(0, 20)}...');
              AppLogger.auth('Domain: $domain');
              AppLogger.auth('Full token: $token');
              AppLogger.auth('Request URL: ${options.baseUrl}${options.path}');
              AppLogger.auth('Request Method: ${options.method}');
              AppLogger.auth('All Headers: ${options.headers}');
            }

            // Add user info to headers if available
            final user = await getCurrentUser();
            if (user != null) {
              options.headers['User-Id'] = user.id;
              options.headers['User-CPF'] = user.cpf;

              if (kDebugMode) {
                AppLogger.auth('Current user: ${user.name} (CPF: ${user.cpf})');
              }
            }
          } else {
            if (kDebugMode) {
              AppLogger.auth('No token available for request');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            AppLogger.error('Error adding auth headers: $e');
          }

          // Continue without auth headers
          handler.next(options);
        }

        handler.next(options);
      },
    );
  }
}
