import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import 'application/auth_scope.dart';
import 'auth_design.dart';
import 'code_verification_screen.dart';
import 'data/phone_country_data.dart';
import 'domain/phone_mask_input_formatter.dart';
import 'domain/phone_number.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final phoneController = TextEditingController();
  CountryOption selectedCountry = countries.first;

  PhoneNumber get phoneNumber {
    return PhoneNumber(
      country: selectedCountry,
      rawNationalNumber: phoneController.text,
    );
  }

  bool get canContinue => phoneNumber.isValid;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final authState = authController.state;
    final isBusy = authState.isBusy;

    return AuthScaffold(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: ZuriSpacing.authBody,
        children: [
          const ZuriScreenHeadline('Please enter your phone number below:'),
          const SizedBox(height: 48),
          const ZuriFieldLabel('Country/Region'),
          const SizedBox(height: 8),
          _CountrySelector(
            country: selectedCountry,
            onTap: showCountryPicker,
          ),
          const SizedBox(height: 16),
          const ZuriFieldLabel('Phone number'),
          const SizedBox(height: 8),
          ZuriTextField(
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
          Text(
            'You agree to receive automated text messages from us. Message frequency varies. Message and data rates may apply. Text STOP to cancel.',
            style: ZuriTextStyles.bodyLarge.copyWith(
              color: ZuriColors.muted,
            ),
          ),
          const SizedBox(height: 34),
          if (authState.errorMessage != null) ...[
            _ErrorText(authState.errorMessage!),
            const SizedBox(height: 18),
          ],
          ZuriPillButton(
            label: isBusy ? 'Sending...' : 'Continue',
            onPressed: canContinue && !isBusy
                ? () async {
                    final navigator = Navigator.of(context);
                    final didSend = await authController.startPhoneAuth(
                      phoneNumber,
                    );
                    if (!mounted || !didSend) return;
                    await navigator.push(
                      MaterialPageRoute<void>(
                        builder: (_) => CodeVerificationScreen(
                          phoneNumber: phoneNumber,
                        ),
                      ),
                    );
                  }
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

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: ZuriTextStyles.bodyLarge.copyWith(color: ZuriColors.danger),
    );
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
      borderRadius: BorderRadius.circular(ZuriRadius.field),
      onTap: onTap,
      child: Ink(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: ZuriColors.card,
          borderRadius: BorderRadius.circular(ZuriRadius.field),
          border: Border.all(color: ZuriColors.border, width: 1.4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${country.name} (${country.prefix})',
                style: ZuriTextStyles.controlStrong.copyWith(
                  color: ZuriColors.ink,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: ZuriColors.border,
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
            color: ZuriColors.card.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(ZuriRadius.modal),
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
                    style: ZuriTextStyles.control.copyWith(
                      color: selected ? ZuriColors.ink : Colors.black,
                      fontWeight: selected
                          ? FontWeight.w800
                          : ZuriTextStyles.control.fontWeight,
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
