import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotativo/screens/auth/register_screen.dart';
import 'package:rotativo/providers/register_form_provider.dart';
import 'package:rotativo/providers/auth_provider.dart';

void main() {
  group('RegisterScreen - Terms and Conditions PDF', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should show terms and conditions link',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Verifica se o link dos termos está visível
      expect(find.text('termos e condições'), findsOneWidget);
      expect(find.text('Declaro que li e aceito os'), findsOneWidget);
    });

    testWidgets('should have clickable terms link',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Verifica se o link é clicável
      final termsLink = find.text('termos e condições');
      expect(termsLink, findsOneWidget);

      // Verifica se o GestureDetector está presente
      final gestureDetector = tester.widget<GestureDetector>(
        find.ancestor(
          of: termsLink,
          matching: find.byType(GestureDetector),
        ),
      );
      expect(gestureDetector.onTap, isNotNull);
    });

    testWidgets('should show terms checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Verifica se o checkbox está presente
      expect(find.byType(Checkbox), findsOneWidget);

      // Verifica se o checkbox está inicialmente desmarcado
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('should toggle terms acceptance when checkbox is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Verifica estado inicial
      final initialCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(initialCheckbox.value, false);

      // Toca no checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Verifica se o estado mudou
      final updatedCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(updatedCheckbox.value, true);
    });

    testWidgets(
        'should show validation error when trying to submit without accepting terms',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Tenta submeter o formulário sem aceitar os termos
      final submitButton = find.text('Cadastrar');
      await tester.tap(submitButton);
      await tester.pump();

      // Verifica se a mensagem de erro aparece
      expect(find.text('Você deve aceitar os termos de uso'), findsOneWidget);
    });

    testWidgets('should not show validation error when terms are accepted',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      // Aceita os termos
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Tenta submeter o formulário
      final submitButton = find.text('Cadastrar');
      await tester.tap(submitButton);
      await tester.pump();

      // Verifica se não há mensagem de erro
      expect(find.text('Você deve aceitar os termos de uso'), findsNothing);
    });
  });
}
