import '../data/phone_country_data.dart';
import 'phone_mask_input_formatter.dart';

class PhoneNumber {
  PhoneNumber({
    required this.country,
    required String rawNationalNumber,
  }) : nationalNumber = rawNationalNumber.replaceAll(RegExp(r'\D'), '');

  final CountryOption country;
  final String nationalNumber;

  String get formattedNationalNumber {
    return PhoneMaskInputFormatter(country.placeholder).applyMask(
      nationalNumber,
    );
  }

  String get display => '${country.prefix} $formattedNationalNumber';

  String get e164 => '${country.prefix}$nationalNumber';

  bool get isValid {
    final requiredDigits = RegExp('0').allMatches(country.placeholder).length;
    return nationalNumber.length == requiredDigits;
  }
}
