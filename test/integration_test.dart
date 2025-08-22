import 'package:flutter_test/flutter_test.dart';
import 'package:rotativo/config/environment.dart';
import 'package:rotativo/config/dynamic_app_config.dart';

void main() {
  group('Integration Tests - Environment & Dynamic Config', () {
    test('Environment variables should be loaded correctly', () {
      // Basic checks
      expect(Environment.cityName, isNotEmpty);
      expect(Environment.flavor, isNotEmpty);
      expect(Environment.isConfigured, isTrue);
    });

    test('Flavor to city mapping should be correct', () {
      final mapping = DynamicAppConfig.flavorToCityMapping;

      // Check that our current flavor has a mapping
      final currentFlavor = Environment.flavor;
      expect(mapping.containsKey(currentFlavor), isTrue,
          reason: 'Flavor $currentFlavor should have a city mapping');

      final cityDirectory = mapping[currentFlavor];

      expect(cityDirectory, isNotNull);
      expect(cityDirectory, isNotEmpty);
    });

    test('Debug info should contain correct data', () async {
      final debugInfo = await DynamicAppConfig.getDebugInfo();

      expect(debugInfo['flavor'], Environment.flavor);
      expect(debugInfo['cityName'], Environment.cityName);
      expect(debugInfo['isConfigured'], Environment.isConfigured);
      expect(debugInfo.keys, contains('configuredCityDirectory'));
    });
  });
}
