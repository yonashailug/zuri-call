import 'package:flutter/material.dart';

import '../ui/zuri_ui.dart';

class ZuriColors {
  const ZuriColors._();

  static const ink = Color(0xFF1C3820);
  static const muted = Color(0xFF9EA49A);
  static const surface = Color(0xFFF2EAE3);
  static const callSurface = Color(0xFFE8F4E9);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFD8CFC8);
  static const primary = Color(0xFF1C3820);
  static const accent = Color(0xFF4A8C50);
  static const disabled = Color(0xFFB5A99E);
  static const success = Color(0xFF1C7A3E);
  static const warning = Color(0xFFB7651D);
  static const danger = Color(0xFFC0392B);

  static const cream = surface;
  static const sand = border;
  static const stone = disabled;
  static const bark = Color(0xFF3A2E28);
  static const forest50 = Color(0xFFE8F4E9);
  static const forest200 = Color(0xFFA8CFA9);
  static const forest400 = accent;
  static const forest600 = Color(0xFF2D5E30);
  static const forest800 = primary;
  static const forest900 = Color(0xFF0E1E10);

  static const successBg = Color(0x1A1C783E);
  static const warningBg = Color(0x1AB7651D);
  static const dangerBg = Color(0xFFFFEDEA);
  static const iconButtonBg = Color(0x121C3820);
  static const rowDivider = Color(0xFFE2DAD3);
  static const navIconInactive = Color(0x472C4A2E);
  static const searchBorder = Color(0x1E1C3820);
  static const searchPlaceholder = Color(0xFFB9BFB7);
  static const subtitleText = Color(0xFF9EA49A);
  static const navBorderTop = Color(0x141C3820);
  static const neutralBg = Color(0x0F1C3820);
  static const overlayOnForest = Color(0xA6F2EAE3);
  static const subtleForestText = Color(0x662C4A2E);
  static const emptyIcon = Color(0xFFB7BBB0);
  static const dashedStroke = Color(0xFFC9C9C0);
  static const profileAvatar = Color(0xFFD4845A);

  static const walletCardMuted = Color(0xFF91A08F);
  static const walletCardDivider = Color(0xFF496748);
  static const walletActiveSoft = Color(0xFF315C31);
  static const walletActiveBorder = Color(0xFF4F8547);
  static const walletActiveText = Color(0xFF9ED18D);
  static const walletBorder = Color(0xFFD8D0C7);
  static const walletRowDivider = Color(0xFFE7DED4);
  static const walletDebit = Color(0xFFC0392D);
  static const walletPopular = Color(0xFFB56B2C);
  static const walletTipBackground = Color(0xFFFFEBDD);
  static const walletTipBorder = Color(0xFFEBC6A7);
  static const walletTipText = Color(0xFF965616);

  static const inCallAvatarFill = Color(0xFF39533A);
  static const inCallAvatarRing = Color(0xFFA6B29E);
  static const inCallWaveform = Color(0xFF93A18D);
  static const inCallControl = Color(0x14FFFFFF);
  static const inCallControlActive = Color(0x24FFFFFF);
  static const inCallControlIcon = Color(0xB3F2EAE3);
  static const inCallLiveSoft = Color(0x264CAF50);
  static const inCallLiveBorder = Color(0x4D4CAF50);
  static const inCallLiveText = Color(0xFF1C5C30);
  static const inCallDangerSoft = Color(0x33C0392B);
  static const inCallDangerBorder = Color(0x59C0392B);
  static const inCallDangerText = Color(0xFF8C2A1E);
  static const inCallHoldSoft = Color(0x2EB7651D);
  static const inCallHoldBorder = Color(0x59B7651D);
  static const inCallHoldText = Color(0xFF8C4D0A);
  static const endedCallPill = Color(0xFFEAE9E2);
  static const endedCallBorder = Color(0xFFD8D0C7);
  static const endedCallDivider = Color(0xFFE7DED4);
  static const endedCallMuted = Color(0xFF8E9788);
  static const endedCallQuality = Color(0xFF61AE58);
  static const endedCallAvatar = Color(0xFF7767D9);
}

class ZuriTheme {
  const ZuriTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ZuriColors.primary,
        brightness: Brightness.light,
        surface: ZuriColors.surface,
        primary: ZuriColors.primary,
        primaryContainer: ZuriColors.callSurface,
        onSurface: ZuriColors.ink,
        onSurfaceVariant: ZuriColors.muted,
        outline: ZuriColors.border,
        outlineVariant: ZuriColors.disabled,
        surfaceContainerLowest: ZuriColors.card,
      ),
      scaffoldBackgroundColor: ZuriColors.surface,
    );

    final sansTextTheme = base.textTheme.apply(
      fontFamily: ZuriTypography.uiFont,
    );
    final textTheme = sansTextTheme.copyWith(
      displayLarge: sansTextTheme.displayLarge?.copyWith(
        fontFamily: ZuriTypography.displayFont,
      ),
      displayMedium: sansTextTheme.displayMedium?.copyWith(
        fontFamily: ZuriTypography.displayFont,
      ),
      displaySmall: sansTextTheme.displaySmall?.copyWith(
        fontFamily: ZuriTypography.displayFont,
      ),
      headlineLarge: sansTextTheme.headlineLarge?.copyWith(
        fontFamily: ZuriTypography.displayFont,
      ),
      headlineMedium: sansTextTheme.headlineMedium?.copyWith(
        fontFamily: ZuriTypography.displayFont,
      ),
      headlineSmall: sansTextTheme.headlineSmall?.copyWith(
        fontFamily: ZuriTypography.displayFont,
      ),
    );

    return base.copyWith(
      textTheme: textTheme.apply(
        bodyColor: ZuriColors.ink,
        displayColor: ZuriColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ZuriColors.surface,
        foregroundColor: ZuriColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: ZuriTextStyles.screenTitle.copyWith(
          color: ZuriColors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZuriColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZuriRadius.field),
          borderSide: const BorderSide(color: ZuriColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZuriRadius.field),
          borderSide: const BorderSide(color: ZuriColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ZuriRadius.field),
          borderSide: const BorderSide(color: ZuriColors.primary),
        ),
        hintStyle: ZuriTextStyles.control.copyWith(
          color: ZuriColors.muted,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        sizeConstraints: BoxConstraints.tightFor(width: 48, height: 48),
        smallSizeConstraints: BoxConstraints.tightFor(width: 48, height: 48),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ZuriColors.surface,
        indicatorColor: ZuriColors.callSurface,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: ZuriTypography.uiFont,
            color: ZuriColors.ink,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 20,
            color: states.contains(WidgetState.selected)
                ? ZuriColors.ink
                : ZuriColors.navIconInactive,
          ),
        ),
      ),
    );
  }
}
