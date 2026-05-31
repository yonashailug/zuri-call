# Zuri MVP Product and Developer Design

This document turns the Zuri VoIP concept into an implementation-ready MVP plan. It should be used together with `zuri_voip_light_dark_themes.html` for visual direction and `zuri-missing-mvp-screens-spec.md` for screen coverage.

## Product Definition

Zuri is a consumer VoIP calling app for placing paid phone calls over Wi-Fi or mobile data. The MVP should prove the core paid-calling loop:

1. A user signs up or signs in.
2. The user verifies a phone number.
3. The user adds calling credit.
4. The user checks cost/rate when needed.
5. The user places an outbound call.
6. The app records the call and charges the wallet ledger.
7. The user can inspect call and transaction history or contact support.

The MVP is not a messaging app, video-call product, social network, or full telecom back office. Those can be added only after the paid outbound calling loop is stable.

## MVP Scope

### Included

- Phone-first authentication with OTP.
- User profile with display name, primary phone, optional email.
- Contacts home and search.
- Manual dial pad with international number support.
- Outbound VoIP call placement.
- Active call screen with mute, speaker, keypad, and hang up.
- Wallet balance.
- Credit purchase flow.
- Immutable transaction history.
- Rate lookup by country or prefix.
- Pre-call cost check for international, unknown-rate, high-cost, or low-balance calls.
- Insufficient balance blocking state.
- Call failed and connection problem states.
- Settings with account, wallet, rates, support, legal links, emergency calling notice, sign out, and delete account entry point.
- Basic support issue capture with call/payment context.

### Excluded From MVP

- In-app messaging.
- Video calling.
- Incoming calls.
- Group calls.
- Subscriptions.
- Referrals or rewards.
- Advanced contact sync conflict resolution.
- Complex analytics dashboards.
- Multi-currency wallet balances.
- Full self-serve refunds.
- Enterprise/admin console.

## Recommended Product Decisions

### Auth

Use phone-first OTP authentication.

Rationale:

- Phone number is central to a calling product.
- OTP reduces password reset/support burden.
- Verified phone identity helps with fraud checks, support, and future caller identity flows.
- Email can be collected later for receipts and recovery without making it the primary identity.

MVP auth methods:

- Primary: phone number + SMS OTP.
- Secondary: optional email collection after signup.
- Later: Apple/Google sign-in after mobile conversion data justifies it.

Do not ship password auth in MVP unless a web-only requirement appears. It adds account recovery and security surface area without improving the first paid-call loop.

### Backend Services

Use the following provider split for MVP:

- Supabase: auth, Postgres, row-level security, storage of product data, edge/server functions.
- Twilio: SMS OTP provider and programmable voice provider.
- Stripe or RevenueCat: payment provider, depending on distribution policy.

Payment decision:

- Use Stripe for web checkout or direct credit purchase outside app-store IAP rules.
- Use RevenueCat over Apple/Google in-app purchases if credits must be sold inside native mobile app stores.

Policy note: final payment path must be validated against Apple App Store and Google Play rules before implementation. Do not hard-code business assumptions into the wallet ledger until that decision is made.

## User Flows

### Signup / Sign In

1. User enters phone number.
2. Backend sends OTP through Supabase Auth configured with Twilio.
3. User enters OTP.
4. Auth session is created.
5. If first login, app asks for display name and optional email.
6. Backend creates profile and empty wallet ledger.
7. User lands on contacts home.

Failure states:

- Invalid phone number.
- OTP expired.
- OTP incorrect.
- Too many attempts.
- SMS delivery failed.
- Account suspended.

### Add Credits

1. User opens Wallet.
2. User selects credit package.
3. Backend creates purchase intent/order.
4. Client completes payment with Stripe or in-app purchase provider.
5. Provider webhook confirms payment.
6. Backend writes a `credit_purchase` ledger transaction.
7. Wallet balance updates.

Important rule: never credit the wallet from a client-side success callback alone. Only provider webhook or server-side purchase verification can create wallet credit.

### Outbound Call

1. User selects contact or enters number on dial pad.
2. Client sends destination number to backend for normalization and call eligibility.
3. Backend checks:
   - user is verified,
   - destination is valid,
   - destination is supported,
   - rate is available,
   - wallet has enough balance for the minimum billable increment,
   - user/account is allowed to call.
4. Backend returns rate and estimated minutes.
5. App shows pre-call cost check only when needed.
6. Backend issues short-lived Twilio Voice token or starts server-authorized call.
7. Client starts call.
8. Twilio callbacks update call status.
9. When call completes, backend calculates charge from final duration/rate.
10. Backend writes `call_charge` ledger transaction.
11. Call history row is finalized.

### Failed Call

Failure reasons should be mapped to user-safe categories:

- No internet connection.
- Weak connection.
- Invalid number.
- Unsupported destination.
- Blocked destination.
- Not enough credit.
- Provider unavailable.
- Unknown error.

