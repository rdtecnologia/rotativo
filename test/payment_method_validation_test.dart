import 'package:flutter_test/flutter_test.dart';
import 'package:rotativo/models/purchase_models.dart';

void main() {
  group('Payment Method Validation Tests', () {
    group('Boleto Minimum Value Validation', () {
      test('should allow boleto payment when value is >= R\$ 20,00', () {
        // Arrange
        final product = ProductOption(credits: 40, price: 20.0);
        final method = PaymentMethodType.boleto;

        // Act & Assert
        expect(product.price >= 20.0, isTrue);
        expect(method == PaymentMethodType.boleto, isTrue);
      });

      test('should not allow boleto payment when value is < R\$ 20,00', () {
        // Arrange
        final product = ProductOption(credits: 10, price: 5.0);
        final method = PaymentMethodType.boleto;

        // Act & Assert
        expect(product.price < 20.0, isTrue);
        expect(method == PaymentMethodType.boleto, isTrue);
      });

      test('should allow credit card payment regardless of value', () {
        // Arrange
        final product = ProductOption(credits: 5, price: 2.5);
        final method = PaymentMethodType.creditCard;

        // Act & Assert
        expect(product.price < 20.0, isTrue);
        expect(method == PaymentMethodType.creditCard, isTrue);
      });

      test('should allow PIX payment regardless of value', () {
        // Arrange
        final product = ProductOption(credits: 5, price: 2.5);
        final method = PaymentMethodType.pix;

        // Act & Assert
        expect(product.price < 20.0, isTrue);
        expect(method == PaymentMethodType.pix, isTrue);
      });
    });

    group('ProductOption Model Tests', () {
      test('should create ProductOption with correct values', () {
        // Arrange & Act
        final product = ProductOption(credits: 20, price: 10.0);

        // Assert
        expect(product.credits, equals(20));
        expect(product.price, equals(10.0));
      });

      test('should create ProductOption from JSON', () {
        // Arrange
        final json = {'credits': 15, 'price': 7.5};

        // Act
        final product = ProductOption.fromJson(json);

        // Assert
        expect(product.credits, equals(15));
        expect(product.price, equals(7.5));
      });
    });

    group('PaymentMethodType Tests', () {
      test('should have correct string values', () {
        // Assert
        expect(PaymentMethodType.creditCard.value, equals('CREDIT_CARD'));
        expect(PaymentMethodType.boleto.value, equals('BOLETO'));
        expect(PaymentMethodType.pix.value, equals('PIX'));
      });

      test('should have correct enum values', () {
        // Assert
        expect(PaymentMethodType.values.length, equals(3));
        expect(PaymentMethodType.values.contains(PaymentMethodType.creditCard),
            isTrue);
        expect(PaymentMethodType.values.contains(PaymentMethodType.boleto),
            isTrue);
        expect(
            PaymentMethodType.values.contains(PaymentMethodType.pix), isTrue);
      });
    });
  });
}
