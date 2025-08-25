import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rotativo/screens/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('should display logo', (WidgetTester tester) async {
      // Build the splash screen
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Wait for the animation to start
      await tester.pump();

      // Verify that the logo is displayed
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('should navigate to auth after 3 seconds',
        (WidgetTester tester) async {
      // Build the splash screen
      await tester.pumpWidget(MaterialApp(
        home: const SplashScreen(),
        routes: {
          '/auth': (context) => const Scaffold(body: Text('Auth Screen')),
        },
      ));

      // Wait for the full duration of the splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify navigation occurred
      expect(find.text('Auth Screen'), findsOneWidget);
    });
  });
}
