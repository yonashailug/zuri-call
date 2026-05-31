# Zuri Firebase Auth Setup

## Current Integration State

The app now has a Firebase Auth adapter behind the existing `AuthRepository` boundary:

```text
lib/features/auth/data/firebase_auth_repository.dart
```

The default app still uses `FakeAuthRepository` so local builds and tests work without Firebase project files.

To run against Firebase, launch with:

```sh
flutter run --release \
  --dart-define=ZURI_USE_FIREBASE_AUTH=true
```

For local development with Firebase test phone numbers, disable app verification
and pass the exact test phone/code configured in Firebase:

```sh
flutter run \
  --dart-define=ZURI_USE_FIREBASE_AUTH=true \
  --dart-define=ZURI_FIREBASE_DISABLE_APP_VERIFICATION=true \
  --dart-define=ZURI_FIREBASE_TEST_PHONE_NUMBER=+14155550100 \
  --dart-define=ZURI_FIREBASE_TEST_SMS_CODE=123456
```

## Required Firebase Project Setup

Before enabling the real adapter:

1. Create or select a Firebase project.
2. Add the iOS app bundle id:

```text
com.zuri.zuriCall
```

3. Download `GoogleService-Info.plist`.
4. Add it to:

```text
ios/Runner/GoogleService-Info.plist
```

5. Enable Phone provider in Firebase Authentication.
6. Configure iOS APNs settings for reliable phone auth on real devices.
7. Add test phone numbers in Firebase for development.

## Runtime Switch

The app chooses auth implementation in `lib/main.dart`:

- default: `FakeAuthRepository`
- with `ZURI_USE_FIREBASE_AUTH=true`: `FirebaseAuthRepository`

This keeps CI and local UI work stable while allowing real-device Firebase testing when config exists.

## Notes

- The demo fake OTP remains `338750`.
- Firebase phone auth sends real SMS unless using Firebase test phone numbers.
- The UI does not need to change when switching repositories.
- Real iOS phone numbers require Firebase app verification setup through APNs
  or reCAPTCHA. If those are incomplete, local testing should use Firebase test
  phone numbers with `ZURI_FIREBASE_DISABLE_APP_VERIFICATION=true`.
