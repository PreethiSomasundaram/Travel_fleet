// Basic widget test for Travel Fleet Management app.

import 'package:flutter_test/flutter_test.dart';

import 'package:travel_fleet/main.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelFleetApp());

    // Verify that the login screen is displayed
    expect(find.text('Travel Fleet'), findsOneWidget);
    expect(find.text('Fleet Management'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
