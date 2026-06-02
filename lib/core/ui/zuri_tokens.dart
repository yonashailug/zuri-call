import 'package:flutter/material.dart';

class ZuriSpacing {
  const ZuriSpacing._();

  // Spec-named tokens (s1–s8, base unit 8dp)
  static const s1 = 4.0; // icon-to-label gap
  static const s2 = 8.0; // row internal gaps
  static const s3 = 12.0; // card internal / component gap
  static const s4 = 16.0; // card padding / section inset
  static const s5 = 20.0; // screen horizontal padding — all screens
  static const s6 = 24.0; // major section separation
  static const s8 = 32.0; // page-level vertical breathing

  // Semantic aliases (keep existing callsites compiling)
  static const xs = s1;
  static const sm = s2;
  static const md = s3;
  static const lg = s4;
  static const xl = s6; // NOTE: xl maps to s6=24, not s5=20
  static const xxl = s8;

  static const screen = EdgeInsets.fromLTRB(s5, 32, s5, 32);
  static const screenCompact = EdgeInsets.fromLTRB(s5, 12, s5, 32);
  static const authBody = EdgeInsets.fromLTRB(s5, 40, s5, 32);
  static const welcome = EdgeInsets.fromLTRB(s5, 40, s5, 32);
}

class ZuriRadius {
  const ZuriRadius._();

  // Spec-named tokens
  static const pill = 22.0; // pill buttons (half of 44dp standard height)
  static const card = 12.0; // standard surface / card
  static const input = 14.0; // search bar / text input
  static const key = 18.0; // dialpad keys
  static const badge = 20.0; // status badges / pills
  static const callAv = 28.0; // call screen avatar (rounded rect)
  static const iconButton = 18.0; // 36dp circular icon buttons
  static const compact = 7.0; // small wallet/inset controls
  static const small = 8.0; // tiny rounded surfaces
  static const action = 13.0; // compact CTA buttons
  static const surface = 16.0; // medium cards / selectable rows
  static const tile = 18.0; // dial keys / content tiles
  static const avatar = 32.0; // large avatar rounds
  static const round = 999.0; // fully rounded pills
  static const waveform = 2.0; // waveform bars

  // Legacy aliases — keep existing callsites compiling
  static const field = 14.0; // themed input border (within spec 12–14px range)
  static const panel = 14.0; // ZuriPanel surface
  static const modal = 30.0; // bottom sheet modal
}

class ZuriDimensions {
  const ZuriDimensions._();

  static const callBackBtnSize = 32.0;
  static const searchBarHeight = 44.0;
  static const avatarRowSize = 44.0;
  static const iconButtonSize = 36.0;
  static const quickDialHeight = 56.0;
  static const recentRowHeight = 64.0;
  static const dialpadActionSize = 44.0;
  static const primaryButtonHeight = 62.0;
  static const secondaryButtonHeight = 56.0;
  static const callButtonHeight = 48.0;
  static const navHeight = 56.0;
  static const quickDialNameMaxLength = 10;
}

class ZuriTextStyles {
  const ZuriTextStyles._();

  // Keep these names aligned with pubspec font family declarations.
  static const displayFont = 'DMSerifDisplay';
  static const uiFont = 'DMSans';

  static const display = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    height: 1,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const screenTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    height: 1.08,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const compactTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 22,
    height: 1.08,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const sectionTitle = TextStyle(
    fontFamily: uiFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
  );

  static const bodyLarge = TextStyle(
    fontFamily: uiFont,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const label = TextStyle(
    fontFamily: uiFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const control = TextStyle(
    fontFamily: uiFont,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const controlStrong = TextStyle(
    fontFamily: uiFont,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const contactName = TextStyle(
    fontFamily: displayFont, // DM Serif Display — spec: "never use DM Sans for primary display names"
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  @Deprecated('Use contactName')
  static const rowTitle = contactName;

  static const rowMeta = TextStyle(
    fontFamily: uiFont,
    fontSize: 11,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
  );

  // Spec: caption — 10sp Light 300 (timestamps, durations, per-minute rates)
  static const caption = TextStyle(
    fontFamily: uiFont,
    fontSize: 10,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
  );

  // Spec: callTimer — DM Sans 20sp Light 300 tabular figures (call duration display)
  static const callTimer = TextStyle(
    fontFamily: uiFont,
    fontSize: 20,
    fontWeight: FontWeight.w300,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: 0,
  );

  static const eyebrow = TextStyle(
    fontFamily: uiFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
  );
}

class ZuriTypography {
  const ZuriTypography._();

  static const displayFont = ZuriTextStyles.displayFont;
  static const uiFont = ZuriTextStyles.uiFont;

  static const screenTitle = ZuriTextStyles.screenTitle;
  static const greetingName = ZuriTextStyles.screenTitle;
  static const balanceLarge = ZuriTextStyles.display;
  static const contactName = ZuriTextStyles.contactName;
  static const btnPrimary = ZuriTextStyles.label;
  static const bodyRegular = ZuriTextStyles.bodyLarge;
  static const caption = ZuriTextStyles.caption;
  static const sectionLabel = ZuriTextStyles.eyebrow;
  static const callTimer = ZuriTextStyles.callTimer;
}
