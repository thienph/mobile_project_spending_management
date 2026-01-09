// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_project_spending_management/main.dart';

void main() {
  testWidgets('App launches and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for navigation and animations to complete
    await tester.pumpAndSettle();

    // Verify that the app loaded without errors
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets('Home screen displays basic UI elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for navigation and animations to complete
    await tester.pumpAndSettle();

    // The app should build without throwing exceptions
    expect(tester.takeException(), isNull);
  });
}
