import '../domain/phone_number.dart';
import 'auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  static const validCode = '338750';

  @override
  Future<AuthSession?> restoreSession() async {
    return null;
  }

  @override
  Future<void> startPhoneAuth(PhoneNumber phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!phoneNumber.isValid) {
      throw const AuthException('Enter a valid phone number.');
    }
  }

  @override
  Future<AuthSession> verifyCode({
    required PhoneNumber phoneNumber,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (code != validCode) {
      throw const AuthException('That code did not match. Try 338750.');
    }

    return AuthSession(
      userId: 'fake-user-${phoneNumber.nationalNumber}',
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<AuthSession> createProfile({
    required AuthSession session,
    required String displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final trimmedName = displayName.trim();
    if (trimmedName.length < 2) {
      throw const AuthException('Enter your name.');
    }

    return session.copyWith(displayName: trimmedName);
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
