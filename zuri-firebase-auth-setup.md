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

## Production Readiness: iOS Phone Auth Verification

Firebase Phone Auth on iOS uses app verification before sending real SMS codes.
For production, Zuri should treat APNs silent verification as the primary path
and reCAPTCHA as a fallback path only.

### Required production setup

1. Use a paid Apple Developer Program team for the production bundle id.
2. Enable the Push Notifications capability for:

```text
com.zuri.zuriCall
```

3. Add an `aps-environment` entitlement through Xcode signing/capabilities.
4. Create or reuse an APNs auth key in Apple Developer.
5. Upload the APNs auth key to Firebase project settings for the iOS app.
6. Keep the encoded Firebase app id URL scheme in `Info.plist` for reCAPTCHA
   fallback redirects.

### UX expectation

With APNs configured correctly, most users should remain in the app during phone
verification. Firebase can verify the app silently and then send the SMS code.

If APNs is unavailable or verification fails, Firebase may fall back to a
browser/reCAPTCHA-style challenge before sending the SMS. That fallback is
acceptable for development and edge cases, but it is not the desired production
experience because it can:

- briefly move the user out of the app or show a web verification surface,
- make the auth flow feel less native,
- add friction before the SMS code is sent,
- increase abandonment risk on slow networks or unusual browser/session states.

### Current local development limitation

The current local device setup uses a personal Apple development team, which
cannot sign the Push Notifications capability. Because of that, local real-phone
testing may use reCAPTCHA fallback. For local development, prefer Firebase test
phone numbers with `ZURI_FIREBASE_DISABLE_APP_VERIFICATION=true`.

Before shipping production phone auth, verify the real-phone flow on a build
signed by the production Apple Developer team with APNs configured in Firebase.

## Notes

- The demo fake OTP remains `338750`.
- Firebase phone auth sends real SMS unless using Firebase test phone numbers.
- The UI does not need to change when switching repositories.
- Real iOS phone numbers require Firebase app verification setup through APNs
  or reCAPTCHA. If those are incomplete, local testing should use Firebase test
  phone numbers with `ZURI_FIREBASE_DISABLE_APP_VERIFICATION=true`.
