# Zuri UI Architecture

## Purpose

Zuri uses a small first-party UI system so screen code stays focused on product behavior instead of recreating typography, spacing, buttons, fields, and panels. The current visual direction is light-only, warm, and utilitarian:

- warm cream app surface
- deep green primary actions and titles
- Georgia display titles
- compact, rounded controls
- circular icon controls and avatars
- no purple gradients

## Source of Truth

UI primitives live in:

```text
lib/core/ui/
  zuri_ui.dart          # public barrel export
  zuri_tokens.dart      # spacing, radius, typography
  zuri_components.dart  # reusable controls and surfaces
```

Theme integration lives in:

```text
lib/core/theme/zuri_theme.dart
```

Feature screens should import:

```dart
import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
```

## Typography Rules

Use these text styles by role:

- `ZuriTextStyles.display`: brand/product emphasis and major numeric values.
- `ZuriTextStyles.screenTitle`: large page or onboarding headlines.
- `ZuriTextStyles.compactTitle`: dense functional titles like dialed phone numbers.
- `ZuriTextStyles.sectionTitle`: visible section headers.
- `ZuriTextStyles.bodyLarge`: supporting copy and metadata that needs prominence.
- `ZuriTextStyles.label`: form labels and compact button-adjacent text.
- `ZuriTextStyles.control`: inputs and primary controls.
- `ZuriTextStyles.controlStrong`: high-emphasis selectable control text.
- `ZuriTextStyles.rowTitle`: list row titles and menu labels.
- `ZuriTextStyles.rowMeta`: secondary list row text.
- `ZuriTextStyles.eyebrow`: uppercase section labels and small high-emphasis labels.

Avoid raw `TextStyle` in feature screens unless a component has a genuinely unique visual requirement. Prefer `copyWith` only for semantic color or unavoidable local emphasis.

## Component Rules

Use these components instead of rebuilding common UI:

- `ZuriPillButton`: primary full-width action buttons.
- `ZuriCircleButton`: circular icon buttons.
- `ZuriTextField`: app text inputs.
- `ZuriPanel`: bordered light panels.
- `ZuriFieldLabel`: form labels.
- `ZuriScreenHeadline`: onboarding and major screen headlines.
- `ZuriAvatar`: circular initials avatar.

Do not add new feature-local button, field, panel, or avatar widgets unless the shared primitive cannot express the required behavior.

## Spacing Rules

Use `ZuriSpacing` tokens:

- `ZuriSpacing.screen`: primary scrollable screen padding.
- `ZuriSpacing.screenCompact`: titled app screens below an app bar.
- `ZuriSpacing.authBody`: auth body padding below auth navigation controls.
- `ZuriSpacing.welcome`: welcome screen padding.

Small gaps can use `SizedBox` with token values when possible.

## Color Rules

Use `ZuriColors` and theme colors:

- `ZuriColors.surface`: app background.
- `ZuriColors.card`: fields and panels.
- `ZuriColors.ink`: primary text.
- `ZuriColors.muted`: secondary text.
- `ZuriColors.primary`: primary action.
- `ZuriColors.accent`: secondary positive action.
- `ZuriColors.border`: field and panel borders.

Avoid hardcoded colors in features except fixed semantic cases such as destructive red or contact avatar sample colors.

## Review Checklist

Before merging UI work:

- No stale legacy UI wrappers are introduced.
- No purple gradient styling returns.
- Feature screens use `ZuriTextStyles` instead of raw typography.
- Shared controls use `ZuriPillButton`, `ZuriCircleButton`, `ZuriTextField`, `ZuriPanel`, or `ZuriAvatar`.
- `flutter analyze` passes.
- `flutter test` passes.
- iOS build compiles.
