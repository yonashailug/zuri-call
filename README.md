# Zuri Call

Flutter mobile MVP for the Zuri VoIP calling app.

## Current Scope

- Flutter app targeting iOS and Android.
- Light theme first.
- Phone-first OTP onboarding placeholder.
- Contacts, recents, dial pad, wallet, and settings shell.
- Android and iOS platform folders generated with bundle/package prefix `com.zuri`.

## Run Commands

Install or refresh dependencies first:

```sh
flutter pub get
```

List available devices:

```sh
flutter devices
```

Run on the default available device with fake/local auth:

```sh
flutter run
```

Run on a specific connected iPhone with fake/local auth:

```sh
flutter run -d <device-id>
```

Run on a connected iPhone with Firebase auth enabled:

```sh
flutter run --release \
  -d <device-id> \
  --dart-define=ZURI_USE_FIREBASE_AUTH=true
```

For the currently used iPhone, the device id has been:

```sh
flutter run --release \
  -d 00008130-000C0D221E3A001C \
  --dart-define=ZURI_USE_FIREBASE_AUTH=true
```

Run with Firebase auth and Firebase test phone settings:

```sh
flutter run \
  -d <device-id> \
  --dart-define=ZURI_USE_FIREBASE_AUTH=true \
  --dart-define=ZURI_FIREBASE_DISABLE_APP_VERIFICATION=true \
  --dart-define=ZURI_FIREBASE_TEST_PHONE_NUMBER=+14155550100 \
  --dart-define=ZURI_FIREBASE_TEST_SMS_CODE=123456
```

Build an iOS simulator app without launching it:

```sh
flutter build ios --simulator
```

Clean generated build artifacts:

```sh
flutter clean
```

## Local Checks

```sh
flutter pub get
dart format .
flutter analyze
flutter test
```

Native mobile builds also require a local Android SDK and a complete Xcode/CocoaPods setup.
