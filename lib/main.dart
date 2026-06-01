import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'firebase_options.dart';

const useFirebaseAuth = bool.fromEnvironment('ZURI_USE_FIREBASE_AUTH');
const disableFirebaseAppVerification = bool.fromEnvironment(
  'ZURI_FIREBASE_DISABLE_APP_VERIFICATION',
);
const firebaseTestPhoneNumber = String.fromEnvironment(
  'ZURI_FIREBASE_TEST_PHONE_NUMBER',
);
const firebaseTestSmsCode = String.fromEnvironment(
  'ZURI_FIREBASE_TEST_SMS_CODE',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (useFirebaseAuth) {
    await _initializeFirebase();
    await firebase_auth.FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: disableFirebaseAppVerification,
      phoneNumber:
          firebaseTestPhoneNumber.isEmpty ? null : firebaseTestPhoneNumber,
      smsCode: firebaseTestSmsCode.isEmpty ? null : firebaseTestSmsCode,
    );
  }

  runApp(
    ZuriApp(
      authRepository: useFirebaseAuth
          ? FirebaseAuthRepository(
              appVerificationDisabledForTesting: disableFirebaseAppVerification,
              testPhoneNumber: firebaseTestPhoneNumber.isEmpty
                  ? null
                  : firebaseTestPhoneNumber,
              testSmsCode:
                  firebaseTestSmsCode.isEmpty ? null : firebaseTestSmsCode,
            )
          : null,
    ),
  );
}

Future<void> _initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) return;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error) {
    if (error.code == 'duplicate-app') return;

    rethrow;
  }
}
