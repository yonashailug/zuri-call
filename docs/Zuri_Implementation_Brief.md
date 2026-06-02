# Zuri — Implementation Correction Brief
> For: Engineering team
> Date: June 2026
> Re: Recents screen deviations from Design System v2.0
> Action required: 7 surgical fixes, no structural changes needed

---

## How to use this brief

Each fix below tells you:
1. **Which file and widget** to open
2. **Which exact property** to change
3. **What to change it FROM and TO**
4. **How to verify** the fix is correct

Do not re-read the design system spec. Follow these instructions line by line.

---

## Fix 1 — Contact name font (P0 · 15 minutes)

**File:** `lib/features/recents/widgets/call_history_row.dart`
*(or wherever your call history list row widget lives)*

**Find this:**
```dart
Text(
  contact.displayName,
  style: TextStyle(
    // any style here that is NOT ZuriTypography.contactName
  ),
)
```

**Replace with:**
```dart
Text(
  contact.displayName,
  style: ZuriTypography.contactName,
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
)
```

**What this does:** Changes the name from DM Sans w400 (thin, system default) to DM Sans w500 15sp — matches the visual weight of the native iOS Phone app contact list.

**Verify:** Run the app. "Seme (Dil Kursu)" should appear slightly heavier and more prominent than the subtitle text below it.

---

## Fix 2 — Greeting name font (P0 · 10 minutes)

**File:** `lib/features/recents/recents_screen.dart`
*(or your home/recents screen widget)*

**Find this:**
```dart
Text(
  userName, // "Yonas"
  style: TextStyle(
    fontSize: 24, // or whatever is there
    fontWeight: FontWeight.bold, // or w600, or w700
    // NOT using ZuriTypography
  ),
)
```

**Replace with:**
```dart
Text(
  userName,
  style: ZuriTypography.greetingName,
)
```

**What this does:** Applies DM Serif Display 28sp w400 — a display serif that gives "Yonas" a warm, editorial presence above the list. This is a display moment, not a UI label.

**Verify:** "Yonas" should look noticeably different from the subtitle "Good morning" above it — more elegant, slightly larger, serif letterforms.

---

## Fix 3 — Avatar colour (P0 · 30 minutes)

**File:** `lib/features/recents/widgets/call_history_row.dart` and `lib/features/contacts/widgets/contact_row.dart`

**Find this:**
```dart
CircleAvatar(
  backgroundColor: Colors.orange, // or any hardcoded colour
  // or: Color(0xFFD4845A), Color(0xFFC87800), etc.
  child: Text(contact.initials),
)
```

**Replace with:**
```dart
CircleAvatar(
  backgroundColor: ZuriAvatarColors.forInitial(contact.displayName),
  radius: ZuriDimensions.avatarRowSize / 2,
  child: Text(
    contact.initials,
    style: ZuriTypography.contactName.copyWith(
      color: Colors.white,
      fontSize: 15,
    ),
  ),
)
```

**Import required:**
```dart
import 'package:zuri/core/tokens/zuri_tokens.dart';
```

**What this does:** The avatar colour is now deterministic — "S" always shows Purple `#8E44AD` across all devices and sessions. Never amber-orange.

**Verify:** A contact whose name starts with "S" (like "Seme") must show a purple avatar. A contact starting with "Y" (Yonas) maps to: Y → Amber `#D4845A`. Check the colour map in `ZuriAvatarColors`.

---

## Fix 4 — Call-back icon button background (P0 · 15 minutes)

**File:** `lib/features/recents/widgets/call_history_row.dart`

**Find this:**
```dart
Container(
  width: 32, height: 32,
  decoration: BoxDecoration(
    color: Colors.teal.withOpacity(0.15), // WRONG — teal
    // or: Color(0xFF1C7A3E).withOpacity(0.12)
    // or: Colors.green[50]
    // or: any teal/mint colour
    shape: BoxShape.circle,
  ),
  child: Icon(
    Icons.phone,
    color: Colors.teal, // WRONG
    size: 16,
  ),
)
```

**Replace with:**
```dart
Container(
  width: ZuriDimensions.callBackBtnSize,   // 32.0
  height: ZuriDimensions.callBackBtnSize,  // 32.0
  decoration: const BoxDecoration(
    color: ZuriColors.iconButtonBg,  // Color(0x121C3820) — forest tint
    shape: BoxShape.circle,
  ),
  child: Icon(
    TablerIcons.phone,
    color: ZuriColors.forest800,  // #1C3820 — dark forest green
    size: 15,
  ),
)
```

**What this does:** The button background becomes a near-invisible warm grey-green tint (7% opacity forest green). The icon becomes dark forest green. The teal/mint colour is completely eliminated.

**Verify:** The call-back button should be barely visible as a circle — it should not compete visually with the contact name. The phone icon should be dark green, not teal.

---

## Fix 5 — Search bar height and border radius (P1 · 10 minutes)

**File:** wherever your search bar widget is defined

**Find this:**
```dart
Container(
  height: 52, // or any value above 44
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(26), // or 30, or full pill
    // ...
  ),
)
```

