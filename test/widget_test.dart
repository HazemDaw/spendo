import 'package:flutter_test/flutter_test.dart';
import 'package:spendo/main.dart';

void main() {
  testWidgets('app renders home screen shell', (WidgetTester tester) async {
    await tester.pumpWidget(const SpendoApp());
    await tester.pumpAndSettle();

    expect(find.text('Monefy'), findsOneWidget);
  });
}
