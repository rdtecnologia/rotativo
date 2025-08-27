import 'package:flutter_test/flutter_test.dart';
import 'package:rotativo/utils/formatters.dart';

void main() {
  group('Plate Validation Tests', () {
    test('should validate old Brazilian plate format (ABC1234)', () {
      expect(AppFormatters.isValidPlateFormat('ABC1234'), true);
      expect(AppFormatters.isValidPlateFormat('XYZ9876'), true);
      expect(AppFormatters.isValidPlateFormat('ABC-1234'), true);
      expect(AppFormatters.isValidPlateFormat('ABC 1234'), true);
    });

    test('should validate Mercosul plate format (ABC1D23)', () {
      expect(AppFormatters.isValidPlateFormat('ABC1D23'), true);
      expect(AppFormatters.isValidPlateFormat('XYZ9A45'), true);
      expect(AppFormatters.isValidPlateFormat('ABC-1D23'), true);
      expect(AppFormatters.isValidPlateFormat('ABC 1D23'), true);
    });

    test(
        'should validate Mercosul plate format with number in fourth position (ABC1234)',
        () {
      expect(AppFormatters.isValidPlateFormat('ABC1234'), true);
      expect(AppFormatters.isValidPlateFormat('XYZ9876'), true);
      expect(AppFormatters.isValidPlateFormat('ABC-1234'), true);
      expect(AppFormatters.isValidPlateFormat('ABC 1234'), true);
    });

    test('should reject invalid plate formats', () {
      expect(AppFormatters.isValidPlateFormat('ABC123'), false); // Too short
      expect(AppFormatters.isValidPlateFormat('ABC12345'), false); // Too long
      expect(
          AppFormatters.isValidPlateFormat('123ABCD'), false); // Wrong pattern
      expect(AppFormatters.isValidPlateFormat('ABC1D2'), false); // Wrong length
      expect(AppFormatters.isValidPlateFormat('ABC1D234'),
          true); // Padrão válido de 8 caracteres
    });

    test('should format plates correctly', () {
      expect(AppFormatters.formatPlate('ABC1234'), 'ABC-1234');
      expect(AppFormatters.formatPlate('XYZ9A45'), 'XYZ-9A45');
      expect(AppFormatters.formatPlate('ABC1D23'), 'ABC-1D23');
    });

    test('should remove plate mask correctly', () {
      expect(AppFormatters.removePlateMask('ABC-1234'), 'ABC1234');
      expect(AppFormatters.removePlateMask('ABC 1234'), 'ABC1234');
      expect(AppFormatters.removePlateMask('ABC-1D23'), 'ABC1D23');
    });
  });
}
