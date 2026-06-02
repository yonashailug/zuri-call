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
