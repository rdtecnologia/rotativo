import 'package:flutter_test/flutter_test.dart';
import 'package:rotativo/models/vehicle_models.dart';

void main() {
  group('Vehicle Auto Search Tests', () {
    test('VehicleModelInfo should parse JSON correctly', () {
      final json = {
        'model': 'HONDA CIVIC',
        'color': 'PRATA',
        'manufactureYear': '2020',
        'modelYear': '2021',
      };

      final vehicleInfo = VehicleModelInfo.fromJson(json);

      expect(vehicleInfo.model, 'HONDA CIVIC');
      expect(vehicleInfo.color, 'PRATA');
      expect(vehicleInfo.manufactureYear, '2020');
      expect(vehicleInfo.modelYear, '2021');
    });

    test('VehicleModelInfo should handle missing fields', () {
      final json = {
        'model': 'TOYOTA COROLLA',
        // color and year fields are missing
      };

      final vehicleInfo = VehicleModelInfo.fromJson(json);

      expect(vehicleInfo.model, 'TOYOTA COROLLA');
      expect(vehicleInfo.color, null);
      expect(vehicleInfo.manufactureYear, null);
      expect(vehicleInfo.modelYear, null);
    });

    test('VehicleModelInfo should convert to JSON correctly', () {
      final vehicleInfo = VehicleModelInfo(
        model: 'VOLKSWAGEN GOLF',
        color: 'BRANCO',
        manufactureYear: '2019',
        modelYear: '2020',
      );

      final json = vehicleInfo.toJson();

      expect(json['model'], 'VOLKSWAGEN GOLF');
      expect(json['color'], 'BRANCO');
      expect(json['manufactureYear'], '2019');
      expect(json['modelYear'], '2020');
    });

    test('VehicleModelInfo copyWith should work correctly', () {
      final original = VehicleModelInfo(
        model: 'FORD FOCUS',
        color: 'AZUL',
        manufactureYear: '2018',
        modelYear: '2019',
      );

      final updated = original.copyWith(
        color: 'VERMELHO',
        modelYear: '2020',
      );

      expect(updated.model, 'FORD FOCUS'); // unchanged
      expect(updated.color, 'VERMELHO'); // changed
      expect(updated.manufactureYear, '2018'); // unchanged
      expect(updated.modelYear, '2020'); // changed
    });

    test('VehicleModelInfo should handle empty JSON', () {
      final json = <String, dynamic>{};

      final vehicleInfo = VehicleModelInfo.fromJson(json);

      expect(vehicleInfo.model, null);
      expect(vehicleInfo.color, null);
      expect(vehicleInfo.manufactureYear, null);
      expect(vehicleInfo.modelYear, null);
    });
  });
}
