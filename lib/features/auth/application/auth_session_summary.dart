import '../data/auth_repository.dart';

class AuthSessionSummary {
  const AuthSessionSummary({
    required this.displayName,
    required this.greetingName,
    required this.initials,
    required this.phoneDisplay,
  });

  factory AuthSessionSummary.fromSession(AuthSession? session) {
    final displayName = _displayName(session);
    return AuthSessionSummary(
      displayName: displayName,
      greetingName: _firstName(displayName),
      initials: _initials(displayName),
      phoneDisplay: session?.phoneNumber.display ?? '',
    );
  }

  final String displayName;
  final String greetingName;
  final String initials;
  final String phoneDisplay;

  static String _displayName(AuthSession? session) {
    final name = session?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Zuri user';
  }

  static String _firstName(String displayName) {
    final parts = displayName.split(RegExp(r'\s+'));
    return parts.first;
  }

  static String _initials(String displayName) {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'ZU';

    return parts.map((part) => part[0].toUpperCase()).join();
  }
}
