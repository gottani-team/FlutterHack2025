import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feature/home/presentation/pages/home_page.dart';

void main() {
  testWidgets('HomePage displays welcome message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Wait for async data to load
    await tester.pumpAndSettle();

    // Verify that welcome message is displayed
    expect(find.text('Welcome to Flutter App Template'), findsOneWidget);
    expect(
      find.text('Start building your app from here!'),
      findsOneWidget,
    );
  });
}
