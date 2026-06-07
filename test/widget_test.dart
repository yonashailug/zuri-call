import 'package:flutter/material.dart';

import 'package:zuri_call/app/di/app_dependencies.dart';
import 'package:zuri_call/core/theme/zuri_theme.dart';
import 'package:zuri_call/core/ui/zuri_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/app.dart';
import 'package:zuri_call/features/calling/call_service.dart';
import 'package:zuri_call/features/calling/in_call_screen.dart';
import 'package:zuri_call/features/dialpad/dialpad_screen.dart';
import 'package:zuri_call/features/home/call_history_repository.dart';
import 'package:zuri_call/features/home/call_record.dart';
import 'package:zuri_call/features/home/contact_preview.dart';
import 'package:zuri_call/features/home/device_contacts_repository.dart';
import 'package:zuri_call/features/wallet/wallet_screen.dart';

void main() {
  testWidgets('renders Zuri welcome screen', (tester) async {
    await tester.pumpWidget(
      _testApp(),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Zuri'), findsOneWidget);
    expect(find.text('Continue with phone'), findsOneWidget);
  });

  testWidgets('handles Firebase auth callback routes', (tester) async {
    await tester.pumpWidget(
      _testApp(),
    );
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.text('Zuri'))).pushNamed(
      '/link?deep_link_id=https://zuri-call.firebaseapp.com/__/auth/callback',
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Zuri'), findsOneWidget);
  });

  testWidgets('falls back safely for unknown external routes', (tester) async {
    await tester.pumpWidget(
      _testApp(),
    );
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.text('Zuri'))).pushNamed('/unexpected');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Zuri'), findsOneWidget);
  });

  testWidgets('walks through auth onboarding screens', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _testApp(),
    );
    await tester.pumpAndSettle();

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
    expect(find.text('Search contacts or numbers'), findsOneWidget);
    expect(find.text('Maya Kim'), findsOneWidget);

    await tester.tap(find.byIcon(ZuriIcons.phone).first);
    await tester.pump();
    await tester.pump();
    expect(find.text('Active call'), findsOneWidget);
    expect(find.text('+1 (206) 555-0142'), findsOneWidget);
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('Mute'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('0:01'), findsOneWidget);

    await tester.tap(find.byIcon(ZuriIcons.phoneOff));
    await tester.pump();
    expect(find.text('Call ended'), findsOneWidget);
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('COST'), findsOneWidget);
    expect(find.text('Rate'), findsOneWidget);
    expect(find.text('Wallet balance'), findsOneWidget);
    expect(find.text('Call back'), findsOneWidget);
    expect(find.text('Save contact'), findsNothing);
    expect(find.text('Report call quality'), findsNothing);

    await tester.tap(find.byIcon(ZuriIcons.close));
    await tester.pumpAndSettle();

    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('Just now'), findsOneWidget);
    expect(find.text('1s'), findsNothing);

    await tester.tap(find.text('Maya Kim').first);
    await tester.pumpAndSettle();
    expect(find.text('Call details'), findsNothing);
    expect(find.byIcon(ZuriIcons.back), findsOneWidget);
    expect(find.text('Recents'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('1s'), findsOneWidget);

    await tester.tap(find.byIcon(ZuriIcons.back));
    await tester.pumpAndSettle();
    expect(find.text('Recents'), findsOneWidget);
    expect(find.text('Just now'), findsOneWidget);
    expect(find.text('1s'), findsNothing);

    await tester.tap(find.text('Maya Kim').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call back'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Active call'), findsOneWidget);
    expect(find.text('+1 (206) 555-0142'), findsOneWidget);
  });

  testWidgets('records failed calls from call service', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _testApp(_FakeCallHistoryRepository(), const _FailingCallService()),
    );
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');

    await tester.tap(find.byIcon(ZuriIcons.phone).first);
    await tester.pump();
    await tester.pump();

    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Unable to connect'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('Just now'), findsOneWidget);
    expect(find.text('Failed'), findsNothing);
  });

  testWidgets('deletes recent call from details', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final callHistoryRepository = _FakeCallHistoryRepository(
      initialCalls: [
        CallRecord.fromDialpad(
          number: '+1 (503) 555-0278',
          name: 'Jordan Rivera',
          startedAt: DateTime.now(),
        ),
      ],
    );

    await tester.pumpWidget(_testApp(callHistoryRepository));
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');

    await tester.tap(find.text('Recents'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jordan Rivera'));
    await tester.pumpAndSettle();
    expect(find.text('Call details'), findsNothing);
    expect(find.byIcon(ZuriIcons.back), findsOneWidget);
    expect(find.text('Recents'), findsOneWidget);

    await tester.tap(find.text('Delete from recents'));
    await tester.pumpAndSettle();

    expect(find.text('No calls yet'), findsOneWidget);
    expect(callHistoryRepository.savedCalls, isEmpty);
  });

  testWidgets('swiping left removes a recent call', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final callHistoryRepository = _FakeCallHistoryRepository(
      initialCalls: [
        CallRecord.fromDialpad(
          number: '+1 (503) 555-0278',
          name: 'Jordan Rivera',
          startedAt: DateTime.now(),
        ),
      ],
    );

    await tester.pumpWidget(_testApp(callHistoryRepository));
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');
    await tester.tap(find.text('Recents'));
    await tester.pumpAndSettle();

    expect(find.text('Jordan Rivera'), findsOneWidget);

    await tester.drag(find.text('Jordan Rivera'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Jordan Rivera'), findsNothing);
    expect(find.text('No calls yet'), findsOneWidget);
    expect(callHistoryRepository.savedCalls, isEmpty);
  });

  testWidgets('restores persisted recent calls after sign in', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final callHistoryRepository = _FakeCallHistoryRepository(
      initialCalls: [
        CallRecord.fromDialpad(
          number: '+1 (503) 555-0278',
          name: 'Jordan Rivera',
          startedAt: DateTime.now(),
        ),
      ],
    );

    await tester.pumpWidget(_testApp(callHistoryRepository));
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');

    await tester.tap(find.text('Recents'));
    await tester.pumpAndSettle();

    expect(find.text('Jordan Rivera'), findsOneWidget);
    expect(find.text('Just now'), findsOneWidget);
    expect(find.text('Outgoing'), findsNothing);
    expect(find.byIcon(ZuriIcons.arrowUpRight), findsOneWidget);
  });

  testWidgets('recents shows first-name quick dial and missed call banner', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeCallHistoryRepository(
      initialCalls: [
        CallRecord(
          name: 'Jordan Rivera',
          phone: '+1 (503) 555-0278',
          startedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          direction: CallDirection.missed,
          status: CallStatus.missed,
        ),
        CallRecord(
          name: 'Maya Kim',
          phone: '+1 (206) 555-0142',
          startedAt: DateTime.now().subtract(const Duration(minutes: 18)),
          durationSeconds: 74,
        ),
      ],
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');
    await tester.tap(find.text('Recents'));
    await tester.pumpAndSettle();

    expect(find.text('Jordan'), findsOneWidget);
    expect(find.text('Jordan R.'), findsNothing);
    expect(find.text('1 missed call'), findsOneWidget);
    expect(find.text('Call back'), findsOneWidget);
    expect(find.byIcon(ZuriIcons.arrowDownLeft), findsOneWidget);
    expect(find.byIcon(ZuriIcons.phoneMissed), findsNothing);
  });

  testWidgets('recents call button starts the in-call screen', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final callHistoryRepository = _FakeCallHistoryRepository(
      initialCalls: [
        CallRecord.fromDialpad(
          number: '+1 (503) 555-0278',
          name: 'Jordan Rivera',
          startedAt: DateTime.now(),
        ),
      ],
    );

    await tester.pumpWidget(_testApp(callHistoryRepository));
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');

    await tester.tap(find.text('Recents'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(ZuriIcons.phone));
    await tester.pump();
    await tester.pump();

    expect(find.text('Active call'), findsOneWidget);
    expect(find.text('Jordan Rivera'), findsOneWidget);
    expect(find.text('+1 (503) 555-0278'), findsOneWidget);
  });

  testWidgets('keeps contacts loaded when switching from recents', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');

    expect(find.text('Maya Kim'), findsOneWidget);

    await tester.tap(find.text('Recents'));
    await tester.pumpAndSettle();
    expect(find.text('No calls yet'), findsOneWidget);

    await tester.tap(find.text('Contacts'));
    await tester.pumpAndSettle();
    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('No contacts found'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.height == ZuriDimensions.searchBarHeight &&
            widget.child is TextField,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ZuriCircleButton &&
            widget.icon == ZuriIcons.phone &&
            widget.size == ZuriDimensions.callBackBtnSize &&
            widget.iconSize == 15 &&
            widget.foregroundColor == ZuriColors.forest800 &&
            widget.backgroundColor == ZuriColors.iconButtonBg,
      ),
      findsOneWidget,
    );
  });

  testWidgets('contact row opens details like recent rows', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');

    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('+1 (206) 555-0142'), findsNothing);

    await tester.tap(find.text('Maya Kim'));
    await tester.pumpAndSettle();

    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('+1 (206) 555-0142'), findsOneWidget);
    expect(find.text('Call back'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Copy number'), findsOneWidget);
    expect(find.text('Delete from recents'), findsNothing);

    await tester.tap(find.byIcon(ZuriIcons.back));
    await tester.pumpAndSettle();

    expect(find.text('Your network'), findsOneWidget);
    expect(find.text('Maya Kim'), findsOneWidget);
  });

  testWidgets('shows network-building empty contacts state', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _testApp(
        null,
        const _FakeCallService(),
        _EmptyContactsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await _signIn(tester, displayName: 'Alex Johnson');

    expect(find.text('Your network'), findsOneWidget);
    expect(find.text('Contacts'), findsWidgets);
    expect(find.text('Build your network'), findsOneWidget);
    expect(find.text('Sync phone contacts'), findsOneWidget);
    expect(find.text('Add manually'), findsOneWidget);

    await tester.ensureVisible(find.text('Add manually'));
    await tester.tap(find.text('Add manually'));
    await tester.pumpAndSettle();

    expect(find.text('Dial'), findsNothing);
    expect(find.text('US +1'), findsNothing);
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('\$0.02 / min'), findsOneWidget);
  });

  testWidgets('dialpad formats manual US numbers with selected prefix', (
    tester,
  ) async {
    String? startedNumber;

    await tester.pumpWidget(
      MaterialApp(
        home: DialpadScreen(
          onStartCall: (number) => startedNumber = number,
        ),
      ),
    );

    await tester.tap(find.text('2'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('6'));
    await tester.pumpAndSettle();

    expect(find.text('+1 (206)'), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('4'));
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(find.text('+1 (206) 555-0142'), findsOneWidget);

    await tester.tap(find.text('Call now'));
    await tester.pump();

    expect(startedNumber, '+1 2065550142');
  });

  testWidgets('dialpad clears contact label after editing prefilled number', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DialpadScreen(
          initialNumber: '+1 (206) 555-0142',
          contactName: 'Maya Kim',
          onStartCall: (_) {},
        ),
      ),
    );

    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('+1 (206) 555-0142'), findsOneWidget);

    await tester.tap(find.byIcon(ZuriIcons.backspace));
    await tester.pumpAndSettle();

    expect(find.text('Maya Kim'), findsNothing);
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('+1 (206) 555-014'), findsOneWidget);
  });

  testWidgets('dialpad syncs international prefix with rate context', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DialpadScreen(
          onStartCall: (_) {},
        ),
      ),
    );

    await tester.longPress(find.text('0'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('9'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(find.text('ET +251'), findsNothing);
    expect(find.text('Ethiopia'), findsOneWidget);
    expect(find.text('\$0.22 / min'), findsOneWidget);
    expect(find.text('+251 91 3'), findsOneWidget);
  });

  testWidgets('wallet opens top-up flow with balance preview', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Top up'));
    await tester.pumpAndSettle();

    expect(find.text('Top up wallet'), findsOneWidget);
    expect(find.text('Current balance'), findsOneWidget);
    expect(find.text('~83 min to ET'), findsOneWidget);
    expect(find.text('Most popular'), findsOneWidget);
    expect(find.text('New balance'), findsOneWidget);
    expect(find.text('\$14.88'), findsOneWidget);
    expect(find.text('Pay \$10.00 securely'), findsOneWidget);

    await tester.tap(find.text('\$20'));
    await tester.pumpAndSettle();

    expect(find.text('\$24.88'), findsOneWidget);
    expect(find.text('Pay \$20.00 securely'), findsOneWidget);
  });

  testWidgets('wallet opens full transaction history ledger', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Total spent'), findsOneWidget);
    expect(find.text('\$2.14'), findsOneWidget);
    expect(find.text('Total topped up'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Calls'), findsOneWidget);
    expect(find.text('Top-ups'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('-\$0.12'), findsNWidgets(2));
    expect(find.text('YESTERDAY'), findsOneWidget);
    expect(find.text('+\$4.99'), findsOneWidget);
    expect(find.text('Top-up • Visa •••4242'), findsOneWidget);
    expect(find.text('2:14 PM • Ref #ZW8847'), findsOneWidget);
    expect(find.text('ET'), findsNWidgets(2));
    expect(find.text('US'), findsOneWidget);
    expect(find.textContaining('\$0.02/min'), findsNWidgets(3));
  });

  testWidgets('wallet opens rate lookup with Ethiopia CTA', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: WalletScreen(),
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Rates'));
    await tester.pumpAndSettle();

    expect(find.text('Call rates'), findsOneWidget);
    expect(find.text('Ethiopia'), findsWidgets);
    expect(find.text('\$0.02'), findsOneWidget);
    expect(find.text('50 min'), findsOneWidget);
    expect(find.text('250 min'), findsOneWidget);
    expect(find.text('500 min'), findsOneWidget);
    expect(find.text('FREQUENTLY CALLED'), findsOneWidget);
    expect(find.text('your top destination'), findsOneWidget);
    expect(find.text('Call Ethiopia now'), findsOneWidget);
  });

  testWidgets('wallet rate lookup can start Ethiopia call', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await _signIn(tester, displayName: 'Alex Johnson');

    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Rates'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call Ethiopia now'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Active call'), findsOneWidget);
    expect(find.text('Ethiopia'), findsOneWidget);
    expect(find.text('+251'), findsOneWidget);
  });

  testWidgets('in-call hold state disables irrelevant controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: InCallScreen(
          request: OutgoingCallRequest(
            phone: '+251 91 393 9493',
            name: 'Yonas Hailu',
            startedAt: DateTime.now(),
          ),
          callService: const _FakeCallService(),
          onCallEnded: (_) {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Hold'));
    await tester.pump();

    expect(find.text('On hold'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.textContaining('can hear hold music'), findsOneWidget);

    final muteButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Mute'),
    );
    final speakerButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Speaker'),
    );
    final keypadButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Keypad'),
    );
    final resumeButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Resume'),
    );

    expect(muteButton.onPressed, isNull);
    expect(speakerButton.onPressed, isNull);
    expect(keypadButton.onPressed, isNull);
    expect(resumeButton.onPressed, isNotNull);
  });

  testWidgets('in-call poor network state offers cellular fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: InCallScreen(
          request: OutgoingCallRequest(
            phone: '+251 91 393 9493',
            name: 'Yonas Hailu',
            startedAt: DateTime.now(),
          ),
          callService: const _PoorNetworkCallService(),
          onCallEnded: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Poor network'), findsOneWidget);
    expect(find.text('Weak signal'), findsOneWidget);
    expect(find.text('Use 4G'), findsOneWidget);

    await tester.tap(find.text('Use 4G'));
    await tester.pump();

    expect(find.text('Active call'), findsOneWidget);
    expect(find.text('Poor network'), findsNothing);
  });

  testWidgets('in-call ended summary exposes call back action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    CallRecord? callbackRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: InCallScreen(
          request: OutgoingCallRequest(
            phone: '+251 91 393 9493',
            name: 'Yonas Hailu',
            startedAt: DateTime.now(),
          ),
          callService: const _FakeCallService(),
          onCallEnded: (_) {},
          onCallBackAfterEnded: (call) => callbackRecord = call,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(ZuriIcons.phoneOff));
    await tester.pump();

    expect(find.text('Call ended'), findsOneWidget);
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('COST'), findsOneWidget);

    await tester.tap(find.text('Call back'));
    await tester.pump();

    expect(callbackRecord, isNotNull);
    expect(callbackRecord!.phone, '+251 91 393 9493');
  });

  testWidgets('app shell shows ended summary before returning to recents', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await _signIn(tester, displayName: 'Alex Johnson');

    await tester.tap(find.byIcon(ZuriIcons.phone).first);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(ZuriIcons.phoneOff));
    await tester.pump();

    expect(find.text('Call ended'), findsOneWidget);
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('COST'), findsOneWidget);
    expect(find.text('Call back'), findsOneWidget);
    expect(find.text('Save contact'), findsNothing);
    expect(find.text('Report call quality'), findsNothing);
    expect(find.text('Maya Kim'), findsOneWidget);
  });

  testWidgets('app shell close button exits ended summary to recents', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await _signIn(tester, displayName: 'Alex Johnson');

    await tester.tap(find.byIcon(ZuriIcons.phone).first);
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(ZuriIcons.phoneOff));
    await tester.pump();
    expect(find.text('Call ended'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('Just now'), findsOneWidget);
    expect(find.text('Outgoing'), findsNothing);
  });

  testWidgets('service ended status opens call summary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: InCallScreen(
          request: OutgoingCallRequest(
            phone: '+251 91 393 9493',
            name: 'Yonas Hailu',
            startedAt: DateTime.now(),
          ),
          callService: const _EndedCallService(),
          onCallEnded: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Call ended'), findsOneWidget);
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('COST'), findsOneWidget);
    expect(find.text('Call back'), findsOneWidget);
    expect(find.text('Save contact'), findsNothing);
    expect(find.text('Report call quality'), findsNothing);
  });
}

