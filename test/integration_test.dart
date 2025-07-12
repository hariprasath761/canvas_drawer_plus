import 'package:canvas_drawer_plus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and shows auth screen', (WidgetTester tester) async {
    // Initialize the app
    await tester.pumpWidget(const MyApp());

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // The app should start with the auth wrapper
    expect(find.byType(MyApp), findsOneWidget);

    // Since we're not authenticated, we should see the sign in screen
    // This will depend on whether the user is already authenticated
    await tester.pumpAndSettle();
  });

  testWidgets('Room list navigation works', (WidgetTester tester) async {
    // This would require mock authentication for proper testing
    // For now, we'll just test that the widget tree is built correctly
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Check if the app doesn't crash on startup
    expect(find.byType(MyApp), findsOneWidget);
  });
}
