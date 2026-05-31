import 'package:flutter/material.dart';

class ZuriSpacing {
  const ZuriSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 28.0;
  static const xxl = 46.0;

  static const screen = EdgeInsets.fromLTRB(28, 34, 28, 32);
  static const screenCompact = EdgeInsets.fromLTRB(28, 12, 28, 32);
  static const authBody = EdgeInsets.fromLTRB(28, 46, 28, 32);
  static const welcome = EdgeInsets.fromLTRB(28, 40, 28, 32);
}

class ZuriRadius {
  const ZuriRadius._();

  static const field = 14.0;
  static const panel = 16.0;
  static const modal = 30.0;
}

class ZuriTextStyles {
  const ZuriTextStyles._();

  static const display = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 48,
    height: 1,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );

  static const screenTitle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 35,
    height: 1.08,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const compactTitle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 32,
    height: 1.08,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const sectionTitle = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const bodyLarge = TextStyle(
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const label = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const control = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const controlStrong = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const rowTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const rowMeta = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const eyebrow = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );
}