Widget _testApp([
  CallHistoryRepository? callHistoryRepository,
  CallService callService = const _FakeCallService(),
  ContactsRepository? contactsRepository,
]) {
  return ZuriApp(
    dependencies: AppDependencies.defaults(
      contactsRepository: contactsRepository ?? _FakeContactsRepository(),
      callHistoryRepository:
          callHistoryRepository ?? _FakeCallHistoryRepository(),
      callService: callService,
    ),
  );
}

Future<void> _signIn(
  WidgetTester tester, {
  required String displayName,
}) async {
  await tester.tap(find.text('Continue with phone'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(EditableText), '6502137552');
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(EditableText), '338750');
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(EditableText), displayName);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Create an account'));
  await tester.pumpAndSettle();
}

class _FakeContactsRepository implements ContactsRepository {
  @override
  Future<ContactsLoadResult> loadContacts() async {
    return ContactsLoadResult.loaded([
      ContactPreview.fromNameAndPhone(
        name: 'Maya Kim',
        phone: '+1 (206) 555-0142',
      ),
    ]);
  }
}

class _EmptyContactsRepository implements ContactsRepository {
  @override
  Future<ContactsLoadResult> loadContacts() async {
    return const ContactsLoadResult.loaded([]);
  }
}

class _FakeCallHistoryRepository implements CallHistoryRepository {
  _FakeCallHistoryRepository({
    List<CallRecord> initialCalls = const [],
  }) : savedCalls = [...initialCalls];

