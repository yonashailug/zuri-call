import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/features/auth/application/auth_session_summary.dart';
import 'package:zuri_call/features/auth/data/auth_repository.dart';
import 'package:zuri_call/features/auth/data/phone_country_data.dart';
import 'package:zuri_call/features/auth/domain/phone_number.dart';

void main() {
  test('derives display fields from auth session', () {
    final summary = AuthSessionSummary.fromSession(
      AuthSession(
        userId: 'user-1',
        phoneNumber: PhoneNumber(
          country: countries.first,
          rawNationalNumber: '2065550100',
        ),
        displayName: 'Yonas Hailu',
      ),
    );

    expect(summary.displayName, 'Yonas Hailu');
    expect(summary.greetingName, 'Yonas');
    expect(summary.initials, 'YH');
    expect(summary.phoneDisplay, '+1 (206) 555-0100');
  });

  test('uses a stable fallback when profile name is unavailable', () {
    final summary = AuthSessionSummary.fromSession(null);

    expect(summary.displayName, 'Zuri user');
    expect(summary.greetingName, 'Zuri');
    expect(summary.initials, 'ZU');
    expect(summary.phoneDisplay, isEmpty);
  });
}
