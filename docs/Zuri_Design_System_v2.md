# Zuri Design System v2.0

> **Flutter · iOS & Android · Confidential — Internal Use Only**
> Version 2.0 — Revised June 2026 (typography system updated)
> Supersedes v1.0 · All changes marked with ⚡

---

## What changed from v1.0

| # | Token / Component | v1.0 (wrong) | v2.0 (correct) | Reason |
|---|---|---|---|---|
| 1 | Typeface system | Custom bundled fonts | **Platform system font** | Matches native iOS/Android typography |
| 2 | Typography mapping | Visual token names | **Role-first tokens** | Prevents titles, metrics, rows, and chips from sharing accidental styles |
| 3 | Contact row title | `contactName` | **`contactRowTitle` / `recentRowTitle`** | Same visual value, stricter role semantics |
| 4 | Wallet title | `display` | **`pageTitle`** | Page titles must not use numeric metric tokens |
| 5 | Typography class | `ZuriTypography` | **`ZuriTextStyles`** | Renamed and expanded into role tokens |
| 6 | Token coverage | 9 tokens | **Strict semantic tokens** | Full coverage eliminates all `.copyWith(fontSize/fontWeight)` hacks |
| 7 | Icon button background | rgba(28,56,32,0.07) in CSS | **Color(0x121C3820)** | Pre-converted to Flutter hex — no ambiguity |
| 8 | Search bar radius | "12–14px" (range) | **14.0** (exact) | Ranges cause developer drift |
| 9 | Search bar height | "42dp" | **44.0** (exact) | Matches 44dp minimum touch target |
| 10 | Avatar colour map | Reference table only | **Dart function shipped** | Table alone is not implementable |
| 11 | Nav icon inactive colour | rgba(44,74,46,0.28) CSS | **Color(0x472C4A2E)** | Pre-converted Flutter hex |
| 12 | Row divider colour | rgba(28,56,32,0.06) CSS | **Color(0x0F1C3820)** | Pre-converted Flutter hex |
| 13 | `pillTruncation` | Not specified | **maxLength: 10 chars, firstName only** | Prevents "Seme (." broken truncation |
| 14 | `MissedCallBanner` | Not in spec | **Full component spec added** | Required by UX principle 02 |

---

## Table of Contents

