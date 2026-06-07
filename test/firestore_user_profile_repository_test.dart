import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zuri_call/features/auth/data/phone_country_data.dart';
import 'package:zuri_call/features/auth/domain/phone_number.dart';
import 'package:zuri_call/features/profile/data/firestore_user_profile_repository.dart';
import 'package:zuri_call/features/profile/data/user_profile_repository.dart';
import 'package:zuri_call/features/profile/domain/user_profile.dart';

void main() {
  test('loads profile from Firestore fields', () async {
    final repository = FirestoreUserProfileRepository(
      projectId: 'zuri-test',
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer token-123');
        expect(
          request.url.toString(),
          'https://firestore.googleapis.com/v1/projects/zuri-test/databases/(default)/documents/users/user-1',
        );

        return http.Response(
          jsonEncode({
            'fields': {
              'displayName': {'stringValue': 'Alex Johnson'},
              'phoneNumber': {'stringValue': '+16502137552'},
              'createdAt': {'timestampValue': '2026-06-01T12:00:00.000Z'},
            },
          }),
          200,
        );
      }),
    );

    final profile = await repository.loadProfile(
      userId: 'user-1',
      authToken: 'token-123',
    );

    expect(profile?.userId, 'user-1');
    expect(profile?.displayName, 'Alex Johnson');
    expect(profile?.phoneNumber?.e164, '+16502137552');
    expect(profile?.createdAt, DateTime.utc(2026, 6, 1, 12));
  });

  test('returns null for missing profile document', () async {
    final repository = FirestoreUserProfileRepository(
      projectId: 'zuri-test',
      httpClient: MockClient((_) async => http.Response('', 404)),
    );

    final profile = await repository.loadProfile(
      userId: 'missing-user',
      authToken: 'token-123',
    );

    expect(profile, isNull);
  });

  test('saves profile using Firestore field encoding', () async {
    late Map<String, dynamic> body;
    final repository = FirestoreUserProfileRepository(
      projectId: 'zuri-test',
      httpClient: MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.headers['Authorization'], 'Bearer token-123');
        expect(
          request.url.queryParametersAll['updateMask.fieldPaths'],
          containsAll([
            'displayName',
            'phoneNumber',
            'phoneCountryCode',
            'phoneNationalNumber',
            'updatedAt',
            'createdAt',
          ]),
        );
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{}', 200);
      }),
    );

    await repository.saveProfile(
      profile: UserProfile(
        userId: 'user-1',
        displayName: 'Alex Johnson',
        phoneNumber: PhoneNumber(
          country: countries.first,
          rawNationalNumber: '6502137552',
        ),
      ),
      authToken: 'token-123',
      includeCreatedAt: true,
    );

    final fields = body['fields'] as Map<String, dynamic>;
    expect(fields['displayName'], {'stringValue': 'Alex Johnson'});
    expect(fields['phoneNumber'], {'stringValue': '+16502137552'});
    expect(fields['phoneCountryCode'], {'stringValue': '+1'});
    expect(fields['phoneNationalNumber'], {'stringValue': '6502137552'});
    expect(fields['createdAt'], containsPair('timestampValue', isA<String>()));
    expect(fields['updatedAt'], containsPair('timestampValue', isA<String>()));
  });

  test('requires phone number when saving profile', () async {
    final repository = FirestoreUserProfileRepository(
      projectId: 'zuri-test',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    expect(
      repository.saveProfile(
        profile: const UserProfile(
          userId: 'user-1',
          displayName: 'Alex Johnson',
        ),
        authToken: 'token-123',
        includeCreatedAt: true,
      ),
      throwsA(isA<UserProfileException>()),
    );
  });
}
