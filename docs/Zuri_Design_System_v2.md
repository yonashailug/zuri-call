# Zuri Design System v2.0

> **Flutter · iOS & Android · Confidential — Internal Use Only**
> Version 2.0 — Revised June 2026
> Supersedes v1.0 · All changes marked with ⚡

---

## What changed from v1.0

| # | Token / Component | v1.0 (wrong) | v2.0 (correct) | Reason |
|---|---|---|---|---|
| 1 | `contactName` typeface | DM Serif Display | **DM Sans** | Serif at 14sp too light for list density |
| 2 | `contactName` weight | Regular 400 | **Medium 500** | Matches native iOS Phone app visual weight |
| 3 | `contactName` size | 14sp | **15sp** | Compensates for sans-serif at list row density |
| 4 | `greetingName` typeface | DM Serif Display | **DM Serif Display** | Correct — kept, but now explicitly enforced |
| 5 | Icon button background | rgba(28,56,32,0.07) in CSS | **Color(0x121C3820)** | Pre-converted to Flutter hex — no ambiguity |
| 6 | Search bar radius | "12–14px" (range) | **14.0** (exact) | Ranges cause developer drift |
| 7 | Search bar height | "42dp" | **44.0** (exact) | Matches 44dp minimum touch target |
| 8 | Avatar colour map | Reference table only | **Dart function shipped** | Table alone is not implementable |
| 9 | Nav icon inactive colour | rgba(44,74,46,0.28) CSS | **Color(0x472C4A2E)** | Pre-converted Flutter hex |
| 10 | Row divider colour | rgba(28,56,32,0.06) CSS | **Color(0x0F1C3820)** | Pre-converted Flutter hex |
| 11 | `pillTruncation` | Not specified | **maxLength: 10 chars, firstName only** | Prevents "Seme (." broken truncation |
| 12 | `MissedCallBanner` | Not in spec | **Full component spec added** | Required by UX principle 02 |

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

> **Rule:** Every text widget MUST use a named `ZuriTypography` constant via `style: ZuriTypography.xxx`.
> Never pass inline `TextStyle()` in widget code.

### Typefaces

| Typeface | Role | Weights used | pubspec.yaml key |
|---|---|---|---|
| **DM Serif Display** | Display only | Regular 400 | `DM Serif Display` |
| **DM Sans** | All UI text | Light 300 · Regular 400 · Medium 500 | `DM Sans` |

### ⚡ Type scale — v2.0 corrected

| Token | Typeface | Size | Weight | Flutter constant | Used for |
|---|---|---|---|---|---|
| Screen title | DM Serif Display | `28sp` | w400 | `ZuriTypography.screenTitle` | "Wallet", "Contacts", "Dial" — page headings |
| Greeting name | DM Serif Display | `28sp` | w400 | `ZuriTypography.greetingName` | "Yonas" — personalised display moment |
| Balance / figure | DM Serif Display | `32sp` | w400 | `ZuriTypography.balanceLarge` | "$4.88", "04:23" — prominent data figures |
| ⚡ **Contact / call name** | **DM Sans** | **15sp** | **w500** | `ZuriTypography.contactName` | All list row primary labels — names and numbers |
| Button / CTA label | DM Sans | `14sp` | w500 | `ZuriTypography.btnPrimary` | "Call now", "Top up", "Pay" |
| Body / secondary | DM Sans | `12sp` | w400 | `ZuriTypography.bodyRegular` | Subtitles, phone numbers, descriptions |
| Metadata / caption | DM Sans | `11sp` | w300 | `ZuriTypography.caption` | Timestamps, durations, rates |
| Section label | DM Sans | `10sp` | w500 | `ZuriTypography.sectionLabel` | "TODAY", "FAVOURITES" — all caps, 0.1em tracking |
| Call timer | DM Sans | `20sp` | w300 | `ZuriTypography.callTimer` | "04:23" — tabular figures, active call screen |

### Typography rules

