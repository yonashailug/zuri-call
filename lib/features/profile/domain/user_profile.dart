import '../../auth/domain/phone_number.dart';

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    this.phoneNumber,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String displayName;
  final PhoneNumber? phoneNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