Provider error codes may be stored internally, but user-facing copy should be plain language.

## Information Architecture

Recommended bottom nav for MVP:

- Recents
- Contacts
- Call button / Dial pad
- Wallet
- Settings

Remove or hide `Messages` for MVP unless messaging becomes a committed product requirement.

## Data Model

Use Supabase Postgres as the source of truth. IDs should be UUIDs unless provider IDs require strings.

### `profiles`

- `id` UUID, primary key, references auth user.
- `display_name` text, required after onboarding.
- `primary_phone` text, unique, E.164 normalized.
- `email` text, nullable.
- `status` enum: `active`, `suspended`, `deleted`.
- `created_at` timestamp.
- `updated_at` timestamp.

### `wallets`

- `id` UUID, primary key.
- `user_id` UUID, unique.
- `currency` text, default `USD`.
- `cached_balance_cents` integer, default `0`.
- `created_at` timestamp.
- `updated_at` timestamp.

The wallet balance must be derived from ledger transactions or reconciled to the ledger. `cached_balance_cents` is an optimization, not the authority.

### `wallet_transactions`

- `id` UUID, primary key.
- `wallet_id` UUID.
- `user_id` UUID.
- `type` enum: `credit_purchase`, `call_charge`, `refund`, `manual_adjustment`.
- `amount_cents` integer. Credits are positive, deductions are negative.
- `currency` text.
- `status` enum: `pending`, `posted`, `failed`, `reversed`.
- `provider` text, nullable: `stripe`, `revenuecat`, `apple`, `google`, `twilio`, `manual`.
- `provider_reference` text, nullable.
- `call_id` UUID, nullable.
- `metadata` jsonb.
- `created_at` timestamp.

Ledger rows are append-only. Do not update posted rows to change money movement; create reversal rows.

### `rates`

- `id` UUID, primary key.
- `country_code` text.
- `country_name` text.
- `prefix` text.
- `rate_per_minute_cents` integer.
- `billing_increment_seconds` integer.
- `minimum_charge_cents` integer.
- `currency` text.
- `status` enum: `active`, `blocked`, `unavailable`.
- `effective_at` timestamp.
- `updated_at` timestamp.

### `calls`

- `id` UUID, primary key.
- `user_id` UUID.
- `contact_id` UUID, nullable.
- `destination_number` text.
- `destination_country` text, nullable.
- `rate_id` UUID, nullable.
- `provider` text, default `twilio`.
- `provider_call_sid` text, nullable.
- `status` enum: `initiated`, `ringing`, `active`, `completed`, `failed`, `cancelled`.
- `failure_reason` text, nullable.
- `started_at` timestamp, nullable.
- `answered_at` timestamp, nullable.
- `ended_at` timestamp, nullable.
- `duration_seconds` integer, nullable.
- `billable_seconds` integer, nullable.
- `charge_cents` integer, nullable.
- `created_at` timestamp.
- `updated_at` timestamp.

### `contacts`

- `id` UUID, primary key.
- `user_id` UUID.
- `display_name` text.
- `phone_number` text.
- `normalized_phone_number` text.
- `source` enum: `manual`, `device_import`.
- `created_at` timestamp.
- `updated_at` timestamp.

### `support_tickets`

- `id` UUID, primary key.
- `user_id` UUID.
- `category` enum: `call`, `payment`, `account`, `other`.
- `subject` text.
- `message` text.
- `call_id` UUID, nullable.
- `wallet_transaction_id` UUID, nullable.
- `status` enum: `open`, `submitted`, `closed`.
- `created_at` timestamp.

## API / Server Function Design

All sensitive operations must run server-side.

### Auth

Supabase Auth handles:

- Send OTP.
- Verify OTP.
- Session refresh.
- Sign out.

Application functions handle:

- `complete_profile`
- `get_current_profile`
- `request_account_deletion`

### Wallet

- `GET /wallet`: returns balance and currency.
- `GET /wallet/transactions`: returns ledger history.
- `POST /wallet/purchase-intent`: creates a payment intent/order for a selected package.
- `POST /webhooks/payments`: verifies payment event and posts ledger credit.

### Rates

- `GET /rates?search=...`: searches country/prefix rates.
- `POST /rates/resolve`: normalizes a destination number and returns matched rate.

### Calling

- `POST /calls/preflight`: validates destination, balance, account status, and rate.
- `POST /calls/token`: returns short-lived Twilio Voice token after preflight.
- `POST /calls/start`: creates internal call row if not created by token flow.
- `POST /webhooks/twilio/voice-status`: handles Twilio status callbacks.
- `POST /calls/:id/finalize`: internal/admin-only fallback for reconciliation.

### Support

- `POST /support/tickets`: creates support ticket.
- `GET /support/context`: returns recent call/payment data for support UI.

