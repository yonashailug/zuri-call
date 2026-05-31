import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/app.dart';

void main() {
  testWidgets('renders Zuri welcome screen', (tester) async {
    await tester.pumpWidget(const ZuriApp());

    expect(find.text('Zuri'), findsOneWidget);
    expect(find.text('Continue with phone'), findsOneWidget);
  });
}
