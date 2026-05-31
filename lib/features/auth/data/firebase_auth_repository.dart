import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'phone_country_data.dart';
import '../domain/phone_number.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    http.Client? httpClient,
    this.appVerificationDisabledForTesting = false,
    this.testPhoneNumber,
    this.testSmsCode,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _httpClient = httpClient ?? http.Client();

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final http.Client _httpClient;
  final bool appVerificationDisabledForTesting;
  final String? testPhoneNumber;
  final String? testSmsCode;

  String? _verificationId;
  PhoneNumber? _bypassedTestPhoneNumber;

  @override
  Future<AuthSession?> restoreSession() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final phoneNumber = _phoneNumberFromE164(user.phoneNumber);
    if (phoneNumber == null) {
      await _firebaseAuth.signOut();
      return null;
    }

    final profile = await _fetchUserProfile(user);
    final displayName = profile?['displayName'] ?? user.displayName;

    return AuthSession(
      userId: user.uid,
      phoneNumber: phoneNumber,
      displayName: displayName,
    );
  }

  @override
  Future<void> startPhoneAuth(PhoneNumber phoneNumber) async {
    if (!phoneNumber.isValid) {
      throw const AuthException('Enter a valid phone number.');
    }

    if (_shouldBypassNativePhoneVerification(phoneNumber)) {
      _bypassedTestPhoneNumber = phoneNumber;
      _verificationId = null;
      return;
    }

    final completer = Completer<void>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber.e164,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(
            AuthException(_messageForFirebaseError(error)),
          );
        }
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw const AuthException(
          'Could not send a code. Check Firebase phone auth setup and try again.',
        );
      },
    );
  }

  @override
  Future<AuthSession> verifyCode({
    required PhoneNumber phoneNumber,
    required String code,
  }) async {
    final verificationId = _verificationId;
    final bypassedPhoneNumber = _bypassedTestPhoneNumber;
    if (bypassedPhoneNumber != null) {
      if (phoneNumber.e164 != bypassedPhoneNumber.e164) {
        throw const AuthException('Request a new code first.');
      }
      if (code != testSmsCode) {
        throw const AuthException('That code did not match.');
      }
      return AuthSession(
        userId: 'firebase-test-${phoneNumber.nationalNumber}',
        phoneNumber: phoneNumber,
      );
    }

    if (verificationId == null) {
      throw const AuthException('Request a new code first.');
    }

    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Unable to sign in. Try again.');
      }

      return AuthSession(
        userId: user.uid,
        phoneNumber: phoneNumber,
        displayName: await _displayNameForUser(user),
      );
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_messageForFirebaseError(error));
    }
  }

  @override
  Future<AuthSession> createProfile({
    required AuthSession session,
    required String displayName,
  }) async {
    final trimmedName = displayName.trim();
    if (trimmedName.length < 2) {
      throw const AuthException('Enter your name.');
    }

    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(trimmedName);
      final existingProfile = await _fetchUserProfile(user);
      await _saveUserProfile(
        user: user,
        profile: {
          'displayName': trimmedName,
          'phoneNumber': session.phoneNumber.e164,
          'phoneCountryCode': session.phoneNumber.country.prefix,
          'phoneNationalNumber': session.phoneNumber.nationalNumber,
        },
        includeCreatedAt: existingProfile == null,
      );
    }

    return session.copyWith(displayName: trimmedName);
  }

  @override
  Future<void> signOut() {
    _bypassedTestPhoneNumber = null;
    _verificationId = null;
    return _firebaseAuth.signOut();
  }

  bool _shouldBypassNativePhoneVerification(PhoneNumber phoneNumber) {
    return appVerificationDisabledForTesting &&
        testPhoneNumber != null &&
        testSmsCode != null &&
        phoneNumber.e164 == testPhoneNumber;
  }

  String _messageForFirebaseError(firebase_auth.FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-phone-number' => 'Enter a valid phone number.',
      'invalid-verification-code' => 'That code did not match.',
      'session-expired' => 'That code expired. Request a new one.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      _ => error.message ?? 'Authentication failed. Try again.',
    };
  }

  Future<String?> _displayNameForUser(firebase_auth.User user) async {
    final profile = await _fetchUserProfile(user);
    return profile?['displayName'] ?? user.displayName;
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

  Future<Map<String, String>?> _fetchUserProfile(
    firebase_auth.User user,
  ) async {
    final response = await _httpClient.get(
      await _userDocumentUri(user.uid),
      headers: await _authHeaders(user),
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AuthException('Could not load your profile. Try again.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final fields = payload['fields'] as Map<String, dynamic>? ?? {};

    return fields.map((key, value) {
      final field = value as Map<String, dynamic>;
      return MapEntry(key, field['stringValue'] as String? ?? '');
    });
  }

  Future<void> _saveUserProfile({
    required firebase_auth.User user,
    required Map<String, String> profile,
    required bool includeCreatedAt,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final fields = {
      ...profile,
      'updatedAt': now,
      if (includeCreatedAt) 'createdAt': now,
    };

    final response = await _httpClient.patch(
      await _userDocumentUri(user.uid, updateMask: fields.keys),
      headers: await _authHeaders(user),
      body: jsonEncode({
        'fields': _firestoreFields(fields),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const AuthException('Could not save your profile. Try again.');
    }
  }

  Future<Uri> _userDocumentUri(
    String uid, {
    Iterable<String> updateMask = const [],
  }) async {
    final projectId = Firebase.app().options.projectId;
    final queryParameters = <String, dynamic>{
      if (updateMask.isNotEmpty) 'updateMask.fieldPaths': updateMask.toList(),
    };

    return Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/$projectId/databases/(default)/documents/users/$uid',
      queryParameters,
    );
  }

  Future<Map<String, String>> _authHeaders(firebase_auth.User user) async {
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
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
