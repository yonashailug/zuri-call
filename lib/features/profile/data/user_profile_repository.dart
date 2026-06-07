import '../domain/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> loadProfile({
    required String userId,
    required String authToken,
  });

  Future<void> saveProfile({
    required UserProfile profile,
    required String authToken,
    required bool includeCreatedAt,
  });
}

class UserProfileException implements Exception {
  const UserProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}