1. [Colour System](#01-colour-system)
2. [Typography](#02-typography)
3. [Icon System](#03-icon-system)
4. [UI Components](#04-ui-components)
5. [Spacing System](#05-spacing-system)
6. [Row Component Specs](#06-row-component-specs)
7. [UX Principles](#07-ux-principles)
8. [Flutter Token Reference](#08-flutter-token-reference)

---

## 01 Colour System

> **Rule:** Every colour used in Flutter code MUST come from a named `ZuriColors` constant.
> Never write inline `Color(0xFF...)` or `Colors.xxx` in widget code. Always use the token.

### Brand palette

| Token | Hex | Flutter constant | Usage |
|---|---|---|---|
| Cream · Background | `#F2EAE3` | `ZuriColors.cream` | Page background, screen surface, nav bar |
| Sand · Dividers | `#D8CFC8` | `ZuriColors.sand` | Row dividers, borders, input borders |
| Stone · Disabled | `#B5A99E` | `ZuriColors.stone` | Disabled text, placeholder text, icons |
| Bark · Secondary text | `#3A2E28` | `ZuriColors.bark` | Secondary labels, subtitles |
| Forest-50 · Tint | `#E8F4E9` | `ZuriColors.forest50` | Tinted backgrounds, Zuri pill background |
| Forest-200 | `#A8CFA9` | `ZuriColors.forest200` | Light border, avatar ring |
| Forest-400 · Hover | `#4A8C50` | `ZuriColors.forest400` | Hover state, active secondary |
| Forest-600 · Active | `#2D5E30` | `ZuriColors.forest600` | Pressed state, strong border |
| Forest-800 · Primary | `#1C3820` | `ZuriColors.forest800` | CTAs, nav active, call screen background |
| Forest-900 · Deep | `#0E1E10` | `ZuriColors.forest900` | Active call background overlay |

### Semantic colours

| Role | Hex | Flutter constant | Background constant | Used for |
|---|---|---|---|---|
| Success | `#1C7A3E` | `ZuriColors.success` | `ZuriColors.successBg` | Online · Active call · Credit · Incoming |
| Warning | `#B7651D` | `ZuriColors.warning` | `ZuriColors.warningBg` | Low balance · On hold · Suggestion badge |
| Danger | `#C0392B` | `ZuriColors.danger` | `ZuriColors.dangerBg` | End call · Missed · Muted · Debit · Error |

### ⚡ Opacity-derived colours — pre-converted to Flutter hex

> **Critical:** CSS `rgba()` does NOT work in Flutter. Use these pre-converted constants only.
> Formula: Flutter alpha byte = round(opacity × 255), expressed as 2 hex digits prefixed to the colour.

| Token name | CSS equivalent | Flutter hex | Usage |
|---|---|---|---|
| `ZuriColors.iconButtonBg` | rgba(28,56,32, **0.07**) | `Color(0x**12**1C3820)` | Row call-back button, header icon button background |
| `ZuriColors.rowDivider` | rgba(28,56,32, **0.06**) | `Color(0x**0F**1C3820)` | Divider between contact/call rows |
| `ZuriColors.navIconInactive` | rgba(44,74,46, **0.28**) | `Color(0x**47**2C4A2E)` | Bottom nav inactive tab icons |
| `ZuriColors.searchBorder` | rgba(28,56,32, **0.12**) | `Color(0x**1E**1C3820)` | Search bar default border |
| `ZuriColors.searchPlaceholder` | rgba(28,56,32, **0.28**) | `Color(0x**47**1C3820)` | Search bar placeholder text |
| `ZuriColors.subtitleText` | rgba(28,56,32, **0.45**) | `Color(0x**73**1C3820)` | Row subtitle, metadata text |
| `ZuriColors.navBorderTop` | rgba(28,56,32, **0.08**) | `Color(0x**14**1C3820)` | Bottom nav top border |
| `ZuriColors.neutralBg` | rgba(28,56,32, **0.06**) | `Color(0x**0F**1C3820)` | Neutral / disabled backgrounds |

### Avatar colour system

Colour is assigned deterministically from the **first letter of the display name**.
The function `ZuriAvatarColors.forInitial(String initial)` must be used — never hardcode avatar colours.

| Colour name | Hex | Flutter constant | Letters |
|---|---|---|---|
| Indigo | `#7B68D9` | `ZuriAvatarColors.indigo` | A, H, O, V |
| Coral | `#E74C3C` | `ZuriAvatarColors.coral` | B, I, P, W |
| Teal | `#2E86AB` | `ZuriAvatarColors.teal` | C, J, Q, X |
| Amber | `#D4845A` | `ZuriAvatarColors.amber` | D, K, R, Y |
| Purple | `#8E44AD` | `ZuriAvatarColors.purple` | E, L, S, Z |
| Forest green | `#1C7A3E` | `ZuriAvatarColors.forestGreen` | F, M, T |
| Red | `#C0392B` | `ZuriAvatarColors.red` | G, N, U |
| Slate | `#546E7A` | `ZuriAvatarColors.slate` | Numbers / symbols / everything else |

---

## 02 Typography

> **Rule:** Every text widget MUST use a named `ZuriTextStyles` constant via `style: ZuriTextStyles.xxx`.
> Never pass inline `TextStyle()` in widget code. Never use `.copyWith(fontSize: ...)` or `.copyWith(fontWeight: ...)` — if no token fits, add one.

### ⚡ Typeface — platform system font

| Typeface | Role | Weights used | Flutter configuration |
|---|---|---|---|
| **Platform system font** | All UI text — every token | Light 300 · Medium 500 · SemiBold 600 · Bold 700 · ExtraBold 800 | No `fontFamily`; Flutter resolves to SF Pro on iOS and Roboto on Android |

Custom bundled fonts have been removed from the active type system. The app uses native platform typography for an iPhone Phone-style feel.

### ⚡ Type roles — strict semantic mapping

Tokens must be selected by UI role, not by visual size. Visual aliases from earlier versions remain in code only as deprecated compatibility aliases.

#### Page / state roles

| Token | Size | Weight | Height | Flutter constant | Used for |
|---|---|---|---|---|---|
| `pageTitle` | 30sp | w700 | 1.08 | `ZuriTextStyles.pageTitle` | Screen and subpage titles |
| `pageSubtitle` | 15sp | w600 | 1.25 | `ZuriTextStyles.pageSubtitle` | Header subtitles and descriptors |
| `greetingTitle` | 32sp | w700 | 1.0 | `ZuriTextStyles.greetingTitle` | Recents greeting name |
| `stateTitle` | 28sp | w700 | 1.1 | `ZuriTextStyles.stateTitle` | Empty states and in-call state titles |
| `compactPageTitle` | 24sp | w700 | 1.08 | `ZuriTextStyles.compactPageTitle` | Compact titles, call details, dialpad placeholders |

#### Metric / numeric roles

| Token | Size | Weight | Height | Flutter constant | Used for |
|---|---|---|---|---|---|
| `metricHero` | 52sp | w300 | 0.95 | `ZuriTextStyles.metricHero` | Wallet balance hero |
| `metricValue` | 34sp | w300 | 1.0 | `ZuriTextStyles.metricValue` | Balance figures, preset amounts, large numerics |
| `metricLabel` | 20sp | w700 | 1.0 | `ZuriTextStyles.metricLabel` | Wallet card sub-figures |
| `dialpadEntry` | 26sp | w600 | 1.0 | `ZuriTextStyles.dialpadEntry` | Dialpad number entry |
| `dialpadContext` | 16sp | w500 | 1.2 | `ZuriTextStyles.dialpadContext` | Dialpad country/contact context |
| `dialpadRate` | 16sp | w600 | 1.2 | `ZuriTextStyles.dialpadRate` | Dialpad rate text |
| `dialpadKey` | 24sp | w600 | 1.0 | `ZuriTextStyles.dialpadKey` | Dialpad key numerals |
| `callTimerText` | 22sp | w300 | — | `ZuriTextStyles.callTimerText` | Tabular call duration |
| `avatarDisplay` | 36sp | w300 | 1.0 | `ZuriTextStyles.avatarDisplay` | Large in-call avatar initials |

#### Top-up wallet roles

| Token | Size | Weight | Height | Flutter constant | Used for |
|---|---|---|---|---|---|
| `topUpTitle` | 26sp | w700 | 1.08 | `ZuriTextStyles.topUpTitle` | Top-up flow page title |
| `topUpBalanceLabel` | 14sp | w500 | 1.2 | `ZuriTextStyles.topUpBalanceLabel` | Current balance caption |
| `topUpBalanceValue` | 28sp | w700 | 1.0 | `ZuriTextStyles.topUpBalanceValue` | Current balance value |
| `topUpOptionAmount` | 26sp | w700 | 1.0 | `ZuriTextStyles.topUpOptionAmount` | Preset amount figures |
| `topUpOptionMinutes` | 13sp | w600 | 1.2 | `ZuriTextStyles.topUpOptionMinutes` | Preset minute estimates |
| `topUpBadge` | 13sp | w700 | 1.15 | `ZuriTextStyles.topUpBadge` | Most popular badge |
| `topUpFieldText` | 16sp | w700 | — | `ZuriTextStyles.topUpFieldText` | Custom amount and disabled add-payment labels |
| `topUpPaymentTitle` | 16sp | w700 | — | `ZuriTextStyles.topUpPaymentTitle` | Payment method title |
| `topUpPaymentSubtitle` | 14sp | w500 | 1.2 | `ZuriTextStyles.topUpPaymentSubtitle` | Payment method subtitle |
| `topUpSummaryLabel` | 14sp | w500 | — | `ZuriTextStyles.topUpSummaryLabel` | Top-up preview row labels |
| `topUpSummaryValue` | 15sp | w700 | — | `ZuriTextStyles.topUpSummaryValue` | Top-up preview row values |

#### Row / list roles

| Token | Size | Weight | Flutter constant | Used for |
|---|---|---|---|---|
| `contactRowTitle` | 16sp | w700 | `ZuriTextStyles.contactRowTitle` | Contact list primary labels |
| `contactRowSubtitle` | 14sp | w500 | `ZuriTextStyles.contactRowSubtitle` | Contact list secondary labels |
| `recentRowTitle` | 16sp | w700 | `ZuriTextStyles.recentRowTitle` | Recents row names |
| `recentRowSubtitle` | 14sp | w500 | `ZuriTextStyles.recentRowSubtitle` | Recents call metadata and timestamps |
| `walletTransactionAmount` | 16sp | w600 | `ZuriTextStyles.walletTransactionAmount` | Wallet activity/history debit and credit amounts |
| `settingsRowTitle` | 16sp | w700 | `ZuriTextStyles.settingsRowTitle` | Settings row labels |
| `cardTitle` | 16sp | w700 | `ZuriTextStyles.cardTitle` | Small cards and panels |
| `cardSubtitle` | 14sp | w500 | `ZuriTextStyles.cardSubtitle` | Small card secondary text |
| `rowTitle` | 18sp | w800 | `ZuriTextStyles.rowTitle` | Transaction/destination row titles, wallet history names |

#### Body / label roles

| Token | Size | Weight | Height | Flutter constant | Used for |
|---|---|---|---|---|---|
| `bodyText` | 16sp | w600 | 1.4 | `ZuriTextStyles.bodyText` | Primary copy |
| `supportingText` | 16sp | w600 | 1.4 | `ZuriTextStyles.supportingText` | Supporting/empty-state copy |
| `emphasisText` | 16sp | w800 | 1.45 | `ZuriTextStyles.emphasisText` | High-emphasis inline text |
| `metadata` | 14sp | w500 | 1.2 | `ZuriTextStyles.metadatadata` | Timestamps, durations, rate notes |
| `metadataStrong` | 14sp | w800 | 1.2 | `ZuriTextStyles.metadatadataStrong` | Strong metadata and metric captions |
| `chipLabel` | 15sp | w700 | — | `ZuriTextStyles.chipLabel` | Filter chips and quick-dial pills |
| `sectionCount` | 15sp | w700 | — | `ZuriTextStyles.sectionCount` | Section right-side counts |

#### Controls / navigation

| Token | Size | Weight | Letter-spacing | Flutter constant | Used for |
|---|---|---|---|---|---|
| `inputText` | 16sp | w700 | 0 | `ZuriTextStyles.inputText` | Text fields and input controls |
| `primaryButtonLabel` | 16sp | w700 | 0 | `ZuriTextStyles.primaryButtonLabel` | Primary CTAs |
| `strongButtonLabel` | 16sp | w800 | 0 | `ZuriTextStyles.strongButtonLabel` | High-emphasis CTAs |
| `secondaryButtonLabel` | 15sp | w700 | 0 | `ZuriTextStyles.secondaryButtonLabel` | Secondary CTAs |
| `sectionHeader` | 11sp | w800 | 1.0 | `ZuriTextStyles.sectionHeader` | Section headers, eyebrow labels, date groups |
| `navItemLabel` | 11sp | w700 | 0 | `ZuriTextStyles.navItemLabel` | Navigation bar tab labels |

### Typography rules

- **Platform system font only.** Do not set `fontFamily` in app typography tokens or widget code.
- **No `.copyWith(fontSize:)` or `.copyWith(fontWeight:)` in widget code.** If a size/weight combination isn't covered, add a token to `ZuriTextStyles`.
- **Color-only `.copyWith()` is permitted.** Example: `ZuriTextStyles.recentRowTitle.copyWith(color: ZuriColors.danger)`.
- **Height overrides are permitted** when a layout requires tighter or looser leading than the token default.
- Never hardcode `fontFamily` strings in widget code.

---

## 03 Icon System

**Library:** Tabler Icons — outline only.
**Package:** `tabler_icons_flutter` or equivalent — never use filled variants.

### Icon sizing

| Context | Size | Inactive colour token | Active colour token |
|---|---|---|---|
| Bottom nav tab | `20.0` | `ZuriColors.navIconInactive` | `ZuriColors.forest800` |
| In-call control | `22.0` | `ZuriColors.cream` with 0.65 opacity | `ZuriColors.cream` |
| Row inline indicator | `16.0` | `ZuriColors.subtitleText` | `ZuriColors.forest800` |
| Header icon button | `17.0` | `ZuriColors.forest800` | `ZuriColors.forest600` |
| Decorative / empty state | `30.0` | `ZuriColors.forest800` with 0.22 opacity | N/A |

### Icon inventory

#### Navigation
| Icon | Constant | Used for |
|---|---|---|
| `ti-clock` | `TablerIcons.clock` | Recents tab |
| `ti-users` | `TablerIcons.users` | Contacts tab |
| `ti-wallet` | `TablerIcons.wallet` | Wallet tab |
| `ti-settings` | `TablerIcons.settings` | Settings tab |
| `ti-phone-plus` | `TablerIcons.phone_plus` | FAB — new call |
| `ti-arrow-left` | `TablerIcons.arrow_left` | Back button |

#### Call states
| Icon | Constant | Colour token | Used for |
|---|---|---|---|
| `ti-phone` | `TablerIcons.phone` | `ZuriColors.forest800` | Call CTA in rows |
| `ti-phone-off` | `TablerIcons.phone_off` | `ZuriColors.danger` | End call button |
| `ti-phone-outgoing` | `TablerIcons.phone_outgoing` | `ZuriColors.subtitleText` | Outgoing history |
| `ti-phone-incoming` | `TablerIcons.phone_incoming` | `ZuriColors.success` | Incoming history |
| `ti-phone-missed` | `TablerIcons.phone_missed` | `ZuriColors.danger` | Missed call — red |
| `ti-phone-calling` | `TablerIcons.phone_calling` | `ZuriColors.forest800` | Dialling state |

#### In-call controls
| Icon | Constant | Used for |
|---|---|---|
| `ti-microphone` | `TablerIcons.microphone` | Unmuted |
| `ti-microphone-off` | `TablerIcons.microphone_off` | Muted — danger treatment |
| `ti-speakerphone` | `TablerIcons.speakerphone` | Speaker toggle |
| `ti-player-pause` | `TablerIcons.player_pause` | Hold |
| `ti-player-play` | `TablerIcons.player_play` | Resume — warning treatment |
| `ti-dialpad` | `TablerIcons.dialpad` | DTMF keypad |
| `ti-video` | `TablerIcons.video` | Video upgrade |
| `ti-bluetooth` | `TablerIcons.bluetooth` | BT audio |
| `ti-dots` | `TablerIcons.dots` | More options |
| `ti-backspace` | `TablerIcons.backspace` | Delete digit |
| `ti-wifi-off` | `TablerIcons.wifi_off` | Poor network — danger |

---

## 04 UI Components

> **Rule:** Every component listed below has exact pixel values. No ranges. No "approximately".

### Buttons

| Variant | Height | Radius | Background | Text colour | Text style |
|---|---|---|---|---|---|
| Primary | `62.0` | `ZuriRadius.pill` (22.0) | `ZuriColors.primary` | `ZuriColors.surface` | `ZuriTextStyles.primaryButtonLabel` |
| Secondary | `56.0` | `ZuriRadius.pill` (22.0) | `Colors.transparent` | `ZuriColors.muted` | `ZuriTextStyles.primaryButtonLabel` |
| Call / dial | `48.0` | `ZuriRadius.pill` | `ZuriColors.primary` | `ZuriColors.surface` | `ZuriTextStyles.primaryButtonLabel` |
| End call | `58.0` circle | `29.0` | `ZuriColors.danger` | `Colors.white` | N/A |
| FAB | `48.0` circle | `24.0` | `ZuriColors.primary` | `ZuriColors.surface` | N/A |
| Icon button | `36.0` circle | `ZuriRadius.iconButton` (18.0) | `ZuriColors.iconButtonBg` | `ZuriColors.ink` | N/A |
| In-call control | `58.0` | `20.0` | `ZuriColors.inCallControl` | `ZuriColors.inCallControlIcon` | N/A |

### Avatars

| Variant | Size | Shape | Radius | Badge |
|---|---|---|---|---|
| Header profile | `36.0` | Circle | `18.0` | Online dot: `9.0`, colour: `ZuriColors.success` |
| Contact / call row | `44.0` | Circle | `22.0` | Flag emoji `16.0` or Zuri-Z `15.0` |
| Favourite strip | `52.0` | Circle | `26.0` | Online `11.0` or Zuri-Z `14.0` |
| Active call | `100.0` | Rounded rect | `34.0` | Pulse rings (animated) |
| Call ended | `64.0` | Rounded rect | `20.0` | None |
| Unsaved contact | `44.0` | Circle, dashed border | `22.0` | None — use `ti-user-question` icon |

### ⚡ Search bar — exact values

| Property | Value | Token |
|---|---|---|
| Height | `44.0` | `ZuriDimensions.searchBarHeight` |
| Border radius | `14.0` | `ZuriRadius.input` |
| Background | `Colors.white` | — |
| Border (default) | `1.0` width, `ZuriColors.searchBorder` | — |
| Border (focused) | `1.5` width, `ZuriColors.forest800` | — |
| Leading icon | `ti-search`, `15.0`, `ZuriColors.searchPlaceholder` | — |
| Placeholder style | `ZuriTextStyles.bodyText` colour `ZuriColors.searchPlaceholder` | — |
| Active text style | `ZuriTextStyles.bodyText` colour `ZuriColors.forest800` | — |
| Filter button size | `28.0 × 28.0`, radius `8.0`, bg `ZuriColors.neutralBg` | — |

### Status badges & pills

| Badge | Background | Border | Text style | Used for |
|---|---|---|---|---|
| Active call | `ZuriColors.successBg` | `1.0` `ZuriColors.success` 0.3 | `ZuriTextStyles.metadata` `ZuriColors.success` | Live call + blink dot |
| On hold | `ZuriColors.warningBg` | `1.0` `ZuriColors.warning` 0.35 | `ZuriTextStyles.metadata` `ZuriColors.warning` | Paused state |
| Muted | `ZuriColors.dangerBg` | `1.0` `ZuriColors.danger` 0.35 | `ZuriTextStyles.metadata` `ZuriColors.danger` | Mic off |
| Call ended | `ZuriColors.neutralBg` | `1.0` `ZuriColors.forest800` 0.14 | `ZuriTextStyles.metadata` `ZuriColors.subtitleText` | Summary screen |
| Filter — active | `ZuriColors.forest800` | `1.0` `ZuriColors.forest800` | `ZuriTextStyles.metadata` `ZuriColors.cream` | Selected tab |
| Filter — inactive | `Colors.transparent` | `1.0` `ZuriColors.searchBorder` | `ZuriTextStyles.metadata` `ZuriColors.subtitleText` | Unselected tab |
| Zuri member | `ZuriColors.neutralBg` | None | `ZuriTextStyles.pageSubtitle` `ZuriColors.forest800` | Free-call indicator |
| Most popular | `ZuriColors.warning` | None | `ZuriTextStyles.metadata` `#FAEEDA` | Top-up suggestion |

### Bottom navigation bar

```
Height:          56.0 + MediaQuery.of(context).padding.bottom
Background:      ZuriColors.cream
Top border:      1.0 width, ZuriColors.navBorderTop
FAB size:        48.0 circle, ZuriColors.forest800, offset: Offset(0, -18)
Tab icon size:   20.0
Tab icon inactive: ZuriColors.navIconInactive
Tab icon active: ZuriColors.forest800
Tab label style: ZuriTextStyles.navItemLabel (9sp, w500, same colour as icon)
```

### ⚡ Quick-dial pill — truncation rule

```
Max display length:  10 characters
Content:             firstName only (split on space, take first token)
Overflow:            TextOverflow.ellipsis
Example:             "Seme (Dil Kursu)" → "Seme"
Example:             "Maya Kim" → "Maya"
Example:             "+251 91..." → "+251 91..." (truncate at 10 chars)
```

### ⚡ Missed call banner — new component in v2

```
Trigger:         Any call in history with status == CallStatus.missed
Position:        Above the section header, below the search bar
Background:      ZuriColors.dangerBg
Border:          1.0 width, ZuriColors.danger with 0.15 opacity
Border radius:   ZuriRadius.card (12.0)
Padding:         12.0 horizontal, 10.0 vertical
Leading icon:    ti-phone-missed, 16.0, ZuriColors.danger
Title:           "X missed call(s)" — ZuriTextStyles.recentRowTitle, ZuriColors.danger
Subtitle:        Contact name + time — ZuriTextStyles.metadata, ZuriColors.danger 0.6
CTA button:      "Call back" — ZuriTextStyles.primaryButtonLabel, ZuriColors.danger
                 bg: ZuriColors.danger with 0.1, radius: 8.0, padding: 4.0×10.0
```

---

## 05 Spacing System

**Base unit: 8.0**
All spacing values are in logical pixels (dp/sp).

| Token | Value | Flutter constant | Used for |
|---|---|---|---|
| `space-1` | `4.0` | `ZuriSpacing.s1` | Icon-to-label gap, tight internal padding |
| `space-2` | `8.0` | `ZuriSpacing.s2` | Row internal gaps, button icon gap |
| `space-3` | `12.0` | `ZuriSpacing.s3` | Card internal gap, component spacing |
| `space-4` | `16.0` | `ZuriSpacing.s4` | Card padding, section content inset |
| `space-5` | `20.0` | `ZuriSpacing.s5` | Screen horizontal padding — ALL screens |
| `space-6` | `24.0` | `ZuriSpacing.s6` | Major section separation |
| `space-8` | `32.0` | `ZuriSpacing.s8` | Page-level vertical breathing |

### Layout dimensions

| Element | Value | Flutter constant |
|---|---|---|
| Screen horizontal padding | `20.0` | `ZuriSpacing.s5` |
| Contact / call row height | `64.0` | `ZuriDimensions.rowHeight` |
| Bottom nav height | `56.0` + bottom safe area | `ZuriDimensions.navHeight` |
| Search bar height | `44.0` | `ZuriDimensions.searchBarHeight` |
| Section header height | `28.0` | `ZuriDimensions.sectionHeaderHeight` |
| Minimum tap target | `44.0 × 44.0` | `ZuriDimensions.minTapTarget` |
| FAB elevation offset | `-18.0` | `ZuriDimensions.fabOffset` |

### Border radii

| Token | Value | Flutter constant | Used for |
|---|---|---|---|
| Pill | `25.0` | `ZuriRadius.pill` | Primary/secondary buttons |
| Card | `12.0` | `ZuriRadius.card` | Cards, banners, sheet components |
| ⚡ Input | `14.0` | `ZuriRadius.input` | Search bar, text inputs |
| Dialpad key | `18.0` | `ZuriRadius.key` | Dial pad buttons |
| Badge | `20.0` | `ZuriRadius.badge` | Status pills, filter pills |
| Call avatar | `28.0` | `ZuriRadius.callAvatar` | Active call avatar |
| Avatar | `50%` | `BoxShape.circle` | All standard avatar shapes |

---

## 06 Row Component Specs

> These define the exact internal layout of the most-used list row components.
> Every measurement is exact — no ranges, no "approximately".

### CallHistoryRow

```
Total height:        72.0
Horizontal padding:  20.0 (ZuriSpacing.s5)
Vertical padding:    10.0 top, 10.0 bottom

Avatar:
  size:              44.0 × 44.0
  shape:             circle (BoxShape.circle)
  colour:            ZuriAvatarColors.forInitial(contact.initial)
  right margin:      12.0

Text column (flex: 1):
  Name:
    style:           ZuriTextStyles.recentRowTitle (system font, 16sp, w700)
    colour:          ZuriColors.forest800
    overflow:        TextOverflow.ellipsis
    maxLines:        1
  Subtitle row (top margin 2.0):
    icon:            arrow-up-right (outgoing) / arrow-down-left (incoming, missed)
    icon size:       16.0
    icon colour:     ZuriColors.subtitleText (outgoing)
                     ZuriColors.success (incoming)
                     ZuriColors.danger (missed)
    gap after icon:  6.0
    text:            "Outgoing · 6s" or "Incoming · 2m 30s" or "Missed"
    style:           ZuriTextStyles.recentRowSubtitle
    colour:          ZuriColors.subtitleText (outgoing/incoming)
                     ZuriColors.danger (missed — entire row tinted red)

Right column:
  Timestamp (top):
    style:           ZuriTextStyles.recentRowSubtitle
    colour:          ZuriColors.subtitleText
    alignment:       right
  Call-back button (bottom, top margin 4.0):
    size:            32.0 × 32.0
    shape:           circle
    background:      ZuriColors.iconButtonBg   ← MUST use this token
    icon:            TablerIcons.phone
    icon size:       15.0
    icon colour:     ZuriColors.forest800       ← MUST be forest800, NOT teal

Divider:
  colour:            ZuriColors.rowDivider
  thickness:         1.0
  indent:            76.0 (avatar width + left padding)
  endIndent:         0.0

Missed call row — additional overrides:
  name colour:       ZuriColors.danger
  call-back button bg: ZuriColors.dangerBg
  call-back icon colour: ZuriColors.danger
```

### ContactRow

```
Total height:        content height, 14.0 vertical padding
Horizontal padding:  20.0
Vertical padding:    10.0 top, 10.0 bottom

Avatar:              same as CallHistoryRow
Text column:
  Name:              ZuriTextStyles.contactRowTitle (system font, 16sp, w700)
  Subtitle:          phone number or "● Online" + Zuri pill
                     ZuriTextStyles.contactRowSubtitle, ZuriColors.subtitleText

Right column:
  Call button:       same as CallHistoryRow call-back button
  (Zuri contacts only) Message button:
    size:            32.0 circle, bg ZuriColors.iconButtonBg
    icon:            TablerIcons.message, 15.0, ZuriColors.forest800
    left margin:     6.0 from call button
```

### WalletTransactionRow

```
Total height:        56.0
Horizontal padding:  20.0
Vertical padding:    8.0 top, 8.0 bottom

Leading icon circle:
  size:              36.0 × 36.0, circle
  Call debit:        bg ZuriColors.neutralBg, icon arrow-up-right forest800
  Top-up credit:     bg ZuriColors.successBg, icon ti-credit-card success

Text column:
  Primary:           ZuriTextStyles.cardTitle
  Subtitle:          ZuriTextStyles.walletTransactionSubtitle, ZuriColors.subtitleText

Amount (right):
  Debit:             ZuriTextStyles.walletTransactionAmount, ZuriColors.danger
  Credit:            ZuriTextStyles.walletTransactionAmount, ZuriColors.success
```

---

## 07 UX Principles

### 01 · Colour encodes meaning, never decoration
Red = missed calls, muted, end call, debit. Green = online, active, credit. Amber = on hold, low balance.
Never use colour for visual interest alone.

### 02 · Progressive disclosure — urgent first
Missed calls render above the list via `MissedCallBanner`. Low balance banner at wallet top.
The most action-requiring information surfaces before browseable content.

### 03 · Every touch target is 44×44dp minimum
No exceptions. Includes call buttons in rows (32dp circle surrounded by 44dp GestureDetector).
Failing this causes mis-taps. Test on physical hardware.

### 04 · Never leave the user in a dead end
Every empty state has a primary action. Every error has a recovery path.
No results → offer "Dial as number" or "Add contact".

### 05 · Reduce cognitive load — translate data into meaning
Flag emoji replaces "+251" prefix. "~40 min" replaces "$4.88". "Missed · 23m ago" replaces undifferentiated rows.

### 06 · Inactive controls must look inactive
On-hold screen: mute, speaker, keypad at `opacity: 0.40`. Never leave interactive ambiguity.

### 07 · Surface trust signals at friction points
Lock icon on Pay button. Privacy note on contact sync. Transaction reference on top-ups.

### 08 · Contextual CTAs beat navigation
Rate lookup → "Call Ethiopia now". Call ended → "Call back". Each screen ends with the logical next action.

### 09 · WCAG 2.1 AA compliance throughout
4.5:1 contrast body text, 3:1 large text. All interactive elements have semantic labels.
Animations respect `prefers-reduced-motion` via `MediaQuery.of(context).disableAnimations`.

### 10 · Tone is warm, not clinical
"Your network" not "ALL CONTACTS". "Good morning" on empty screens. "~40 more minutes" not "$4.88".

---

## 08 Flutter Token Reference

```dart
// ============================================================
// zuri_tokens.dart
// Zuri Design System v2.0 (typography updated June 2026)
// DO NOT edit inline values in widget code.
// All colours, typography, spacing and dimensions must come
// from these constants. No exceptions.
// ============================================================

import 'package:flutter/material.dart';

// ── COLOURS ──────────────────────────────────────────────────

class ZuriColors {
  const ZuriColors._();

  // Brand ramp
  static const surface  = Color(0xFFF2EAE3); // cream — page background
  static const border   = Color(0xFFD8CFC8); // sand — dividers, borders
  static const disabled = Color(0xFFB5A99E); // stone — disabled, placeholder
  static const ink      = Color(0xFF1C3820); // primary — CTAs, text, nav active
  static const muted    = Color(0xFF9EA49A); // muted — subtitles, metadata
  static const card     = Color(0xFFFFFFFF); // card surface

  static const forest50  = Color(0xFFE8F4E9); // tint bg, call surface
  static const forest200 = Color(0xFFA8CFA9); // light border, avatar ring
  static const forest400 = Color(0xFF4A8C50); // accent, hover
  static const forest600 = Color(0xFF2D5E30); // active / pressed
  static const forest800 = Color(0xFF1C3820); // primary (alias for ink)
  static const forest900 = Color(0xFF0E1E10); // call screen deep bg

  static const accent    = forest400;
  static const primary   = ink;

  // Semantic
  static const success   = Color(0xFF1C7A3E);
  static const successBg = Color(0x1A1C7A3E); // 10% opacity
  static const warning   = Color(0xFFB7651D);
  static const warningBg = Color(0x1AB7651D); // 10% opacity
  static const danger    = Color(0xFFC0392B);
  static const dangerBg  = Color(0xFFFFEDEA);

  // Opacity-derived — pre-converted (never use inline rgba)
  static const iconButtonBg      = Color(0x121C3820); // rgba(28,56,32, 0.07)
  static const rowDivider        = Color(0xFFE2DAD3);
  static const navIconInactive   = Color(0x472C4A2E); // rgba(44,74,46, 0.28)
  static const searchBorder      = Color(0x1E1C3820); // rgba(28,56,32, 0.12)
  static const searchPlaceholder = Color(0xFFB9BFB7);
  static const subtitleText      = Color(0xFF9EA49A); // alias for muted
  static const navBorderTop      = Color(0x141C3820); // rgba(28,56,32, 0.08)
  static const neutralBg         = Color(0x0F1C3820); // rgba(28,56,32, 0.06)
  static const callSurface       = Color(0xFFE8F4E9); // forest50 alias

  // In-call screen colours
  static const inCallControl       = Color(0x14FFFFFF);
  static const inCallControlActive = Color(0x24FFFFFF);
  static const inCallControlIcon   = Color(0xB3F2EAE3);
  static const inCallAvatarFill    = Color(0xFF39533A);

  // Wallet colours
  static const walletCardMuted    = Color(0xFF91A08F);
  static const walletCardDivider  = Color(0xFF496748);
  static const walletActiveText   = Color(0xFF9ED18D);
  static const walletTipText      = Color(0xFF965616);
  static const walletTipBackground= Color(0xFFFFEBDD);
  static const walletTipBorder    = Color(0xFFEBC6A7);
  static const walletDebit        = Color(0xFFC0392D);
  static const walletPopular      = Color(0xFFB56B2C);

  // Legacy aliases
  static const cream = surface;
  static const sand  = border;
  static const stone = disabled;
  static const bark  = Color(0xFF3A2E28);
}

// ── AVATAR COLOURS ───────────────────────────────────────────

class ZuriAvatarColors {
  const ZuriAvatarColors._();

  static const indigo      = Color(0xFF7B68D9); // A H O V
  static const coral       = Color(0xFFE74C3C); // B I P W
  static const teal        = Color(0xFF2E86AB); // C J Q X
  static const amber       = Color(0xFFD4845A); // D K R Y
  static const purple      = Color(0xFF8E44AD); // E L S Z
  static const forestGreen = Color(0xFF1C7A3E); // F M T
  static const red         = Color(0xFFC0392B); // G N U
  static const slate       = Color(0xFF546E7A); // numbers / symbols

  /// Returns the deterministic avatar colour for a given display name initial.
  /// Usage: ZuriAvatarColors.forInitial(contact.initials)
  static Color forInitial(String initial) {
    final first = initial.trim().characters.take(1).toString().toUpperCase();
    return switch (first) {
      'A' || 'H' || 'O' || 'V' => indigo,
      'B' || 'I' || 'P' || 'W' => coral,
      'C' || 'J' || 'Q' || 'X' => teal,
      'D' || 'K' || 'R' || 'Y' => amber,
      'E' || 'L' || 'S' || 'Z' => purple,
      'F' || 'M' || 'T'        => forestGreen,
      'G' || 'N' || 'U'        => red,
      _                        => slate,
    };
  }
}

// ── TYPOGRAPHY ───────────────────────────────────────────────
// Platform system font only. Select tokens by UI role.

class ZuriTextStyles {
  const ZuriTextStyles._();

  static const pageTitle = TextStyle(fontSize: 30, fontWeight: FontWeight.w700);
  static const metricHero = TextStyle(fontSize: 52, fontWeight: FontWeight.w300);
  static const contactRowTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const recentRowSubtitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const primaryButtonLabel = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
}

// See lib/core/ui/zuri_tokens.dart for the complete source of truth.

// ── SPACING ──────────────────────────────────────────────────

class ZuriSpacing {
  const ZuriSpacing._();

  static const s1 =  4.0; // icon-to-label gap
  static const s2 =  8.0; // row internal gaps
  static const s3 = 12.0; // card internal / component gap
  static const s4 = 16.0; // card padding / section inset
  static const s5 = 20.0; // screen horizontal padding — ALL screens
  static const s6 = 24.0; // major section separation
  static const s8 = 32.0; // page-level vertical breathing

  static const screen        = EdgeInsets.fromLTRB(s5, 32, s5, 32);
  static const screenCompact = EdgeInsets.fromLTRB(s5, 12, s5, 32);
}

// ── DIMENSIONS ───────────────────────────────────────────────

class ZuriDimensions {
  const ZuriDimensions._();

  static const callBackBtnSize       = 32.0;
  static const searchBarHeight       = 44.0;
  static const avatarRowSize         = 44.0;
  static const iconButtonSize        = 36.0;
  static const quickDialHeight       = 56.0;
  static const recentRowHeight       = 64.0;
  static const dialpadActionSize     = 44.0;
  static const primaryButtonHeight   = 62.0;
  static const secondaryButtonHeight = 56.0;
  static const callButtonHeight      = 48.0;
  static const navHeight             = 56.0;
  static const quickDialNameMaxLength = 10;
}

// ── BORDER RADII ─────────────────────────────────────────────

class ZuriRadius {
  const ZuriRadius._();

  static const pill       = 22.0; // pill buttons
  static const card       = 12.0; // standard surface / card
  static const input      = 14.0; // search bar, text inputs
  static const key        = 18.0; // dialpad keys
  static const badge      = 20.0; // status badges / pills
  static const callAv     = 28.0; // call screen avatar (rounded rect)
  static const iconButton = 18.0; // 36dp circular icon buttons
  static const compact    =  7.0; // small wallet/inset controls
  static const small      =  8.0; // tiny rounded surfaces
  static const action     = 13.0; // compact CTA buttons
  static const surface    = 16.0; // medium cards / selectable rows
  static const tile       = 18.0; // content tiles
  static const round      = 999.0;// fully rounded pills
  static const modal      = 30.0; // bottom sheet modal
}
```

---

## Implementation checklist

Before opening a PR, every developer must verify:

- [ ] All colours reference `ZuriColors.*` — zero inline `Color(0xFF...)` in widget files
- [ ] All text widgets use `style: ZuriTextStyles.*` — zero inline `TextStyle()`
- [ ] No `.copyWith(fontSize: ...)` or `.copyWith(fontWeight: ...)` in widget code — use a named token
- [ ] Avatar colour uses `ZuriAvatarColors.forInitial(contact.initials)` — never hardcoded
- [ ] Icon button background is `ZuriColors.iconButtonBg` — NOT teal, NOT `Colors.green`
- [ ] Icon button icon colour is `ZuriColors.ink` — NOT teal
- [ ] Search bar height is `ZuriDimensions.searchBarHeight` (44.0), radius is `ZuriRadius.input` (14.0)
- [ ] `MissedCallBanner` renders above the list when `missedCalls.isNotEmpty`
- [ ] Quick-dial pills show `firstName` only, max `ZuriDimensions.quickDialNameMaxLength` (10) characters
- [ ] All fonts declared in `pubspec.yaml` under `flutter > fonts`
- [ ] `flutter analyze --no-pub` returns zero issues after any token or theme change

---

*Zuri Design System v2.0 · Revised June 2026 · Confidential*
*Supersedes v1.0 — do not reference v1.0 for any new implementation*
