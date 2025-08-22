import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/dynamic_app_config.dart';

/// Provider para nome da cidade
final cityNameProvider = FutureProvider<String>((ref) async {
  return await DynamicAppConfig.cityName;
});

/// Provider para nome de exibição da cidade
final cityDisplayNameProvider = FutureProvider<String>((ref) async {
  return await DynamicAppConfig.displayName;
});

/// Provider para domínio da cidade
final cityDomainProvider = FutureProvider<String>((ref) async {
  return await DynamicAppConfig.domain;
});

/// Provider para coordenadas da cidade
final cityCoordinatesProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final latitude = await DynamicAppConfig.latitude;
  final longitude = await DynamicAppConfig.longitude;
  return {'latitude': latitude, 'longitude': longitude};
});

/// Provider para produtos disponíveis na cidade
final cityProductsProvider = FutureProvider<List<int>>((ref) async {
  return await DynamicAppConfig.products;
});

/// Provider para tipos de veículos disponíveis na cidade
final cityVehicleTypesProvider = FutureProvider<List<int>>((ref) async {
  return await DynamicAppConfig.vehicleTypes;
});

/// Provider para regras de estacionamento da cidade
final cityParkingRulesProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return await DynamicAppConfig.parkingRules;
});

/// Provider para configuração de saldo da cidade
final cityBalanceConfigProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return await DynamicAppConfig.balance;
});

/// Provider para link de download da cidade
final cityDownloadLinkProvider = FutureProvider<String>((ref) async {
  return await DynamicAppConfig.downloadLink;
});

/// Provider para link dos termos de uso da cidade
final cityTermsLinkProvider = FutureProvider<String?>((ref) async {
  return await DynamicAppConfig.termsLink;
});

/// Provider para WhatsApp da cidade
final cityWhatsAppProvider = FutureProvider<String?>((ref) async {
  return await DynamicAppConfig.whatsapp;
});

/// Provider para URL do chatbot da cidade
final cityChatBotURLProvider = FutureProvider<String?>((ref) async {
  return await DynamicAppConfig.chatBotURL;
});

/// Provider para logo principal da cidade
final cityMainLogoProvider = FutureProvider<String>((ref) async {
  return await DynamicAppConfig.mainLogo;
});

/// Provider para logo do menu da cidade
final cityLogoMenuProvider = FutureProvider<String>((ref) async {
  return await DynamicAppConfig.logoMenu;
});

/// Provider para informações de debug da cidade
final cityDebugInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final cityName = await DynamicAppConfig.cityName;
  final domain = await DynamicAppConfig.domain;

  return {
    'city': cityName,
    'domain': domain,
    'flavor': 'dynamic', // Será determinado pelo ambiente
    'configPath': 'assets/config/cities/$cityName/$cityName.json',
  };
});
