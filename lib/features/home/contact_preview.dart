import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';

class ContactPreview {
  const ContactPreview({
    required this.name,
    required this.phone,
    required this.initials,
    required this.color,
  });

  factory ContactPreview.fromNameAndPhone({
    required String name,
    required String phone,
  }) {
    final displayName = name.trim().isEmpty ? phone : name.trim();
    return ContactPreview(
      name: displayName,
      phone: phone.trim(),
      initials: _initials(displayName),
      color: _colorFor(displayName),
    );
  }

  final String name;
  final String phone;
  final String initials;
  final Color color;

  String get shortName => name.split(RegExp(r'\s+')).first;

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    final queryDigits = normalizedQuery.replaceAll(RegExp(r'\D'), '');
    return name.toLowerCase().contains(normalizedQuery) ||
        phone.toLowerCase().contains(normalizedQuery) ||
        (queryDigits.isNotEmpty && normalizedPhone.contains(queryDigits));
  }

  static String _initials(String value) {
    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return '?';

    return parts.map((part) => part[0].toUpperCase()).join();
  }

  static Color _colorFor(String value) {
    const colors = [
      ZuriColors.primary,
      ZuriColors.accent,
      Color(0xFFD97706),
      Color(0xFF7C3AED),
      Color(0xFF0F766E),
      ZuriColors.danger,
    ];

    final hash = value.codeUnits.fold<int>(
      0,
      (previous, codeUnit) => previous + codeUnit,
    );
    return colors[hash % colors.length];
  }
}
