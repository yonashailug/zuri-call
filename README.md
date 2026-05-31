# Zuri Call

Flutter mobile MVP for the Zuri VoIP calling app.

## Current Scope

- Flutter app targeting iOS and Android.
- Light theme first.
- Phone-first OTP onboarding placeholder.
- Contacts, recents, dial pad, wallet, and settings shell.
- Android and iOS platform folders generated with bundle/package prefix `com.zuri`.

## Local Checks

```sh
flutter pub get
dart format .
flutter analyze
flutter test
```

Native mobile builds also require a local Android SDK and a complete Xcode/CocoaPods setup.
