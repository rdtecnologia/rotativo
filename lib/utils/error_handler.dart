import 'package:dio/dio.dart';

/// Utility class for handling API errors and extracting meaningful messages
class ErrorHandler {
  /// Extract the most meaningful error message from an exception
  static String getErrorMessage(dynamic error) {
    // Priority 1: Try to get the backend message from DioException response
    if (error is DioException && error.response?.data is Map<String, dynamic>) {
      final responseData = error.response!.data as Map<String, dynamic>;
      
      // Always prioritize the backend message if available
      final backendMessage = responseData['message'] as String?;
      if (backendMessage != null && backendMessage.isNotEmpty) {
        return backendMessage; // Return only the backend message
      }
      
      // If no message, try to get the error code
      final errorCode = responseData['code'] as String?;
      if (errorCode != null && errorCode.isNotEmpty) {
        return 'Erro: $errorCode';
      }
    }
    
    // Priority 2: Handle specific HTTP status codes with user-friendly messages
    if (error is DioException && error.response?.statusCode != null) {
      final statusCode = error.response!.statusCode!;
      switch (statusCode) {
        case 400:
          return 'Dados inválidos. Verifique as informações fornecidas.';
        case 401:
          return 'Não autorizado. Faça login novamente.';
        case 402:
          return 'Pagamento recusado. Verifique os dados do cartão.';
        case 403:
          return 'Acesso negado.';
        case 404:
          return 'Recurso não encontrado.';
        case 422:
          return 'Dados inválidos. Verifique as informações fornecidas.';
        case 500:
          return 'Erro interno do servidor. Tente novamente mais tarde.';
        case 502:
          return 'Serviço temporariamente indisponível.';
        case 503:
          return 'Serviço em manutenção. Tente novamente mais tarde.';
        default:
          return 'Erro de conexão. Tente novamente.';
      }
    }
    
    // Priority 3: If it's a string, return it directly (but clean it)
    if (error is String) {
      return _cleanErrorMessage(error);
    }
    
    // Priority 4: For other types, try to convert to string and clean
    final errorString = error.toString();
    if (errorString.isNotEmpty) {
      return _cleanErrorMessage(errorString);
    }
    
    // Default fallback message
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
  
  /// Clean error messages to remove technical details
  static String _cleanErrorMessage(String errorMessage) {
    // Remove common technical prefixes
    String cleaned = errorMessage;
    
    // Remove DioException technical details
    if (cleaned.contains('DioException')) {
      cleaned = cleaned.replaceAll(RegExp(r'DioException\s*\[[^\]]*\]:\s*'), '');
    }
    
    // Remove status code technical details
    if (cleaned.contains('Status:')) {
      cleaned = cleaned.replaceAll(RegExp(r'Status:\s*\d+\s*'), '');
    }
    
    // Remove "This exception was thrown because..." messages
    if (cleaned.contains('This exception was thrown because')) {
      cleaned = cleaned.replaceAll(RegExp(r'This exception was thrown because[^.]*\.'), '');
    }
    
    // Remove "Read more about status codes" messages
    if (cleaned.contains('Read more about status codes')) {
      cleaned = cleaned.replaceAll(RegExp(r'Read more about status codes[^.]*\.'), '');
    }
    
    // Remove "In order to resolve this exception" messages
    if (cleaned.contains('In order to resolve this exception')) {
      cleaned = cleaned.replaceAll(RegExp(r'In order to resolve this exception[^.]*\.'), '');
    }
    
    // Clean up extra whitespace and newlines
    cleaned = cleaned.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    return cleaned;
  }
  
  /// Check if the error is a payment-related error
  static bool isPaymentError(dynamic error) {
    if (error is DioException && error.response?.statusCode == 402) {
      return true;
    }
    
    if (error is DioException && error.response?.data is Map<String, dynamic>) {
      final responseData = error.response!.data as Map<String, dynamic>;
      final errorCode = responseData['code'] as String?;
      return errorCode == 'PaymentRequired' || errorCode == 'PaymentDeclined';
    }
    
    return false;
  }
  
  /// Get a user-friendly title for the error
  static String getErrorTitle(dynamic error) {
    if (isPaymentError(error)) {
      return 'Pagamento Recusado';
    }
    
    if (error is DioException && error.response?.statusCode == 400) {
      return 'Dados Inválidos';
    }
    
    if (error is DioException && error.response?.statusCode == 401) {
      return 'Não Autorizado';
    }
    
    if (error is DioException && error.response?.statusCode == 404) {
      return 'Não Encontrado';
    }
    
    if (error is DioException && error.response?.statusCode == 500) {
      return 'Erro do Servidor';
    }
    
    return 'Erro';
  }
}