- **DM Serif Display** is for display-scale data (28sp+): screen titles, greeting name, balance, call timer
- **DM Sans** is for everything at list-row scale and below: contact names, subtitles, buttons, labels
- ⚡ **Revised rule (v2):** Contact names in list rows use DM Sans Medium 500 — DM Serif Display is too light at 14–15sp against the cream background
- Never mix typefaces within a single component
- Never hardcode `fontFamily` strings in widget code — always use `ZuriTypography` constants

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
| Primary | `50.0` | `25.0` | `ZuriColors.forest800` | `ZuriColors.cream` | `ZuriTypography.btnPrimary` |
| Secondary | `44.0` | `22.0` | `Colors.transparent` | `ZuriColors.forest800` with 0.7 | `ZuriTypography.btnPrimary` |
| End call | `58.0` circle | `29.0` | `ZuriColors.danger` | `Colors.white` | N/A |
| FAB | `48.0` circle | `24.0` | `ZuriColors.forest800` | `ZuriColors.cream` | N/A |
| ⚡ Icon button | `36.0` circle | `18.0` | `ZuriColors.iconButtonBg` | `ZuriColors.forest800` | N/A |
| In-call control | `58.0` | `20.0` | `Colors.white` with 0.08 | `ZuriColors.cream` with 0.7 | N/A |

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
| Placeholder style | `ZuriTypography.bodyRegular` colour `ZuriColors.searchPlaceholder` | — |
| Active text style | `ZuriTypography.bodyRegular` colour `ZuriColors.forest800` | — |
| Filter button size | `28.0 × 28.0`, radius `8.0`, bg `ZuriColors.neutralBg` | — |

### Status badges & pills

| Badge | Background | Border | Text style | Used for |
|---|---|---|---|---|
| Active call | `ZuriColors.successBg` | `1.0` `ZuriColors.success` 0.3 | `ZuriTypography.caption` `ZuriColors.success` | Live call + blink dot |
| On hold | `ZuriColors.warningBg` | `1.0` `ZuriColors.warning` 0.35 | `ZuriTypography.caption` `ZuriColors.warning` | Paused state |
| Muted | `ZuriColors.dangerBg` | `1.0` `ZuriColors.danger` 0.35 | `ZuriTypography.caption` `ZuriColors.danger` | Mic off |
| Call ended | `ZuriColors.neutralBg` | `1.0` `ZuriColors.forest800` 0.14 | `ZuriTypography.caption` `ZuriColors.subtitleText` | Summary screen |
| Filter — active | `ZuriColors.forest800` | `1.0` `ZuriColors.forest800` | `ZuriTypography.caption` `ZuriColors.cream` | Selected tab |
| Filter — inactive | `Colors.transparent` | `1.0` `ZuriColors.searchBorder` | `ZuriTypography.caption` `ZuriColors.subtitleText` | Unselected tab |
| Zuri member | `ZuriColors.neutralBg` | None | `ZuriTypography.caption` w500 `ZuriColors.forest800` | Free-call indicator |
| Most popular | `ZuriColors.warning` | None | `ZuriTypography.caption` w600 `#FAEEDA` | Top-up suggestion |

### Bottom navigation bar

