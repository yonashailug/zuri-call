# Zuri Design System v1.0

> **Flutter · iOS & Android · Confidential — Internal Use Only**
> Typography · Colour · Icons · UI Components · Spacing · UX Principles

---

## Table of Contents

1. [Colour System](#01-colour-system)
2. [Typography](#02-typography)
3. [Icon System](#03-icon-system)
4. [UI Components](#04-ui-components)
5. [Spacing System](#05-spacing-system)
6. [UX Principles](#06-ux-principles)

---

## 01 Colour System

### Brand palette

| Token | Hex | Usage |
|---|---|---|
| Cream · Background | `#F2EAE3` | Page background, screen surface, nav bar |
| Sand · Dividers | `#D8CFC8` | Row dividers, borders, input borders |
| Stone · Disabled | `#B5A99E` | Disabled text, placeholder text, icons |
| Bark · Secondary text | `#3A2E28` | Secondary labels, subtitles |
| Forest-50 · Tint | `#E8F4E9` | Tinted backgrounds, Zuri pill background |
| Forest-200 | `#A8CFA9` | Light border, avatar ring |
| Forest-400 · Hover | `#4A8C50` | Hover state, active secondary |
| Forest-600 · Active | `#2D5E30` | Pressed state, strong border |
| Forest-800 · Primary | `#1C3820` | CTAs, nav active, call screen background |
| Forest-900 · Deep | `#0E1E10` | Active call background overlay |

### Semantic colours

| Role | Hex | Background | Used for |
|---|---|---|---|
| Success | `#1C7A3E` | `rgba(28,120,62,0.10)` | Online · Active call · Credit · Incoming |
| Warning | `#B7651D` | `rgba(183,101,29,0.10)` | Low balance · On hold · Suggestion badge |
| Danger | `#C0392B` | `rgba(192,57,43,0.10)` | End call · Missed · Muted · Debit · Error |
| Neutral | `rgba(28,56,32,0.50)` | `rgba(28,56,32,0.06)` | Secondary text · Disabled state · Muted icons |

### Avatar colour system

Colour is assigned deterministically from the first letter of the display name — always consistent across devices and sessions.

| Colour name | Hex | Letters |
|---|---|---|
| Indigo | `#7B68D9` | A, H, O, V |
| Coral | `#E74C3C` | B, I, P, W |
| Teal | `#2E86AB` | C, J, Q, X |
| Amber | `#D4845A` | D, K, R, Y |
| Purple | `#8E44AD` | E, L, S, Z |
| Forest green | `#1C7A3E` | F, M, T |
| Red | `#C0392B` | G, N, U |
| Slate | `#546E7A` | Numbers / symbols |

---

## 02 Typography

### Typefaces

| Typeface | Role | Weights | Used for |
|---|---|---|---|
| **DM Serif Display** | Display | Regular 400 | Screen titles, balance figures, hero caller name, section headings |
| **DM Sans** | UI text | Light 300 · Regular 400 · Medium 500 | Contact/call list names, buttons, labels, metadata, captions, section labels, status text, all interactive elements |

### Type scale

| Role | Typeface | Size | Weight | Used for |
|---|---|---|---|---|
| Screen title | DM Serif Display | `28sp` | Regular | Wallet, Contacts, Dial, Settings |
| Balance / figure | DM Serif Display | `22–32sp` | Regular | $4.88, 04:23, Yonas Hailu (greeting) |
| Contact / call name | DM Sans | `15sp` | Medium 500 | All contact, recent call, and quick-dial primary labels |
| Button / CTA label | DM Sans | `13–15sp` | Medium 500 | Primary and secondary action buttons |
| Body / secondary label | DM Sans | `12sp` | Regular 400 | Subtitles, phone numbers, descriptions |
| Metadata / caption | DM Sans | `10–11sp` | Light 300 | Timestamps, durations, per-minute rates |
| Section label | DM Sans | `10sp` | Medium 500 · CAPS · 0.1em tracking | TODAY, FAVOURITES, RECENT CALLS |

### Typography rules

- **DM Serif Display** is for high-emphasis display data — balances, screen titles, hero caller names, call duration
- **DM Sans** is for dense native-feeling UI and list content — contact names, recent call names, buttons, labels, metadata, section headers
- Rule: display/hero data → serif; list and control UI → sans
- Never use DM Serif for buttons, labels, or captions
- Never use DM Serif for contact list or recent-call row names; use DM Sans Medium 500 at 15sp

---

## 03 Icon System

**Library:** Tabler Icons — outline style only. Never use `-filled` variants. Never mix in custom SVG paths or other icon libraries.

### Icon sizing rules

| Context | Size | Colour — inactive | Colour — active |
|---|---|---|---|
| Bottom navigation tab | `20px` | `rgba(44,74,46,0.28)` | `#1C3820` |
| In-call control button | `22px` | `rgba(242,234,227,0.65)` | `#F2EAE3` |
| Row inline indicator | `16px` | `rgba(28,56,32,0.40)` | `#1C3820` / `#C0392B` |
| Header icon button | `17px` | `#1C3820` | `#1C3820` darker |
| Decorative / empty state | `28–32px` | `rgba(28,56,32,0.22)` | N/A |

### Icon inventory

#### Navigation

| Icon | Used for |
|---|---|
| `ti-clock` | Recents tab |
| `ti-users` | Contacts tab |
| `ti-wallet` | Wallet tab |
| `ti-settings` | Settings tab |
| `ti-phone-plus` | Centre FAB — start new call |
| `ti-arrow-left` | Back button on sub-screens |

#### Call states

| Icon | Used for |
|---|---|
| `ti-phone` | Call CTA in contact rows and ended summary |
| `ti-phone-off` | End call button (danger red) |
| `ti-phone-outgoing` | Outgoing call indicator in history |
| `ti-phone-incoming` | Incoming call indicator in history |
| `ti-phone-missed` | Missed call indicator (red) |
| `ti-phone-calling` | Dialling / ringing state |

#### In-call controls

| Icon | Used for |
|---|---|
| `ti-microphone` | Mic active / unmuted |
| `ti-microphone-off` | Mic muted — red treatment |
| `ti-speakerphone` | Speaker / earpiece toggle |
| `ti-player-pause` | Hold call |
| `ti-player-play` | Resume from hold — amber treatment |
| `ti-dialpad` | Open DTMF keypad overlay |
| `ti-video` | Video call upgrade |
| `ti-bluetooth` | Bluetooth audio device |
| `ti-dots` | More options |
| `ti-backspace` | Delete last dialled digit |
| `ti-wifi-off` | Poor network warning |

#### Contacts & UI

| Icon | Used for |
|---|---|
| `ti-user-plus` | Add contact — headers and rows |
| `ti-user-question` | Unsaved contact avatar placeholder |
| `ti-search` | Search bar leading icon |
| `ti-adjustments-horizontal` | Filter button in search bar |
| `ti-x` | Clear search / dismiss |
| `ti-lock` | Security signal on payment button |
| `ti-credit-card` | Payment method icon |
| `ti-world` | Rates lookup button |
| `ti-download` | Export transaction history |
| `ti-check` | Selected state — payment method |
| `ti-bulb` | Predictive tip / insight banner |
| `ti-alert-triangle` | Warning — poor network, low balance |

---

## 04 UI Components

### Buttons

| Variant | Height | Radius | Background | Text colour | Usage |
|---|---|---|---|---|---|
| Primary | `46–50dp` | `22px` pill | `#1C3820` | `#F2EAE3` | Main CTA — Call now, Pay, Continue |
| Secondary | `38–44dp` | `22px` pill | Transparent | `rgba(28,56,32,.7)` | Alternative — Add contact, Import |
| End call | `58dp` circle | `50%` | `#C0392B` | `#FFFFFF` | Terminate active call |
| FAB | `44–48dp` circle | `50%` | `#1C3820` | `#F2EAE3` | New call — elevated –18dp above nav |
| Icon button | `32–36dp` circle | `50%` | `rgba(28,56,32,.07)` | `#1C3820` | Header actions — add, search, back |
| In-call control | `56–58dp` | `18–20px` | `rgba(255,255,255,.08)` | `rgba(242,234,227,.70)` | Mute, speaker, hold, keypad |
| Danger text | `32dp` | `8px` | Transparent | `#C0392B` | Report quality, destructive actions |

### Avatars

| Variant | Size | Shape | Badge | Context |
|---|---|---|---|---|
| Header profile | `36dp` | Circle 50% | Online dot `9dp` green | Screen header — own profile |
| Contact list | `42–44dp` | Circle 50% | Flag `16dp` or Zuri-Z `15dp` | Contact and recent rows |
| Favourite strip | `48–52dp` | Circle 50% | Online `11dp` or Zuri-Z `14dp` | Horizontal recent strip |
| Active call | `80–100dp` | Rounded rect `26–34px` | Pulse rings (animated) | Call screen centre piece |
| Call ended | `64dp` | Rounded rect `20px` | None | Call summary screen |
| Unsaved contact | `42dp` | Circle · dashed border | None — shows `ti-user-question` | Unsaved number rows |

### Input — search bar

| Property | Value |
|---|---|
| Height | `42dp` |
| Border radius | `12–14px` |
| Background | `#FFFFFF` |
| Border — default | `1px solid rgba(28,56,32,0.12)` |
| Border — active | `1.5px solid #1C3820` |
| Leading icon | `ti-search` · `15px` · `rgba(28,56,32,0.30)` |
| Placeholder text | DM Sans 400 · `13sp` · `rgba(28,56,32,0.28)` |
| Active text | DM Sans 400 · `13sp` · `#1C3820` |
| Filter button | `28×28dp` · `8px` radius · `rgba(28,56,32,0.06)` bg |

### Status badges & pills

| Badge | Background | Border | Text colour | Used for |
|---|---|---|---|---|
| Active call | `rgba(76,175,80,0.15)` | `1px rgba(76,175,80,0.30)` | `#1C5C30` | Live call status + blinking dot |
| On hold | `rgba(183,101,29,0.18)` | `1px rgba(183,101,29,0.35)` | `#8C4D0A` | Call paused state |
| Muted | `rgba(192,57,43,0.20)` | `1px rgba(192,57,43,0.35)` | `#8C2A1E` | Microphone off state |
| Call ended | `rgba(28,56,32,0.07)` | `1px rgba(28,56,32,0.14)` | `rgba(28,56,32,.55)` | Post-call summary |
| Filter pill — active | `#1C3820` | `1px #1C3820` | `#F2EAE3` | Selected tab filter |
| Filter pill — inactive | Transparent | `1px rgba(28,56,32,.12)` | `rgba(28,56,32,.5)` | Unselected tab filter |
| Zuri member | `rgba(28,56,32,0.07)` | None | `#1C3820` Bold | Free-call indicator on contact |
| Most popular | `#B7651D` | None | `#FAEEDA` Bold | Top-up amount suggestion |

### Bottom navigation bar

```
Height:        56dp + safe area inset (iOS: +34dp home indicator)
Background:    #F2EAE3 with backdrop
Border top:    1px rgba(28,56,32,0.08)
FAB:           44–48dp circle · –18dp elevated above nav · #1C3820 bg
Tab icon:      20px · inactive rgba(44,74,46,0.28) · active #1C3820
Tab label:     DM Sans 500 · 9sp · same colour as icon
```

### Dialpad keys

```
Size:          max-width 68dp × 62dp
Radius:        18px
Background:    #FFFFFF
Border:        1px rgba(44,74,46,0.10)
Number label:  DM Serif Display · 22sp · #1C3820
Letter label:  DM Sans 500 · 9sp · rgba(44,74,46,0.40) · letter-spacing 0.12em
Press state:   background #E8DED7 · scale(0.96)
```

---

## 05 Spacing System

**Base unit: 8dp**

| Token | Value | Used for |
|---|---|---|
| `space-1` | `4dp` | Icon-to-label gap · tight internal padding |
| `space-2` | `8dp` | Row internal gaps · button icon gap |
| `space-3` | `12dp` | Card internal gap · component spacing |
| `space-4` | `16dp` | Card padding · section content inset |
| `space-5` | `20dp` | Screen horizontal padding (all screens) |
| `space-6` | `24dp` | Major section separation |
| `space-8` | `32dp` | Page-level vertical breathing |

### Layout dimensions

| Element | Dimension | Note |
|---|---|---|
| Screen horizontal padding | `20dp` | Consistent on all screens |
| Contact / call row height | `56dp` min | 48dp touch target + 8dp vertical gap |
| Bottom nav height | `56dp` + safe area | iOS: +34dp home indicator |
| Section header height | `28dp` | 10sp label + 20dp inset |
| Search bar height | `42dp` | Radius 12–14px |
| Minimum tap target | `44×44dp` | Apple HIG + Android Material standard |
| Border radius — pill button | `22px` | Half of 44dp standard button height |
| Border radius — card | `12–14px` | Standard surface radius |
| Border radius — avatar | `50%` | Circle on all sizes |
| Border radius — call avatar | `26–34px` | Rounded rect, scales with size |
| Row divider | `1px rgba(28,56,32,0.06)` | Starts at avatar right edge |
| Avatar badge size | `9–16dp` | Scales proportionally with avatar |

---

## 06 UX Principles

### 01 · Colour encodes meaning, never decoration

Red = missed calls, muted state, end call, debit. Green = online, active, connected, credit. Amber = on hold, low balance, suggestions. Never use colour for visual interest alone — it must always carry semantic meaning.

### 02 · Progressive disclosure — urgent first

Missed calls surface above the list. Low balance banner appears at wallet top. The most action-requiring information is always surfaced before browseable content. Users should never have to hunt for critical information.

### 03 · Every touch target is 44×44dp minimum

No exceptions. This includes call buttons in rows, nav icons, and badges with actions. Failing this causes mis-taps and user frustration on physical devices. Test on actual hardware, not just design tools.

### 04 · Never leave the user in a dead end

Every empty state has a clear primary action. Every error has a recovery path. Every "no results" search offers "dial as number" or "add contact". Dead ends destroy trust and increase support tickets.

### 05 · Reduce cognitive load — translate data into meaning

Flag badges replace "+9" country codes. "$4.88 = ~40 min" replaces raw balance. "Missed · 23m ago" replaces undifferentiated rows. Always translate raw data into human-meaningful language before displaying it.

### 06 · Inactive controls must look inactive

On-hold screen: mute, speaker, and keypad buttons are 40% opacity. Users must never be uncertain whether a control is interactive. If a control cannot be used, it must visually communicate that state clearly.

### 07 · Surface trust signals at the point of friction

Lock icon on pay button. Privacy note on contact sync ("hashed — never stored"). Transaction reference numbers on top-ups. These appear exactly when users are most anxious — not buried in settings or help documentation.

### 08 · Contextual CTAs beat navigation

Rate lookup ends with "Call Ethiopia now". Call summary offers "Call back". Top-up confirmation shows new balance preview. Each screen ends with the most logical next action — never force the user to navigate back to act.

### 09 · WCAG 2.1 AA compliance throughout

Minimum 4.5:1 contrast for body text, 3:1 for large text. All interactive elements require accessible labels. Animations must respect `prefers-reduced-motion`. VoiceOver (iOS) and TalkBack (Android) must be fully navigable.

### 10 · Tone is warm, not clinical

"Your network" not "ALL CONTACTS". "Good morning" persists even on empty screens. "~40 more minutes" not "$4.88 remaining". The app should feel like a knowledgeable friend, not a billing management dashboard.

---

## Quick do / don't reference

| Do | Don't |
|---|---|
| Use DM Sans Medium for contact/call row names and DM Serif Display for display figures | Use DM Serif for buttons, labels, metadata, or dense list rows — that's DM Sans |
| Show country flag badges on unknown number avatars | Show "+9" or country code prefix as avatar content |
| Convert balance to minutes at user's most-called destination | Show raw dollar balance without context |
| Use the Zuri "Z" badge to mark contacts callable for free | Treat all contacts the same — free vs paid is critical |
| Group controls in a 4-column grid for thumb-zone access | Use more than 4 in-call buttons — overload under stress |
| Show new balance before confirming a top-up payment | Confirm payment without showing what the user will have |

---

## Flutter token reference

```dart
// zuri_tokens.dart

class ZuriColors {
  // Brand
  static const cream       = Color(0xFFF2EAE3);
  static const sand        = Color(0xFFD8CFC8);
  static const stone       = Color(0xFFB5A99E);
  static const forest50    = Color(0xFFE8F4E9);
  static const forest200   = Color(0xFFA8CFA9);
  static const forest400   = Color(0xFF4A8C50);
  static const forest600   = Color(0xFF2D5E30);
  static const forest800   = Color(0xFF1C3820); // primary
  static const forest900   = Color(0xFF0E1E10); // call screen

  // Semantic
  static const success     = Color(0xFF1C7A3E);
  static const successBg   = Color(0x1A1C783E);
  static const warning     = Color(0xFFB7651D);
  static const warningBg   = Color(0x1AB7651D);
  static const danger      = Color(0xFFC0392B);
  static const dangerBg    = Color(0x1AC0392B);
}

class ZuriTypography {
  static const displayFont = 'DM Serif Display';
  static const uiFont      = 'DM Sans';

  static const screenTitle  = TextStyle(fontFamily: displayFont, fontSize: 28, color: ZuriColors.forest800);
  static const balanceLarge = TextStyle(fontFamily: displayFont, fontSize: 32, color: ZuriColors.forest800);
  static const contactName  = TextStyle(fontFamily: uiFont, fontSize: 15, fontWeight: FontWeight.w500, color: ZuriColors.forest800);
  static const callTimer    = TextStyle(fontFamily: uiFont, fontSize: 20, fontWeight: FontWeight.w300,
                                        fontFeatures: [FontFeature.tabularFigures()]);
  static const btnPrimary   = TextStyle(fontFamily: uiFont, fontSize: 14, fontWeight: FontWeight.w500);
  static const bodyRegular  = TextStyle(fontFamily: uiFont, fontSize: 12, fontWeight: FontWeight.w400);
  static const caption      = TextStyle(fontFamily: uiFont, fontSize: 10, fontWeight: FontWeight.w300);
  static const sectionLabel = TextStyle(fontFamily: uiFont, fontSize: 10, fontWeight: FontWeight.w500,
                                        letterSpacing: 1.0);
}

class ZuriSpacing {
  static const s1 =  4.0;  // icon gap
  static const s2 =  8.0;  // row internal
  static const s3 = 12.0;  // component gap
  static const s4 = 16.0;  // card padding
  static const s5 = 20.0;  // screen padding
  static const s6 = 24.0;  // section gap
  static const s8 = 32.0;  // page breathing
}

class ZuriRadius {
  static const pill   = 22.0;
  static const card   = 12.0;
  static const input  = 12.0;
  static const key    = 18.0;
  static const badge  = 20.0;
  static const callAv = 28.0;
}
```

---

*Zuri Design System v1.0 · Generated June 2026 · Confidential*
