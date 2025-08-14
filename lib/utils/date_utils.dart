/// Utilitários para manipulação de datas com timezone UTC
class DateUtils {
  /// Converte uma data UTC para o timezone local do Brasil (UTC-3)
  static DateTime parseUtcDate(String? dateString, {DateTime? fallback}) {
    if (dateString == null || dateString.isEmpty) {
      return fallback ?? DateTime.now().toUtc();
    }
    try {
      DateTime utcDate;
      if (dateString.endsWith('Z')) {
        // Data já está em UTC, apenas parse
        utcDate = DateTime.parse(dateString);
      } else {
        // Assumir que é local e converter para UTC
        utcDate = DateTime.parse(dateString).toUtc();
      }
      
      // Converter UTC para timezone local do Brasil
      return utcDate.toLocal();
    } catch (e) {
      return fallback ?? DateTime.now().toUtc();
    }
  }

  static DateTime parseUtcDateWithFallback(String? dateString, DateTime fallback) {
    return parseUtcDate(dateString, fallback: fallback);
  }

  /// Converte uma data local para UTC
  static DateTime localToUtc(DateTime localDateTime) {
    return localDateTime.toUtc();
  }

  /// Converte uma data UTC para local
  static DateTime utcToLocal(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Verifica se uma string de data termina com Z (UTC)
  static bool isUtcDate(String dateString) {
    return dateString.endsWith('Z');
  }

  /// Converte uma data para string ISO 8601 em UTC
  static String toUtcIso8601(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Converte uma data para string ISO 8601 no timezone local
  static String toLocalIso8601(DateTime dateTime) {
    return dateTime.toLocal().toIso8601String();
  }

  /// Obtém o offset do timezone local em relação ao UTC
  static Duration getLocalTimezoneOffset() {
    return DateTime.now().timeZoneOffset;
  }

  /// Converte uma data UTC para o timezone específico do Brasil (UTC-3)
  static DateTime utcToBrazilTime(DateTime utcDateTime) {
    // Brasil está em UTC-3 (horário de Brasília)
    return utcDateTime.subtract(const Duration(hours: 3));
  }

  /// Converte uma data do timezone do Brasil para UTC
  static DateTime brazilTimeToUtc(DateTime brazilDateTime) {
    // Brasil está em UTC-3 (horário de Brasília)
    return brazilDateTime.add(const Duration(hours: 3));
  }
}
