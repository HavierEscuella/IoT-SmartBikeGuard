import 'package:flutter_test/flutter_test.dart';
import 'package:smart_bike_guard/main.dart';

void main() {
  testWidgets('Smoke test for IoT Bike Guard App', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartBikeGuardApp());

    expect(find.text('IoT Bike Guard'), findsOneWidget);
    expect(find.text('Система готова. Очікування команди...'), findsOneWidget);
  });
}
