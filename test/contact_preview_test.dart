import 'package:flutter_test/flutter_test.dart';
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
}
