import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/config/dynamic_app_config.dart';
import '../lib/config/environment.dart';

void main() {
  group('DynamicAppConfig Tests', () {
    setUpAll(() {
      // Initialize binding
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock the asset loading
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString') {
            final String assetPath = methodCall.arguments;

            // Mock different city configs based on path
            if (assetPath.contains('PatosDeMinas')) {
              return '''
              {
                "city": "Patos de Minas",
                "domain": "Patos de Minas",
                "latitude": -18.5890851,
                "longitude": -46.5181081,
                "downloadLink": "http://www.rotativodigital.com.br/app/?city=patosdeminas",
                "termsLink": "http://www.rotativodigital.com.br/wp-content/uploads/2019/10/termos-de-uso-patos.pdf",
                "androidPackage": "com.rotativodigitalpatos",
                "iosPackage": "com.timob.rotativodigitalpatos",
                "products": [7, 8],
                "vehicleTypes": [1, 2],
                "mainLogo": "",
                "logoMenu": "",
                "balance": {"showBy": "credits", "showDetails": true},
                "parkingRules": {"1": [{"time": 60, "price": 2, "credits": 1}]},
                "purchase": {"vehicleTypeDefault": 1, "showBy": "real"},
                "faq": [{"title": "Test FAQ", "content": "Test content"}]
              }
              ''';
            }

            // Default mock for other cities
            return '''
            {
              "city": "Test City",
              "domain": "Test Domain",
              "latitude": 0.0,
              "longitude": 0.0,
              "downloadLink": "http://test.com",
              "androidPackage": "com.test",
              "iosPackage": "com.test",
              "products": [1],
              "vehicleTypes": [1],
              "mainLogo": "",
              "logoMenu": "",
              "balance": {},
              "parkingRules": {},
              "purchase": {},
              "faq": []
            }
            ''';
          }
          return null;
        },
      );
    });

    tearDown(() {
      // Clear cache between tests
      DynamicAppConfig.clearCache();
    });

    test('should load city name from environment when configured', () async {
      final cityName = await DynamicAppConfig.cityName;

      // Should use environment variable if configured
      if (Environment.isConfigured) {
        expect(cityName, Environment.cityName);
      } else {
        expect(cityName, isNotEmpty);
      }
    });

    test('should load correct display name', () async {
      final displayName = await DynamicAppConfig.displayName;
      expect(displayName, startsWith('Rotativo'));
    });

    test('should load config data correctly', () async {
      final domain = await DynamicAppConfig.domain;
      final latitude = await DynamicAppConfig.latitude;
      final longitude = await DynamicAppConfig.longitude;
      final products = await DynamicAppConfig.products;

      expect(domain, isNotEmpty);
      expect(latitude, isA<double>());
      expect(longitude, isA<double>());
      expect(products, isA<List<int>>());
      expect(products, isNotEmpty);
    });

    test('should provide debug info', () async {
      final debugInfo = await DynamicAppConfig.getDebugInfo();

      expect(debugInfo['flavor'], Environment.flavor);
      expect(debugInfo['cityName'], Environment.cityName);
      expect(debugInfo['isConfigured'], Environment.isConfigured);
      expect(debugInfo.keys, contains('configuredCityDirectory'));
    });
  });
}
