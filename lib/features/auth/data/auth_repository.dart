import '../domain/phone_number.dart';

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.phoneNumber,
    this.displayName,
  });

  final String userId;
  final PhoneNumber phoneNumber;
  final String? displayName;

  AuthSession copyWith({String? displayName}) {
    return AuthSession(
      userId: userId,
      phoneNumber: phoneNumber,
      displayName: displayName ?? this.displayName,
    );
  }
}

abstract class AuthRepository {
  Future<void> startPhoneAuth(PhoneNumber phoneNumber);

  Future<AuthSession> verifyCode({
    required PhoneNumber phoneNumber,
    required String code,
  });

  Future<AuthSession> createProfile({
    required AuthSession session,
    required String displayName,
  });

  Future<void> signOut();
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
