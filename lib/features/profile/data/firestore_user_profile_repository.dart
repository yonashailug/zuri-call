import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../../auth/data/phone_country_data.dart';
import '../../auth/domain/phone_number.dart';
import '../domain/user_profile.dart';
import 'user_profile_repository.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({
    http.Client? httpClient,
    String? projectId,
  })  : _httpClient = httpClient ?? http.Client(),
        _projectId = projectId;

  final http.Client _httpClient;
  final String? _projectId;

  @override
  Future<UserProfile?> loadProfile({
    required String userId,
    required String authToken,
  }) async {
    final response = await _httpClient.get(
      await _userDocumentUri(userId),
      headers: _authHeaders(authToken),
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const UserProfileException(
        'Could not load your profile. Try again.',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final fields = payload['fields'] as Map<String, dynamic>? ?? {};
    return _profileFromFirestoreFields(userId, fields);
  }

  @override
  Future<void> saveProfile({
    required UserProfile profile,
    required String authToken,
    required bool includeCreatedAt,
  }) async {
    final now = DateTime.now().toUtc();
    final phoneNumber = profile.phoneNumber;
    if (phoneNumber == null) {
      throw const UserProfileException('Profile phone number is required.');
    }

    final fields = {
      'displayName': profile.displayName,
      'phoneNumber': phoneNumber.e164,
      'phoneCountryCode': phoneNumber.country.prefix,
      'phoneNationalNumber': phoneNumber.nationalNumber,
      'updatedAt': now.toIso8601String(),
      if (includeCreatedAt) 'createdAt': now.toIso8601String(),
    };

    final response = await _httpClient.patch(
      await _userDocumentUri(profile.userId, updateMask: fields.keys),
      headers: _authHeaders(authToken),
      body: jsonEncode({
        'fields': _firestoreFields(fields),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const UserProfileException(
        'Could not save your profile. Try again.',
      );
    }
  }

  UserProfile? _profileFromFirestoreFields(
    String userId,
    Map<String, dynamic> fields,
  ) {
    final values = fields.map((key, value) {
      final field = value as Map<String, dynamic>;
      return MapEntry(
        key,
        field['stringValue'] as String? ??
            field['timestampValue'] as String? ??
            '',
      );
    });
    final displayName = values['displayName']?.trim();
    final e164 = values['phoneNumber'];
    final phoneNumber = _phoneNumberFromE164(e164);

    if (displayName == null || displayName.isEmpty) {
      return null;
    }

    return UserProfile(
      userId: userId,
      displayName: displayName,
      phoneNumber: phoneNumber,
      createdAt: DateTime.tryParse(values['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(values['updatedAt'] ?? ''),
    );
  }

  PhoneNumber? _phoneNumberFromE164(String? e164) {
    if (e164 == null || e164.isEmpty) return null;

    final sortedCountries = [...countries]
      ..sort((a, b) => b.prefix.length.compareTo(a.prefix.length));
    for (final country in sortedCountries) {
      if (e164.startsWith(country.prefix)) {
        return PhoneNumber(
          country: country,
          rawNationalNumber: e164.substring(country.prefix.length),
        );
      }
    }

    return null;
  }

  Future<Uri> _userDocumentUri(
    String uid, {
    Iterable<String> updateMask = const [],
  }) async {
    final projectId = _projectId ?? Firebase.app().options.projectId;
    final queryParameters = updateMask.isEmpty
        ? null
        : <String, dynamic>{
            'updateMask.fieldPaths': updateMask.toList(),
          };

    return Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/$projectId/databases/(default)/documents/users/$uid',
      queryParameters,
    );
  }

  Map<String, String> _authHeaders(String authToken) {
    return {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };
  }

  Map<String, Map<String, String>> _firestoreFields(
    Map<String, String> fields,
  ) {
    return {
      for (final entry in fields.entries)
        entry.key: entry.key.endsWith('At')
            ? {'timestampValue': entry.value}
            : {'stringValue': entry.value},
    };
  }
}
