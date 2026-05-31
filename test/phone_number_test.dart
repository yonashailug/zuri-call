import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/features/auth/data/phone_country_data.dart';
import 'package:zuri_call/features/auth/domain/phone_mask_input_formatter.dart';
import 'package:zuri_call/features/auth/domain/phone_number.dart';

void main() {
  test('formats US phone numbers with placeholder mask', () {
    final formatter = PhoneMaskInputFormatter('(000) 000-0000');

    expect(formatter.applyMask('6502137552'), '(650) 213-7552');
  });

  test('formats Singapore phone numbers with placeholder mask', () {
    final formatter = PhoneMaskInputFormatter('0000 0000');

    expect(formatter.applyMask('81234567'), '8123 4567');
  });

  test('normalizes phone numbers to display and e164 values', () {
    final phoneNumber = PhoneNumber(
      country: countries.first,
      rawNationalNumber: '(650) 213-7552',
    );

    expect(phoneNumber.nationalNumber, '6502137552');
    expect(phoneNumber.formattedNationalNumber, '(650) 213-7552');
    expect(phoneNumber.display, '+1 (650) 213-7552');
    expect(phoneNumber.e164, '+16502137552');
    expect(phoneNumber.isValid, isTrue);
  });
}
