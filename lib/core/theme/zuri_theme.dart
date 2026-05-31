import 'package:flutter/material.dart';

class ZuriColors {
  const ZuriColors._();

  static const ink = Color(0xFF1E1461);
  static const muted = Color(0xFF7B72B8);
  static const tertiary = Color(0xFFB5B0D8);
  static const surface = Color(0xFFF7F6FF);
  static const callSurface = Color(0xFFF0EEFF);
  static const card = Colors.white;
  static const border = Color(0xFFE2DEFA);
  static const primary = Color(0xFF4F46E5);
  static const primaryDeep = Color(0xFF6D28D9);
  static const success = Color(0xFF15803D);
  static const danger = Color(0xFFDC2626);
}

class ZuriGradients {
  const ZuriGradients._();

  static const primary = LinearGradient(
    colors: [ZuriColors.primary, ZuriColors.primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
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
      ),
      scaffoldBackgroundColor: ZuriColors.surface,
      fontFamily: 'DM Sans',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: ZuriColors.ink,
        displayColor: ZuriColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ZuriColors.surface,
        foregroundColor: ZuriColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZuriColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZuriColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZuriColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZuriColors.primary),
        ),
      ),
    );
  }
}
