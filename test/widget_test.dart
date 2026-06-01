import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/app.dart';
import 'package:zuri_call/features/calling/call_service.dart';
import 'package:zuri_call/features/calling/in_call_screen.dart';
import 'package:zuri_call/features/dialpad/dialpad_screen.dart';
import 'package:zuri_call/features/home/call_history_repository.dart';
import 'package:zuri_call/features/home/call_record.dart';
import 'package:zuri_call/features/home/contact_preview.dart';
import 'package:zuri_call/features/home/device_contacts_repository.dart';

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

    await tester.tap(find.byIcon(Icons.call_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Dial'), findsOneWidget);
    expect(find.text('+1 (206) 555-0142'), findsOneWidget);

    await tester.tap(find.text('Call now'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Active call'), findsOneWidget);
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('Mute'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('0:01'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.call_end_rounded));
    await tester.pump();
    expect(find.text('Call ended'), findsOneWidget);
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('COST'), findsOneWidget);
    expect(find.text('Rate'), findsOneWidget);
    expect(find.text('Wallet balance'), findsOneWidget);
    expect(find.text('Report call quality'), findsOneWidget);

    await tester.tap(find.text('Report call quality'));
    await tester.pumpAndSettle();

    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('Just now'), findsOneWidget);
    expect(find.text('Outgoing • 1s'), findsOneWidget);

    await tester.tap(find.text('Maya Kim').first);
    await tester.pumpAndSettle();
    expect(find.text('Call details'), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('Recents'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('1s'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Recents'), findsOneWidget);
    expect(find.text('Just now'), findsOneWidget);
    expect(find.text('Outgoing • 1s'), findsOneWidget);

    await tester.tap(find.text('Maya Kim').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call back'));
    await tester.pumpAndSettle();
    expect(find.text('Dial'), findsOneWidget);
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

    await tester.tap(find.byIcon(Icons.call_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call now'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Unable to connect'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Maya Kim'), findsOneWidget);
    expect(find.text('Just now'), findsOneWidget);
    expect(find.text('Outgoing • Failed'), findsOneWidget);
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
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('Recents'), findsOneWidget);

    await tester.tap(find.text('Delete from recents'));
    await tester.pumpAndSettle();

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
    expect(find.text('Outgoing'), findsOneWidget);
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

    expect(find.text('Dial'), findsOneWidget);
  });

  testWidgets('dialpad keeps selected US prefix for manual numbers', (
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

    expect(find.text('206'), findsOneWidget);

    await tester.tap(find.text('Call now'));
    await tester.pump();

    expect(startedNumber, '+1 206');
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

    await tester.tap(find.byIcon(Icons.call_end_rounded));
    await tester.pump();

    expect(find.text('Call ended'), findsOneWidget);
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('COST'), findsOneWidget);

    await tester.tap(find.text('Call\nback'));
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

    await tester.tap(find.byIcon(Icons.call_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call now'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.call_end_rounded));
    await tester.pump();

    expect(find.text('Call ended'), findsOneWidget);
    expect(find.text('DURATION'), findsOneWidget);
    expect(find.text('COST'), findsOneWidget);
    expect(find.text('Report call quality'), findsOneWidget);
    expect(find.text('Maya Kim'), findsOneWidget);
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
    expect(find.text('Report call quality'), findsOneWidget);
  });
}

Widget _testApp([
  CallHistoryRepository? callHistoryRepository,
  CallService callService = const _FakeCallService(),
  ContactsRepository? contactsRepository,
]) {
  return ZuriApp(
    contactsRepository: contactsRepository ?? _FakeContactsRepository(),
    callHistoryRepository:
        callHistoryRepository ?? _FakeCallHistoryRepository(),
    callService: callService,
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