**Replace with:**
```dart
Container(
  height: ZuriDimensions.searchBarHeight, // 44.0
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(ZuriRadius.input), // 14.0
    border: Border.all(
      color: ZuriColors.searchBorder,
      width: 1.0,
    ),
  ),
)
```

**What this does:** Search bar becomes a rounded rectangle (radius 14), not a full pill. Height matches the 44dp minimum touch target spec.

**Verify:** The search bar should look like a rounded rect, not an oval. It should be the same height as a standard iOS search field.

---

## Fix 6 — Quick-dial pill name truncation (P1 · 10 minutes)

**File:** wherever your quick-dial / recent contact pill is rendered

**Find this:**
```dart
Text(contact.displayName) // shows "Seme (." truncated incorrectly
```

**Replace with:**
```dart
Text(
  _getShortName(contact.displayName),
  style: ZuriTypography.caption.copyWith(
    color: ZuriColors.cream,
    fontWeight: FontWeight.w500,
  ),
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
)

// Helper function:
String _getShortName(String displayName) {
  final firstName = displayName.trim().split(' ').first;
  return firstName.length > 10
      ? '${firstName.substring(0, 10)}...'
      : firstName;
}
```

**What this does:** Shows first name only. "Seme (Dil Kursu)" → "Seme". "Maya Kim" → "Maya". Never truncates mid-word with a bracket.

---

## Fix 7 — Add MissedCallBanner above the list (P1 · 45 minutes)

**File:** `lib/features/recents/recents_screen.dart`

**Find this** (your list rendering):
```dart
ListView.builder(
  itemCount: calls.length,
  itemBuilder: (context, index) => CallHistoryRow(call: calls[index]),
)
```

**Add above the list:**
```dart
// In your build method, before the ListView:
final missedCalls = calls.where((c) => c.status == CallStatus.missed).toList();

if (missedCalls.isNotEmpty)
  MissedCallBanner(
    count: missedCalls.length,
    latestContact: missedCalls.first.contactName,
    latestTime: missedCalls.first.timestamp,
    onCallBack: () => _initiateCall(missedCalls.first.number),
  ),
```

**Create `lib/features/recents/widgets/missed_call_banner.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:zuri/core/tokens/zuri_tokens.dart';

class MissedCallBanner extends StatelessWidget {
  final int count;
  final String latestContact;
  final DateTime latestTime;
  final VoidCallback onCallBack;

  const MissedCallBanner({
    super.key,
    required this.count,
    required this.latestContact,
    required this.latestTime,
    required this.onCallBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        ZuriSpacing.s5, ZuriSpacing.s3, ZuriSpacing.s5, 0
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: ZuriSpacing.s3, vertical: ZuriSpacing.s2 + 2,
      ),
      decoration: BoxDecoration(
        color: ZuriColors.dangerBg,
        borderRadius: BorderRadius.circular(ZuriRadius.card),
        border: Border.all(
          color: ZuriColors.danger.withOpacity(0.15),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            TablerIcons.phone_missed,
            size: 16,
            color: ZuriColors.danger,
          ),
          const SizedBox(width: ZuriSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count missed call${count > 1 ? 's' : ''}',
                  style: ZuriTypography.contactName.copyWith(
                    color: ZuriColors.danger,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$latestContact · ${_timeAgo(latestTime)}',
                  style: ZuriTypography.caption.copyWith(
                    color: ZuriColors.danger.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCallBack,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ZuriSpacing.s2 + 2, vertical: ZuriSpacing.s1,
              ),
              decoration: BoxDecoration(
                color: ZuriColors.danger.withOpacity(0.10),
                borderRadius: BorderRadius.circular(ZuriRadius.iconButton),
              ),
              child: Text(
                'Call back',
                style: ZuriTypography.caption.copyWith(
                  color: ZuriColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
```

---

## pubspec.yaml — font declarations

This repo uses `google_fonts` for DM Sans and DM Serif Display instead of vendored local `.ttf` assets. Do **not** add `flutter.fonts` entries unless the actual font files are added under `assets/fonts/`.

Verify `pubspec.yaml` contains:

```yaml
dependencies:
  google_fonts: ^8.1.0
```

The theme loads DM Sans through `GoogleFonts.dmSansTextTheme(...)`, and token styles use the family names `DM Sans` and `DM Serif Display`.

If the app later switches to local font files, add the `flutter.fonts` block and run:

```bash
flutter clean
flutter pub get
flutter run
```

Hot reload is NOT sufficient for font changes. Full restart required.

---

## Verification checklist

After all fixes, verify the following before opening your PR:

| # | Check | Expected result |
|---|---|---|
| 1 | "Seme (Dil Kursu)" font | DM Sans, medium weight, reads clearly |
| 2 | "Yonas" greeting font | DM Serif Display, elegant serif letterforms |
| 3 | Seme avatar colour | Purple `#8E44AD` — not amber/orange |
| 4 | Call-back button circle | Near-invisible warm grey-green, dark forest icon |
| 5 | Search bar | Rounded rectangle (not pill), ~44dp height |
| 6 | Quick-dial pill | Shows "Seme" not "Seme (." |
| 7 | Missed calls exist | Red banner appears above list with call-back button |
| 8 | Missed calls absent | No banner shown — list starts at section header |

---

*Zuri Implementation Brief · June 2026 · Engineering only*
