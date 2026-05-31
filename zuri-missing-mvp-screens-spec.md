# Zuri Missing MVP Screens Spec

This spec defines the missing MVP screens for the Zuri VoIP app design in `zuri_voip_light_dark_themes.html`. The current HTML covers welcome, contacts home, and active call screens in light and dark themes. The first production implementation is a Flutter mobile app focused on the light theme first. The screens below complete the onboarding, calling, billing, account, and error flows needed for a production MVP. Product scope, backend design, provider choices, and implementation phases are defined in `zuri-mvp-product-dev-spec.md`.

## Design Baseline

Use the existing visual system:

- Phone frame width: `280px`
- Rounded app frame with light theme as the MVP production target
- Font pairing: `DM Sans` for UI text, `Syne` for brand and major names
- Primary action gradient: indigo to purple
- Dark background: `#0B0B14`
- Light background: `#F7F6FF` or `#F0EEFF` for call-adjacent screens
- Bottom navigation style from the home screen
- Icon style: Tabler icons via `ti` classes
- Every new screen should be implemented in light theme first. Keep color and typography tokens compatible with a later dark theme.

## Screen 1: Create Account

Purpose: Let a new user register before using calling and billing features.

Entry point:
- Welcome screen `Create account` button

Primary content:
- Header: `Create account`
- Supporting text: short trust-oriented line, for example `Start calling over Wi-Fi or mobile data`
- Full name input
- Email or phone input
- Password input if using password auth
- Primary button: `Create account`
- Secondary text action: `Already have an account? Sign in`
- Terms/privacy consent row

States:
- Empty form
- Invalid email or phone
- Weak password
- Duplicate account
- Loading while creating account

UX notes:
- Keep the layout centered and calm like the welcome screen.
- Use stacked inputs with 12-14px radius to match the search field and buttons.

## Screen 2: Sign In

Purpose: Let returning users access their account, balance, contacts, and call history.

Entry point:
- Welcome screen `Sign in` button

Primary content:
- Header: `Welcome back`
- Email or phone input
- Password input or OTP option
- Primary button: `Sign in`
- Secondary action: `Create account`
- Text action: `Forgot password?`

States:
- Invalid credentials
- Account locked or suspended
- Loading
- Network failure

UX notes:
- Reuse the create account form structure.
- Keep error text short and close to the relevant input.

## Screen 3: Verification

Purpose: Verify phone or email ownership before enabling credit purchases or calling.

Entry point:
- After create account
- After sign in when verification is required

Primary content:
- Header: `Verify your account`
- Destination text: `Enter the code sent to ...`
- 4-6 digit OTP input
- Primary button: `Verify`
- Secondary action: `Resend code`
- Text action: `Change email or phone`

States:
- Code sent
- Resend countdown
- Incorrect code
- Expired code
- Too many attempts
- Verified success

UX notes:
- Use large separated code boxes or one centered numeric input.
- Show throttling clearly to reduce support issues.

## Screen 4: Dial Pad

Purpose: Let users manually enter phone numbers, especially international numbers.

Entry point:
- Center bottom nav floating phone button
- Contact call button when editing number before call

Primary content:
- Entered number display
- Country code selector or country prefix chip
- Numeric keypad
- Delete/backspace action
- Primary call button
- Add contact action
- Optional rate preview row

States:
- Empty number
- Invalid number
- Valid number
- Low balance before call
- Offline

UX notes:
- This is a core screen and should feel as polished as the active call screen.
- Use stable keypad dimensions so the layout does not shift while typing.

## Screen 5: Wallet / Balance

Purpose: Let users see their available calling credit and access top-up and transaction history.

Entry point:
- Settings
- Home header balance pill if added
- Low balance prompts

Primary content:
- Current balance
- Available minutes estimate for common/recent destinations if available
- Primary button: `Add credits`
- Secondary action: `Transaction history`
- Small note about calls being charged per destination rate

States:
- Balance loading
- Balance unavailable
- Zero balance
- Low balance

UX notes:
- Balance should be visually prominent but not oversized.
- Use clear currency formatting.

## Screen 6: Buy Credits

Purpose: Let users purchase call credit through the approved payment flow.

Entry point:
- Wallet `Add credits`
- Low balance prompt
- Insufficient balance screen

Primary content:
- Header: `Add credits`
- Current balance
- Credit packages, for example `$5`, `$10`, `$20`, `$50`
- Selected package state
- Primary button: `Continue`
- Payment terms / tax note if needed

States:
- Package selected
- Purchase processing
- Purchase successful
- Purchase cancelled
- Purchase failed
- Purchase pending

UX notes:
- Credit packages should be simple cards or segmented buttons.
- Make the selected amount obvious in the light theme.

## Screen 7: Transaction History

Purpose: Show credit purchases, call charges, refunds, and manual adjustments.

Entry point:
- Wallet
- Settings

Primary content:
- List of transactions
- Amount
- Transaction type
- Date/time
- Status
- Reference ID on detail view

Transaction types:
- Credit purchase
- Call charge
- Refund
- Manual adjustment

