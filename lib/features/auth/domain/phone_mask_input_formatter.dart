import 'package:flutter/services.dart';

class PhoneMaskInputFormatter extends TextInputFormatter {
  PhoneMaskInputFormatter(this.placeholder);

  final String placeholder;

  int get maxDigits => RegExp('0').allMatches(placeholder).length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'\D'), '')
        .split('')
        .take(maxDigits)
        .join();
    final formatted = applyMask(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String applyMask(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    var digitIndex = 0;

    for (final character in placeholder.split('')) {
      if (character == '0') {
        if (digitIndex >= digits.length) break;
        buffer.write(digits[digitIndex]);
        digitIndex += 1;
        continue;
      }

      if (digitIndex < digits.length) {
        buffer.write(character);
      }
    }

    return buffer.toString();
  }
}