  List<CallRecord> savedCalls;

  @override
  Future<List<CallRecord>> loadRecentCalls() async {
    return [...savedCalls];
  }

  @override
  Future<void> saveRecentCalls(List<CallRecord> calls) async {
    savedCalls = [...calls];
  }
}

class _FakeCallService implements CallService {
  const _FakeCallService();

  @override
  Stream<ActiveCallStatus> startOutgoingCall(OutgoingCallRequest request) {
    return Stream.fromIterable([
      ActiveCallStatus.connecting,
      ActiveCallStatus.connected,
    ]);
  }
}

class _FailingCallService implements CallService {
  const _FailingCallService();

  @override
  Stream<ActiveCallStatus> startOutgoingCall(OutgoingCallRequest request) {
    return Stream.fromIterable([
      ActiveCallStatus.connecting,
      ActiveCallStatus.failed,
    ]);
  }
}

class _PoorNetworkCallService implements CallService {
  const _PoorNetworkCallService();

  @override
  Stream<ActiveCallStatus> startOutgoingCall(OutgoingCallRequest request) {
    return Stream.fromIterable([
      ActiveCallStatus.connecting,
      ActiveCallStatus.connected,
      ActiveCallStatus.poorNetwork,
    ]);
  }
}

class _EndedCallService implements CallService {
  const _EndedCallService();

  @override
  Stream<ActiveCallStatus> startOutgoingCall(OutgoingCallRequest request) {
    return Stream.fromIterable([
      ActiveCallStatus.connecting,
      ActiveCallStatus.connected,
      ActiveCallStatus.ended,
    ]);
  }
}
