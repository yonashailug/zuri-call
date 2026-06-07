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
  static const quickDialHeight = 40.0;
  static const recentRowHeight = 72.0;
  static const dialpadActionSize = 44.0;
  static const primaryButtonHeight = 62.0;
  static const secondaryButtonHeight = 56.0;
  static const callButtonHeight = 48.0;
  static const navHeight = 56.0;
  static const navOverlayBottomPadding = 112.0;
  static const quickDialNameMaxLength = 10;
}

class ZuriTextStyles {
  const ZuriTextStyles._();

  // ── Page / hero roles ─────────────────────────────────────────────────────
  /// Page titles: Wallet, Contacts, Dial, Settings, subpage titles. 30sp Bold.
  static const pageTitle = TextStyle(
    fontSize: 30,
    height: 1.08,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Page subtitles and small header descriptors. 15sp SemiBold.
  static const pageSubtitle = TextStyle(
    fontSize: 15,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Recents greeting name. 32sp Bold.
  static const greetingTitle = TextStyle(
    fontSize: 32,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Empty state and in-call state titles. 28sp Bold.
  static const stateTitle = TextStyle(
    fontSize: 28,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Compact page/title text for call details and dialpad placeholders. 24sp Bold.
  static const compactTitle = TextStyle(
    fontSize: 24,
    height: 1.08,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const compactPageTitle = compactTitle;
  static const callParticipantName = compactTitle;
  static const dialpadPlaceholder = compactTitle;

  // ── Metric / numeric roles ────────────────────────────────────────────────
  /// Wallet balance hero figure ($4.88). 52sp Light.
  static const metricHero = TextStyle(
    fontSize: 52,
    height: 0.95,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
  );

  /// Balance figures, preset amounts, large numerics. 34sp Light.
  static const metricValue = TextStyle(
    fontSize: 34,
    height: 1.0,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
  );

  /// Avatar initials on in-call and ended-call screens. 36sp Light.
  static const avatarDisplay = TextStyle(
    fontSize: 36,
    height: 1.0,
    fontWeight: FontWeight.w300,
    letterSpacing: 0,
  );

  /// Live call duration counter. 22sp Light, tabular figures.
  static const callTimerText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: 0,
  );

  /// Dialpad number entry display. 26sp Bold.
  static const dialpadEntry = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Dialpad country/contact context. 16sp Medium.
  static const dialpadContext = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  /// Dialpad rate text. 16sp SemiBold.
  static const dialpadRate = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Dialpad key numerals. 24sp SemiBold.
  static const dialpadKey = TextStyle(
    fontSize: 32,
    height: 1.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Wallet card sub-figures (spent, top-up amounts). 20sp Bold.
  static const metricLabel = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  // ── Top-up wallet roles ────────────────────────────────────────────────────
  /// Top-up flow page title. 26sp Bold.
  static const topUpTitle = TextStyle(
    fontSize: 26,
    height: 1.08,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Top-up balance caption. 14sp Medium.
  static const topUpBalanceLabel = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  /// Top-up balance figure. 28sp Bold.
  static const topUpBalanceValue = TextStyle(
    fontSize: 28,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Preset top-up amount figures. 26sp Bold.
  static const topUpOptionAmount = TextStyle(
    fontSize: 26,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Preset top-up minute estimates. 13sp SemiBold.
  static const topUpOptionMinutes = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Top-up popularity badge. 13sp Bold.
  static const topUpBadge = TextStyle(
    fontSize: 13,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Top-up field and payment row primary labels. 16sp Bold.
  static const topUpFieldText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  /// Top-up payment method title. 16sp Bold.
  static const topUpPaymentTitle = topUpFieldText;

  /// Top-up payment method subtitle. 14sp Medium.
  static const topUpPaymentSubtitle = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  /// Top-up summary labels. 14sp Medium.
  static const topUpSummaryLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  /// Top-up summary values. 15sp Bold.
  static const topUpSummaryValue = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  // ── Row / list roles ──────────────────────────────────────────────────────
  /// Primary contact/list row labels. 16sp Bold.
  static const rowPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const contactRowTitle = rowPrimary;
  static const recentRowTitle = rowPrimary;
  static const settingsRowTitle = rowPrimary;
  static const cardTitle = rowPrimary;
  static const avatarInitials = rowPrimary;

  /// High-emphasis transaction/list row titles. 18sp ExtraBold.
  static const rowTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  /// Secondary row metadata and subtitles. 14sp Medium.
  static const rowSecondary = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
  static const contactRowSubtitle = rowSecondary;
  static const recentRowSubtitle = rowSecondary;
  static const cardSubtitle = rowSecondary;
  static const walletTransactionSubtitle = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static const walletTransactionAmount = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Chip and pill labels. 15sp Bold.
  static const chipLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const secondaryButtonLabel = chipLabel;
  static const sectionCount = chipLabel;

  // ── Body ──────────────────────────────────────────────────────────────────
  /// Primary body text: descriptions, banners, inline copy. 16sp SemiBold.
  static const body = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const bodyText = body;
  static const paragraphText = body;

  /// Medium-emphasis body: hold status line, signal quality. 16sp Medium.
  static const bodyMedium = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
  static const supportingText = bodyMedium;
  static const emptyStateBody = bodyMedium;

  /// High-emphasis body: tip banners, inline warnings. 16sp ExtraBold.
  static const bodyStrong = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );
  static const emphasisText = bodyStrong;
  static const bannerText = bodyStrong;

  /// Secondary body: panel rows, phone subtitles, compact copy. 14sp Medium.
  static const bodySmall = TextStyle(
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  /// Subtitle labels ("Good morning", "Your balance"). 15sp SemiBold.
  static const bodySubtle = pageSubtitle;

  // ── Metadata ──────────────────────────────────────────────────────────────
  /// Timestamps, durations, rate notes, country chip labels. 14sp Medium.
  static const meta = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
  static const metadata = meta;

  /// Card metric sub-labels, minute calculation labels. 14sp ExtraBold.
  static const metaStrong = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );
  static const metadataStrong = metaStrong;

  /// Phone number subtitle directly under rowPrimary. 14sp Medium.
  static const rowMeta = rowSecondary;

  // ── Labels / controls ─────────────────────────────────────────────────────
  /// Form field labels, chip labels. 15sp Bold.
  static const label = chipLabel;

  /// Primary CTA buttons ("Call now", "Top up"). 16sp Bold.
  static const buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const primaryButtonLabel = buttonPrimary;

  /// High-emphasis CTAs ("Call back", "Pay securely"). 16sp ExtraBold.
  static const buttonStrong = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );
  static const strongButtonLabel = buttonStrong;

  /// Input field text, country picker list items. 16sp Bold.
  static const control = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const inputText = control;
  static const formControl = control;

  // ── Section / navigation ──────────────────────────────────────────────────
  /// Section headers, eyebrow labels, date group headers. 11sp ExtraBold, tracked.
  static const sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
  );
  static const sectionHeader = sectionLabel;

  /// Dialpad letter sub-labels (ABC, DEF …). Same spec as sectionLabel.
  static const dialpadSublabel = sectionLabel;

  /// Navigation bar tab labels. 11sp Bold.
  static const navLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const navItemLabel = navLabel;

  // ── Deprecated aliases (remove after migration) ───────────────────────────
  @Deprecated('Use body')
  static const bodyLarge = body;
  @Deprecated('Use pageTitle')
  static const screenTitle = pageTitle;
  @Deprecated('Use greetingTitle')
  static const greetingName = greetingTitle;
  @Deprecated('Use pageSubtitle')
  static const subheading = pageSubtitle;
  @Deprecated('Use metricHero')
  static const displayHero = metricHero;
  @Deprecated('Use metricValue')
  static const display = metricValue;
  @Deprecated('Use avatarDisplay')
  static const displayAvatar = avatarDisplay;
  @Deprecated('Use rowPrimary')
  static const contactName = rowPrimary;
  @Deprecated('Use callTimerText')
  static const callTimer = callTimerText;
  @Deprecated('Use dialpadEntry')
  static const dialpadNumber = dialpadEntry;
  @Deprecated('Use metricLabel')
  static const balanceMetric = metricLabel;
  @Deprecated('Use sectionLabel')
  static const sectionTitle = sectionLabel;
  @Deprecated('Use sectionLabel')
  static const eyebrow = sectionLabel;
  @Deprecated('Use buttonStrong')
  static const controlStrong = buttonStrong;
  @Deprecated('Use meta')
  static const caption = meta;
}
