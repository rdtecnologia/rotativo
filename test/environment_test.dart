import 'package:flutter_test/flutter_test.dart';
import '../lib/config/environment.dart';

void main() {
  group('Environment Configuration Tests', () {
    test('should have city name from dart-define', () {
      print('City Name: ${Environment.cityName}');
      print('Flavor: ${Environment.flavor}');
      print('Is Configured: ${Environment.isConfigured}');
      print('Display Info: ${Environment.displayInfo}');
      
      expect(Environment.cityName, isNotEmpty);
      expect(Environment.flavor, isNotEmpty);
    });
    
    test('should have valid configuration', () {
      // This test will pass if environment variables are properly set
      expect(Environment.isConfigured, isTrue);
    });
  });
}