```
Height:          56.0 + MediaQuery.of(context).padding.bottom
Background:      ZuriColors.cream
Top border:      1.0 width, ZuriColors.navBorderTop
FAB size:        48.0 circle, ZuriColors.forest800, offset: Offset(0, -18)
Tab icon size:   20.0
Tab icon inactive: ZuriColors.navIconInactive
Tab icon active: ZuriColors.forest800
Tab label style: ZuriTypography.sectionLabel (9sp, w500, same colour as icon)
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
Title:           "X missed call(s)" — ZuriTypography.contactName, ZuriColors.danger
Subtitle:        Contact name + time — ZuriTypography.caption, ZuriColors.danger 0.6
CTA button:      "Call back" — ZuriTypography.caption w600, ZuriColors.danger
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
Total height:        64.0
Horizontal padding:  20.0 (ZuriSpacing.s5)
Vertical padding:    10.0 top, 10.0 bottom

Avatar:
  size:              44.0 × 44.0
  shape:             circle (BoxShape.circle)
  colour:            ZuriAvatarColors.forInitial(contact.initial)
  right margin:      12.0

Text column (flex: 1):
  Name:
    style:           ZuriTypography.contactName  (DM Sans, 15sp, w500)
    colour:          ZuriColors.forest800
    overflow:        TextOverflow.ellipsis
    maxLines:        1
  Subtitle row (top margin 2.0):
    icon:            ti-phone-outgoing / ti-phone-incoming / ti-phone-missed
    icon size:       14.0
    icon colour:     ZuriColors.subtitleText (outgoing)
                     ZuriColors.success (incoming)
                     ZuriColors.danger (missed)
    gap after icon:  4.0
    text:            "Outgoing · 6s" or "Incoming · 2m 30s" or "Missed"
    style:           ZuriTypography.caption
    colour:          ZuriColors.subtitleText (outgoing/incoming)
                     ZuriColors.danger (missed — entire row tinted red)

Right column:
  Timestamp (top):
    style:           ZuriTypography.caption
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
Total height:        64.0
Horizontal padding:  20.0
Vertical padding:    10.0 top, 10.0 bottom

Avatar:              same as CallHistoryRow
Text column:
  Name:              ZuriTypography.contactName (DM Sans, 15sp, w500)
  Subtitle:          phone number or "● Online" + Zuri pill
                     ZuriTypography.caption, ZuriColors.subtitleText

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
  Call debit:        bg ZuriColors.neutralBg, icon ti-phone-outgoing forest800
  Top-up credit:     bg ZuriColors.successBg, icon ti-credit-card success

Text column:
  Primary:           ZuriTypography.contactName
  Subtitle:          ZuriTypography.caption, ZuriColors.subtitleText

Amount (right):
  Debit:             ZuriTypography.bodyRegular w500, ZuriColors.danger
  Credit:            ZuriTypography.bodyRegular w500, ZuriColors.success
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
// Zuri Design System v2.0
// Generated June 2026 — DO NOT edit inline values in widget code
// All colours, typography, spacing and dimensions must come
// from these constants. No exceptions.
// ============================================================

import 'package:flutter/material.dart';

// ── COLOURS ──────────────────────────────────────────────────

class ZuriColors {
  ZuriColors._();

  // Brand ramp
  static const cream    = Color(0xFFF2EAE3); // page background
  static const sand     = Color(0xFFD8CFC8); // dividers, borders
  static const stone    = Color(0xFFB5A99E); // disabled, placeholder
  static const bark     = Color(0xFF3A2E28); // secondary labels

  static const forest50  = Color(0xFFE8F4E9); // tint bg, Zuri pill
  static const forest200 = Color(0xFFA8CFA9); // light border
  static const forest400 = Color(0xFF4A8C50); // hover
  static const forest600 = Color(0xFF2D5E30); // active / pressed
  static const forest800 = Color(0xFF1C3820); // PRIMARY — CTAs, nav active
  static const forest900 = Color(0xFF0E1E10); // call screen deep bg

  // Semantic
  static const success   = Color(0xFF1C7A3E);
  static const successBg = Color(0x1A1C7A3E); // 10% opacity
  static const warning   = Color(0xFFB7651D);
  static const warningBg = Color(0x1AB7651D); // 10% opacity
  static const danger    = Color(0xFFC0392B);
  static const dangerBg  = Color(0x1AC0392B); // 10% opacity

  // ⚡ Opacity-derived — pre-converted (never use inline rgba)
  static const iconButtonBg    = Color(0x121C3820); // rgba(28,56,32, 0.07)
  static const rowDivider      = Color(0x0F1C3820); // rgba(28,56,32, 0.06)
  static const navIconInactive = Color(0x472C4A2E); // rgba(44,74,46, 0.28)
  static const searchBorder    = Color(0x1E1C3820); // rgba(28,56,32, 0.12)
  static const searchPlaceholder = Color(0x471C3820); // rgba(28,56,32, 0.28)
  static const subtitleText    = Color(0x731C3820); // rgba(28,56,32, 0.45)
  static const navBorderTop    = Color(0x141C3820); // rgba(28,56,32, 0.08)
  static const neutralBg       = Color(0x0F1C3820); // rgba(28,56,32, 0.06)
}

// ── AVATAR COLOURS ───────────────────────────────────────────

class ZuriAvatarColors {
  ZuriAvatarColors._();

  static const indigo      = Color(0xFF7B68D9); // A H O V
  static const coral       = Color(0xFFE74C3C); // B I P W
  static const teal        = Color(0xFF2E86AB); // C J Q X
  static const amber       = Color(0xFFD4845A); // D K R Y
  static const purple      = Color(0xFF8E44AD); // E L S Z
  static const forestGreen = Color(0xFF1C7A3E); // F M T
  static const red         = Color(0xFFC0392B); // G N U
  static const slate       = Color(0xFF546E7A); // numbers / symbols

  /// Returns the deterministic avatar colour for a given display name initial.
  /// Call as: ZuriAvatarColors.forInitial(contact.displayName)
  static Color forInitial(String displayName) {
    if (displayName.isEmpty) return slate;
    final ch = displayName.trim().toUpperCase()[0];
    switch (ch) {
      case 'A': case 'H': case 'O': case 'V': return indigo;
      case 'B': case 'I': case 'P': case 'W': return coral;
      case 'C': case 'J': case 'Q': case 'X': return teal;
      case 'D': case 'K': case 'R': case 'Y': return amber;
      case 'E': case 'L': case 'S': case 'Z': return purple;
      case 'F': case 'M': case 'T':           return forestGreen;
      case 'G': case 'N': case 'U':           return red;
      default:                                return slate;
    }
  }
}

// ── TYPOGRAPHY ───────────────────────────────────────────────

class ZuriTypography {
  ZuriTypography._();

  static const _serif = 'DM Serif Display';
  static const _sans  = 'DM Sans';

  // Display scale — DM Serif Display
  static const screenTitle = TextStyle(
    fontFamily: _serif, fontSize: 28, fontWeight: FontWeight.w400,
    color: ZuriColors.forest800, letterSpacing: -0.3,
  );
  static const greetingName = TextStyle(
    fontFamily: _serif, fontSize: 28, fontWeight: FontWeight.w400,
    color: ZuriColors.forest800, letterSpacing: -0.3,
  );
  static const balanceLarge = TextStyle(
    fontFamily: _serif, fontSize: 32, fontWeight: FontWeight.w400,
    color: ZuriColors.forest800, letterSpacing: -0.5,
  );
  static const callTimer = TextStyle(
    fontFamily: _sans, fontSize: 20, fontWeight: FontWeight.w300,
    color: ZuriColors.cream,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ⚡ List row scale — DM Sans (revised from v1)
  static const contactName = TextStyle(
    fontFamily: _sans, fontSize: 15, fontWeight: FontWeight.w500,
    color: ZuriColors.forest800,
  );

  // UI scale — DM Sans
  static const btnPrimary = TextStyle(
    fontFamily: _sans, fontSize: 14, fontWeight: FontWeight.w500,
    color: ZuriColors.cream, letterSpacing: 0.1,
  );
  static const bodyRegular = TextStyle(
    fontFamily: _sans, fontSize: 12, fontWeight: FontWeight.w400,
    color: ZuriColors.forest800,
  );
  static const caption = TextStyle(
    fontFamily: _sans, fontSize: 11, fontWeight: FontWeight.w300,
    color: ZuriColors.subtitleText,
  );
  static const sectionLabel = TextStyle(
    fontFamily: _sans, fontSize: 10, fontWeight: FontWeight.w500,
    color: ZuriColors.subtitleText, letterSpacing: 1.0,
  );
}

// ── SPACING ──────────────────────────────────────────────────

class ZuriSpacing {
  ZuriSpacing._();
  static const s1 =  4.0;
  static const s2 =  8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0; // screen horizontal padding
  static const s6 = 24.0;
  static const s8 = 32.0;
}

// ── DIMENSIONS ───────────────────────────────────────────────

class ZuriDimensions {
  ZuriDimensions._();
  static const rowHeight           = 64.0;
  static const searchBarHeight     = 44.0; // ⚡ was "42dp" in v1
  static const navHeight           = 56.0; // + MediaQuery bottom padding
  static const sectionHeaderHeight = 28.0;
  static const minTapTarget        = 44.0;
  static const fabOffset           = -18.0;
  static const fabSize             = 48.0;
  static const iconButtonSize      = 36.0;
  static const callBackBtnSize     = 32.0;
  static const avatarRowSize       = 44.0;
  static const avatarHeaderSize    = 36.0;
}

// ── BORDER RADII ─────────────────────────────────────────────

class ZuriRadius {
  ZuriRadius._();
  static const pill        = 25.0;
  static const card        = 12.0;
  static const input       = 14.0; // ⚡ was "12–14" range in v1
  static const key         = 18.0;
  static const badge       = 20.0;
  static const callAvatar  = 28.0;
  static const iconButton  =  8.0;
}
```

---

## Implementation checklist

Before opening a PR, every developer must verify:

- [ ] All colours reference `ZuriColors.*` — zero inline `Color(0xFF...)` in widget files
- [ ] All text widgets use `style: ZuriTypography.*` — zero inline `TextStyle()`
- [ ] Avatar colour uses `ZuriAvatarColors.forInitial(contact.displayName)` — never hardcoded
- [ ] Icon button background is `ZuriColors.iconButtonBg` — NOT teal, NOT `Colors.green`
- [ ] Icon button icon colour is `ZuriColors.forest800` — NOT teal
- [ ] Search bar height is `ZuriDimensions.searchBarHeight` (44.0), radius is `ZuriRadius.input` (14.0)
- [ ] `MissedCallBanner` renders above the list when `missedCalls.isNotEmpty`
- [ ] Quick-dial pills show `firstName` only, max 10 characters
- [ ] All fonts declared in `pubspec.yaml` under `flutter > fonts`
- [ ] `flutter clean && flutter pub get` run after any font or token change

---

*Zuri Design System v2.0 · Revised June 2026 · Confidential*
*Supersedes v1.0 — do not reference v1.0 for any new implementation*
