import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_fleet/main.dart';

void main() {
  testWidgets('App boots with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TravelFleetApp()));

    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
