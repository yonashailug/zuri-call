import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/features/auth/application/auth_controller.dart';
import 'package:zuri_call/features/auth/data/auth_repository.dart';
import 'package:zuri_call/features/auth/data/fake_auth_repository.dart';
import 'package:zuri_call/features/auth/data/phone_country_data.dart';
import 'package:zuri_call/features/auth/domain/phone_number.dart';

void main() {
  test('restores an existing auth session', () async {
    final phoneNumber = PhoneNumber(
      country: countries.first,
      rawNationalNumber: '6502137552',
    );
    final session = AuthSession(
      userId: 'existing-user',
      phoneNumber: phoneNumber,
      displayName: 'Alex Johnson',
    );
    final controller = AuthController(
      repository: _RestoringAuthRepository(session),
    );

    addTearDown(controller.dispose);

    await controller.restoreSession();

    expect(controller.state.step, AuthStep.authenticated);
    expect(controller.state.session, session);
  });

  test('returns to signed out when session restore fails unexpectedly',
      () async {
    final controller = AuthController(
      repository: _FailingRestoreAuthRepository(),
    );

    addTearDown(controller.dispose);

    await controller.restoreSession();

    expect(controller.state.step, AuthStep.signedOut);
    expect(controller.state.session, isNull);
    expect(controller.state.errorMessage, contains('Could not restore'));
  });

  test('walks fake auth state from phone to authenticated session', () async {
    final controller = AuthController(repository: FakeAuthRepository());
    final phoneNumber = PhoneNumber(
      country: countries.first,
      rawNationalNumber: '6502137552',
    );

    addTearDown(controller.dispose);

    expect(await controller.startPhoneAuth(phoneNumber), isTrue);
    expect(controller.state.step, AuthStep.codeSent);

    expect(await controller.verifyCode(FakeAuthRepository.validCode), isTrue);
    expect(controller.state.step, AuthStep.needsProfile);

    expect(await controller.createProfile('Alex Johnson'), isTrue);
    expect(controller.state.step, AuthStep.authenticated);
    expect(controller.state.session?.displayName, 'Alex Johnson');

    await controller.signOut();
    expect(controller.state.step, AuthStep.signedOut);
    expect(controller.state.session, isNull);
  });

  test('rejects invalid fake verification code', () async {
    final controller = AuthController(repository: FakeAuthRepository());
    final phoneNumber = PhoneNumber(
      country: countries.first,
      rawNationalNumber: '6502137552',
    );

    addTearDown(controller.dispose);

    await controller.startPhoneAuth(phoneNumber);

    expect(await controller.verifyCode('000000'), isFalse);
    expect(controller.state.step, AuthStep.codeSent);
    expect(controller.state.errorMessage, contains('338750'));
  });
}

class _RestoringAuthRepository extends FakeAuthRepository {
  _RestoringAuthRepository(this.session);

  final AuthSession? session;

  @override
  Future<AuthSession?> restoreSession() async {
    return session;
  }
}

class _FailingRestoreAuthRepository extends FakeAuthRepository {
  @override
  Future<AuthSession?> restoreSession() async {
    throw StateError('restore failed');
  }
}