States:
- Empty history
- Loading
- Failed to load
- Filtered by type if needed later

UX notes:
- Positive amounts should be visually distinct from deductions.
- Keep rows compact and readable.

## Screen 8: Rate Lookup

Purpose: Let users check calling rates before placing international calls.

Entry point:
- Wallet
- Dial pad rate preview
- Settings

Primary content:
- Search input for country or prefix
- Country list
- Country flag or initials
- Prefix
- Per-minute rate
- Billing increment if applicable
- Last updated timestamp

States:
- Loading rates
- Empty search result
- Rates unavailable
- Country blocked or unsupported

UX notes:
- This should look similar to the contacts list, but with rate data replacing phone numbers.

## Screen 9: Pre-Call Cost Check

Purpose: Confirm cost and available minutes before placing a call, especially for international or expensive destinations.

Entry point:
- Dial pad call button
- Contact call button

Primary content:
- Destination number
- Matched destination country/prefix
- Rate per minute
- Current balance
- Estimated available minutes
- Primary button: `Call now`
- Secondary action: `Add credits`

States:
- Enough balance
- Low balance
- Insufficient balance
- Rate unavailable
- Blocked destination

UX notes:
- This can be a bottom sheet or compact confirmation screen.
- Do not interrupt every call if the destination is recent and balance is clearly sufficient.

## Screen 10: Insufficient Balance

Purpose: Block calls that cannot be funded and guide users to top up.

Entry point:
- Dial pad
- Pre-call cost check
- Provider balance validation response

Primary content:
- Header: `Not enough credit`
- Current balance
- Required minimum or estimated first-minute cost
- Primary button: `Add credits`
- Secondary action: `Cancel`

States:
- Balance refresh available
- Payment pending

UX notes:
- Keep the tone direct and non-alarming.
- Always offer a path back to the dial pad.

## Screen 11: Call Failed

Purpose: Explain why a call did not connect and offer the right next action.

Entry point:
- Failed outbound call attempt
- Dropped call before connection

Primary content:
- Header: `Call failed`
- Destination number or contact
- Failure reason
- Primary action based on reason
- Secondary action: `Try again`
- Support link for repeated failures

Failure reasons:
- No internet connection
- Weak connection
- Invalid number
- Destination unavailable
- Destination blocked
- Not enough credit
- Provider error

UX notes:
- Make the reason specific when the backend/provider can supply one.
- For provider errors, avoid exposing internal codes as primary text.

## Screen 12: Connection Problem

Purpose: Handle offline and weak connection states before and during calls.

Entry point:
- App launch
- Dial pad
- Active call
- Failed call

Primary content:
- Connection status
- Short explanation
- Retry action
- Optional action: `Switch network`

States:
- Offline
- Weak Wi-Fi
- Switching networks
- Reconnected

UX notes:
- For an active call, use a compact banner instead of replacing the whole call screen.
- For pre-call, block the call button until a usable connection returns.

## Screen 13: Settings

Purpose: Let users manage account, privacy, support, and app preferences.

Entry point:
- Bottom nav `Settings`

Primary content:
- Account profile summary
- Balance row
- Payment / wallet row
- Rates row
- Support row
- Privacy policy row
- Terms of service row
- Emergency calling notice row
- Theme preference if supported
- Sign out
- Delete account

States:
- Signed in
- Loading profile
- Failed to load account

UX notes:
- Use compact rows with icons.
- Reserve destructive styling only for sign out and delete account.

## Screen 14: Delete Account Confirmation

Purpose: Confirm account deletion and explain consequences.

Entry point:
- Settings `Delete account`

Primary content:
- Header: `Delete account?`
- Explanation that call history, account data, and remaining credit handling may be affected
- Confirmation input or checkbox if required
- Destructive button: `Delete account`
- Secondary button: `Cancel`

States:
- Confirmation required
- Deleting
- Delete failed
- Delete completed

UX notes:
- This should be a modal or dedicated confirmation screen.
- Do not place destructive action next to the cancel action without clear spacing.

## Screen 15: Support

Purpose: Give users a route to resolve call, payment, and account problems.

Entry point:
- Settings
- Call failed
- Transaction detail

Primary content:
- Help categories
- Contact support action
- Recent call issue shortcut
- Recent payment issue shortcut
- App version
- Account ID or support ID

States:
- Support request draft
- Submitted
- Failed to submit

UX notes:
- Support should include enough diagnostic context to reduce manual back-and-forth.

## Recommended Build Order

1. Create account, sign in, verification
2. Dial pad
3. Wallet, buy credits, transaction history
4. Rate lookup and pre-call cost check
5. Insufficient balance, call failed, connection problem states
6. Settings, delete account, support

## Open Product Decisions

- Confirm payment path after policy review: Stripe, RevenueCat/App Store IAP, or platform-specific behavior.
- Confirm launch countries for users and allowed destination countries for calls.
- Confirm initial credit packages.
- Confirm emergency calling disclaimer and legal review owner.
- How should unused credit be handled during account deletion?
