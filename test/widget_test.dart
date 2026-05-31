import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/app.dart';

void main() {
  testWidgets('renders Zuri welcome screen', (tester) async {
    await tester.pumpWidget(const ZuriApp());

    expect(find.text('Zuri'), findsOneWidget);
    expect(find.text('Continue with phone'), findsOneWidget);
  });

  testWidgets('walks through auth onboarding screens', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ZuriApp());

    await tester.tap(find.text('Continue with phone'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your phone number below:'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '6502137552');
    await tester.pumpAndSettle();
    expect(find.text('(650) 213-7552'), findsOneWidget);
    final phoneContinue = find.text('Continue');
    await tester.ensureVisible(phoneContinue);
    await tester.tap(phoneContinue);
    await tester.pumpAndSettle();
    expect(
      find.text("We've sent you a security code. Please type it here:"),
      findsOneWidget,
    );

    await tester.enterText(find.byType(EditableText), '338750');
    await tester.pumpAndSettle();
    final codeContinue = find.text('Continue');
    await tester.ensureVisible(codeContinue);
    await tester.tap(codeContinue);
    await tester.pumpAndSettle();
    expect(
      find.text('Please enter your name to create an account.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(EditableText), 'Alex Johnson');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Search contacts'), findsOneWidget);
  });
}
