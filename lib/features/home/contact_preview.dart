import 'package:flutter/material.dart';

import '../../core/ui/zuri_ui.dart';

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
    final cleanedValue = value.replaceAll(RegExp(r'\([^)]*\)'), ' ');
    final parts = cleanedValue
        .trim()
        .split(RegExp(r'\s+'))
        .map((part) => part.replaceAll(RegExp(r'^[^A-Za-z0-9]+'), ''))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return '?';

    return parts.map((part) => part[0].toUpperCase()).join();
  }

  static Color _colorFor(String value) {
    return ZuriAvatarColors.forInitial(value);
  }
}
