import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../domain/phone_number.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    this.appVerificationDisabledForTesting = false,
    this.testPhoneNumber,
    this.testSmsCode,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final bool appVerificationDisabledForTesting;
  final String? testPhoneNumber;
  final String? testSmsCode;

  String? _verificationId;
  PhoneNumber? _bypassedTestPhoneNumber;

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
        displayName: user.displayName,
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
}
