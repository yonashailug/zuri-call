import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/core/ui/zuri_ui.dart';
import 'package:zuri_call/features/home/contact_preview.dart';

void main() {
  test('builds contact display data from name and phone', () {
    final contact = ContactPreview.fromNameAndPhone(
      name: 'Maya Kim',
      phone: '+1 (206) 555-0142',
    );

    expect(contact.name, 'Maya Kim');
    expect(contact.phone, '+1 (206) 555-0142');
    expect(contact.initials, 'MK');
    expect(contact.shortName, 'Maya');
    expect(contact.color, ZuriAvatarColors.forInitial('M'));
  });

  test('ignores parenthesized labels when deriving initials', () {
    final contact = ContactPreview.fromNameAndPhone(
      name: 'Seme (Dil Kursu)',
      phone: '+1 (503) 555-0278',
    );

    expect(contact.initials, 'S');
  });

  test('matches search by name and phone digits', () {
    final contact = ContactPreview.fromNameAndPhone(
      name: 'Jordan Rivera',
      phone: '+1 (503) 555-0278',
    );

    expect(contact.matches('rivera'), isTrue);
    expect(contact.matches('503555'), isTrue);
    expect(contact.matches('maya'), isFalse);
  });

  test('uses deterministic Zuri avatar colour map by initial', () {
    expect(ZuriAvatarColors.forInitial('A'), const Color(0xFF7B68D9));
    expect(ZuriAvatarColors.forInitial('m'), const Color(0xFF1C7A3E));
    expect(ZuriAvatarColors.forInitial('7'), const Color(0xFF546E7A));
  });
}
