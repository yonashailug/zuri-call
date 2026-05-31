# Zuri Auth Architecture Task Plan

## Purpose

The current auth onboarding implementation is appropriate for an MVP visual flow, but it should not become the long-term auth architecture unchanged. This task plan turns the architecture review into concrete implementation steps before adding a production backend.

## Current State

- The app has a light-theme phone auth onboarding flow:
  - Welcome
  - Phone number entry
  - Code verification
  - Profile name creation
- The UI is inspired by the provided Pi screenshots.
- Phone number formatting is handled client-side using the selected country placeholder as a mask.
- The flow is currently local-only:
  - No real OTP request.
  - No real OTP verification.
  - No persisted user session.
  - No profile creation API.

## Architecture Goals

- Keep the screens simple and mostly presentation-focused.
- Move auth business logic out of widgets.
- Make backend choice replaceable behind an interface.
- Keep phone formatting and country metadata testable outside widget tests.
- Support Firebase, Supabase, or a custom backend without rewriting the onboarding UI.
- Add enough test coverage to safely iterate on auth.

## Recommended Target Shape

```text
lib/features/auth/
  application/
    auth_controller.dart
    auth_state.dart
  data/
    auth_repository.dart
    fake_auth_repository.dart
    phone_country_data.dart
  domain/
    phone_mask_input_formatter.dart
    phone_number.dart
  presentation/
    welcome_screen.dart
    phone_entry_screen.dart
    code_verification_screen.dart
    profile_name_screen.dart
    auth_design.dart
```

## Task 1: Introduce Auth Repository Boundary

Create an `AuthRepository` interface that owns backend-facing auth operations.

Methods:

```dart
abstract class AuthRepository {
  Future<void> startPhoneAuth({
    required String countryCode,
    required String nationalNumber,
  });

  Future<AuthSession> verifyCode({
    required String phoneNumber,
    required String code,
  });

  Future<UserProfile> createProfile({
    required String userId,
    required String displayName,
  });
}
```

Acceptance criteria:

- Screens do not pretend verification succeeded directly.
- The app can run with a `FakeAuthRepository` for MVP/demo mode.
- Backend integration can be added later without changing route structure.

## Task 2: Add Auth Controller and State

Create an auth controller that owns the auth flow state.

Suggested states:

- `idle`
- `enteringPhone`
- `sendingCode`
- `codeSent`
- `verifyingCode`
- `needsProfile`
- `authenticated`
- `failure`

Acceptance criteria:

- Buttons show loading/disabled states based on controller state.
- Verification failure can be displayed without navigating forward.
- Route transitions are triggered by auth state, not hardcoded success inside each screen.

## Task 3: Move Phone Formatting Out of UI

Move `PhoneMaskInputFormatter` out of `phone_entry_screen.dart` into domain/shared form code.

Add unit tests for:

- US mask: `6502137552` -> `(650) 213-7552`
- Singapore mask: `81234567` -> `8123 4567`
- Extra digits are ignored.
- Non-digit input is stripped.
- Country switch reapplies the new mask to existing digits.

Acceptance criteria:

- Formatter has pure unit tests.
- Widget tests only verify user-facing behavior.
- Phone entry screen imports the formatter instead of defining it inline.

## Task 4: Move Country Metadata to Data Layer

Move the hardcoded `countries` list out of the phone entry screen.

Create:

```text
lib/features/auth/data/phone_country_data.dart
```

Acceptance criteria:

- Screen renders from imported country data.
- Country option model is reusable outside the widget.
- Later replacement with package/backend metadata is straightforward.

## Task 5: Normalize Phone Number Model

Introduce a small `PhoneNumber` value object.

Fields:

- `countryCode`
- `nationalNumber`
- `formattedNationalNumber`
- `e164`

Acceptance criteria:

- Backend calls receive E.164-compatible values.
- UI can still display friendly formatted numbers.
- Code verification screen receives normalized phone data, not a loose display string.

## Task 6: Integrate Auth UI with App Theme

The current `auth_design.dart` is useful, but it is a feature-local design layer. Keep the auth-specific components, but move reusable color/type decisions toward the app theme.

Acceptance criteria:

- Shared colors live in the app theme or a token file.
- Auth components consume theme tokens instead of hardcoding every color.
- Light theme remains the only supported theme for now.

## Task 7: Expand Tests

Add tests in layers.

Unit tests:

- Phone formatter.
- Phone number value object.
- Auth controller state transitions.

Widget tests:

- Phone entry formats while typing.
- Continue is disabled for invalid phone numbers.
- Country picker updates placeholder and formatter.
- Code verification rejects incomplete codes.
- Profile creation requires a valid name.

Integration-style fake repository tests:

- Successful phone auth flow.
- Failed code verification.
- Retry/resend path.

Acceptance criteria:

- `flutter analyze` passes.
- `flutter test` passes.
- Critical auth states have automated coverage.

## Task 8: Backend Decision Point

Before production auth, choose the backend implementation behind `AuthRepository`.

Recommended options:

- Supabase Auth if the app wants a simple hosted backend with Postgres and phone OTP.
- Firebase Auth if the app wants the fastest mobile phone auth path and mature device tooling.
- Custom backend only if Zuri requires custom telecom, call routing, user identity, compliance, or billing logic from day one.

Current recommendation:

Use a repository boundary now, keep a fake implementation for MVP, and make the backend decision after the UX flow is stable. If forced to pick early, Firebase Auth is likely the lowest-friction phone OTP option for a Flutter mobile MVP.

## Suggested Implementation Order

1. Move phone formatter and country data out of UI.
2. Add formatter and phone model unit tests.
3. Add `AuthRepository` with `FakeAuthRepository`.
4. Add `AuthController/AuthState`.
5. Refactor screens to call the controller.
6. Add loading, failure, and resend states.
7. Choose and implement the real backend adapter.

## Definition of Done

- Auth screens are presentation-focused.
- Auth business logic is covered by unit tests.
- Backend access goes through `AuthRepository`.
- Phone numbers are normalized before backend calls.
- UI handles success, loading, failure, retry, and incomplete input states.
- The app still passes:

```sh
flutter analyze
flutter test
flutter build ios --debug --no-codesign
```