## Authorization Rules

Use Supabase RLS for user-owned tables:

- Users can read and update their own `profiles` fields except status.
- Users can read their own wallet.
- Users can read their own wallet transactions.
- Users cannot insert wallet transactions directly.
- Users can read their own calls.
- Users cannot directly set final call charge.
- Users can CRUD their own manual contacts.
- Users can create support tickets for themselves.

Service-role functions only:

- Posting wallet transactions.
- Updating cached wallet balance.
- Creating payment intents.
- Verifying provider webhooks.
- Finalizing call charges.
- Suspending accounts.

## Security and Abuse Controls

MVP controls:

- OTP rate limiting.
- SMS country allowlist before broad launch.
- Destination country allowlist for calls.
- Minimum balance check before token issuance.
- Short-lived Twilio tokens.
- Server-side rate and charge calculation.
- Provider webhook signature verification.
- Idempotency keys for payment and call finalization.
- Append-only ledger with reversals.
- Store provider error codes in metadata, not as user-facing text.

Post-MVP controls:

- Device fingerprint/risk scoring.
- Velocity limits per account, phone, destination, and IP.
- Fraud review queue.
- KYC or enhanced verification if required by business/compliance model.

## Implementation Phases

### Phase 1: App Shell and Auth

- Create app project.
- Configure Supabase.
- Implement phone OTP sign in/sign up.
- Add profile completion.
- Add protected app shell.
- Hide `Messages` nav item.

Exit criteria:

- A new user can verify phone number and land on home.
- A returning user can sign in with OTP.
- Session persists across app restart.

### Phase 2: Wallet and Credits

- Create wallet schema and ledger.
- Add wallet screen.
- Add transaction history.
- Add purchase package UI.
- Integrate Stripe or RevenueCat sandbox.
- Add webhook verification.

Exit criteria:

- A confirmed payment posts exactly one wallet credit.
- Duplicate webhook delivery does not double-credit.
- User can see balance and transaction row.

### Phase 3: Rates and Dialing

- Create rate table.
- Add rate lookup.
- Add dial pad.
- Add destination normalization.
- Add pre-call cost check.
- Add insufficient balance state.

Exit criteria:

- User can enter an international number and see matched rate.
- Unsupported or blocked numbers cannot proceed.
- Low-balance users are routed to Add Credits.

### Phase 4: Twilio Calling

- Configure Twilio Voice.
- Add server-side call preflight.
- Generate short-lived Twilio Voice token.
- Place outbound call.
- Receive status callbacks.
- Finalize call history and wallet charge.

Exit criteria:

- User can complete a real outbound test call.
- Completed call creates a call history row.
- Wallet is charged once based on billable duration.

### Phase 5: Failure States, Settings, Support

- Add call failed screen.
- Add offline/weak connection banners.
- Add settings.
- Add support ticket creation.
- Add legal and emergency notice entries.
- Add account deletion request flow.

Exit criteria:

- Common call, payment, auth, and network failures have explicit UI.
- Support tickets include relevant call/payment context.

## Testing Plan

### Unit Tests

- Phone normalization.
- Rate matching.
- Billable duration calculation.
- Wallet balance derivation.
- Ledger reversal behavior.
- Failure reason mapping.

### Integration Tests

- OTP auth happy path.
- Payment webhook idempotency.
- Call preflight with enough balance.
- Call preflight with insufficient balance.
- Twilio status callback handling.
- Call finalization and wallet charge.

### Manual QA

- First-run signup.
- Returning signin.
- Bad OTP.
- Add credits success/failure/cancelled.
- Dial valid local number.
- Dial valid international number.
- Dial blocked country.
- Start call with low balance.
- Complete call.
- Dropped/failed call.
- Offline before call.
- Weak connection during active call.

## Initial Engineering Backlog

1. Choose app runtime: React Native, native iOS/Android, or web-first prototype.
2. Create Supabase project and local migration structure.
3. Add schema for profiles, wallets, wallet transactions, rates, calls, contacts, and support tickets.
4. Configure Supabase Auth with Twilio phone OTP.
5. Build OTP onboarding screens.
6. Build profile completion.
7. Build wallet ledger server functions.
8. Decide Stripe vs RevenueCat after payment policy review.
9. Build payment sandbox flow.
10. Build dial pad and rate preflight.
11. Configure Twilio Voice sandbox/test app.
12. Build call token function and active call integration.
13. Build Twilio status webhook and call charge finalization.
14. Build settings/support/failure states.

## Open Decisions Before Implementation

- Target platform for first implementation: React Native, native mobile, or web.
- Payment path: Stripe, RevenueCat/App Store IAP, or both with platform-specific behavior.
- Launch country/countries for users.
- Allowed destination countries for MVP.
- Initial credit packages.
- Emergency calling disclaimer copy and legal review owner.
- Refund and unused-credit policy.
