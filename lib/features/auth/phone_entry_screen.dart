import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_design.dart';
import 'code_verification_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final phoneController = TextEditingController();
  CountryOption selectedCountry = countries.first;

  bool get canContinue =>
      phoneController.text.replaceAll(RegExp(r'\D'), '').length >= 7;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(28, 46, 28, 32),
        children: [
          const AuthHeadline('Please enter your phone number below:'),
          const SizedBox(height: 48),
          const AuthFieldLabel('Country/Region'),
          const SizedBox(height: 8),
          _CountrySelector(
            country: selectedCountry,
            onTap: showCountryPicker,
          ),
          const SizedBox(height: 16),
          const AuthFieldLabel('Phone number'),
          const SizedBox(height: 8),
          AuthTextField(
            controller: phoneController,
            hintText: selectedCountry.placeholder,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              PhoneMaskInputFormatter(selectedCountry.placeholder),
            ],
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 34),
          const Text(
            'You agree to receive automated text messages from us. Message frequency varies. Message and data rates may apply. Text STOP to cancel.',
            style: TextStyle(
              color: AuthColors.muted,
              fontSize: 17,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 34),
          AuthPillButton(
            label: 'Continue',
            onPressed: canContinue
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CodeVerificationScreen(
                          phoneNumber:
                              '${selectedCountry.prefix} ${phoneController.text}',
                        ),
                      ),
                    )
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> showCountryPicker() async {
    final picked = await showModalBottomSheet<CountryOption>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.08),
      builder: (context) {
        return _CountrySheet(selectedCountry: selectedCountry);
      },
    );

    if (picked == null) return;
    setState(() {
      selectedCountry = picked;
      phoneController.value = PhoneMaskInputFormatter(
        picked.placeholder,
      ).formatEditUpdate(TextEditingValue.empty, phoneController.value);
    });
  }
}

class _CountrySelector extends StatelessWidget {
  const _CountrySelector({
    required this.country,
    required this.onTap,
  });

  final CountryOption country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AuthColors.field,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AuthColors.border, width: 1.4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${country.name} (${country.prefix})',
                style: const TextStyle(
                  color: AuthColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AuthColors.border,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountrySheet extends StatelessWidget {
  const _CountrySheet({required this.selectedCountry});

  final CountryOption selectedCountry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.72,
          constraints: const BoxConstraints(maxHeight: 560),
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: AuthColors.field.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 26,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                final selected = country == selectedCountry;
                return ListTile(
                  title: Text(
                    '${country.name} (${country.prefix})',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? AuthColors.ink : Colors.black,
                      fontSize: 22,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(country),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CountryOption {
  const CountryOption({
    required this.name,
    required this.prefix,
    required this.placeholder,
  });

  final String name;
  final String prefix;
  final String placeholder;
}

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
        .characters
        .take(maxDigits)
        .join();
    final formatted = _applyMask(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _applyMask(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    var digitIndex = 0;

    for (final character in placeholder.characters) {
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

const countries = [
  CountryOption(
      name: 'United States', prefix: '+1', placeholder: '(000) 000-0000'),
  CountryOption(name: 'Canada', prefix: '+1', placeholder: '(000) 000-0000'),
  CountryOption(name: 'Singapore', prefix: '+65', placeholder: '0000 0000'),
  CountryOption(name: 'Argentina', prefix: '+54', placeholder: '00 0000 0000'),
  CountryOption(name: 'Australia', prefix: '+61', placeholder: '000 000 000'),
  CountryOption(name: 'Austria', prefix: '+43', placeholder: '000 000000'),
  CountryOption(name: 'Belgium', prefix: '+32', placeholder: '000 00 00 00'),
  CountryOption(name: 'Brazil', prefix: '+55', placeholder: '(00) 00000-0000'),
  CountryOption(name: 'Chile', prefix: '+56', placeholder: '0 0000 0000'),
  CountryOption(name: 'Colombia', prefix: '+57', placeholder: '000 0000000'),
  CountryOption(name: 'Costa Rica', prefix: '+506', placeholder: '0000 0000'),
  CountryOption(
      name: 'Czech Republic', prefix: '+420', placeholder: '000 000 000'),
];
