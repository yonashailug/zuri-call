import 'package:flutter/material.dart';

import '../ui/zuri_ui.dart';

class ZuriColors {
  const ZuriColors._();

  static const ink = Color(0xFF0B4A2F);
  static const muted = Color(0xFF706961);
  static const surface = Color(0xFFFFF6EF);
  static const callSurface = Color(0xFFF0EADD);
  static const card = Color(0xFFFFFCFA);
  static const border = Color(0xFFAAA298);
  static const primary = Color(0xFF0B4A2F);
  static const accent = Color(0xFF0E9F6E);
  static const disabled = Color(0xFFB8C8C0);
  static const success = Color(0xFF15803D);
  static const danger = Color(0xFFDC2626);
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

    return base.copyWith(
      textTheme: base.textTheme.apply(
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ZuriColors.surface,
        indicatorColor: ZuriColors.callSurface,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            color: ZuriColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? ZuriColors.ink
                : ZuriColors.muted,
          ),
        ),
      ),
    );
  }
}
