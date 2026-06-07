import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../auth/data/phone_country_data.dart';
import '../auth/domain/phone_mask_input_formatter.dart';

class DialpadScreen extends StatefulWidget {
  const DialpadScreen({
    required this.onStartCall,
    this.initialNumber,
    this.contactName,
    super.key,
  });

  final ValueChanged<String> onStartCall;
  final String? initialNumber;
  final String? contactName;

  @override
  State<DialpadScreen> createState() => _DialpadScreenState();
}

class _DialpadScreenState extends State<DialpadScreen> {
  late _DialState dialState = _DialState.fromInitialNumber(
    widget.initialNumber,
    widget.contactName,
  );

  bool get canCall => dialState.dialableNumber.isNotEmpty;

  @override
  void didUpdateWidget(DialpadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNumber != oldWidget.initialNumber ||
        widget.contactName != oldWidget.contactName) {
      dialState = _DialState.fromInitialNumber(
        widget.initialNumber,
        widget.contactName,
      );
    }
  }

  void append(String digit) {
    setState(() {
      dialState = dialState.append(digit);
    });
  }

  void appendPlus() {
    setState(() {
      dialState = dialState.appendPlus();
    });
  }

  void backspace() {
    if (!dialState.hasInput) return;
    setState(() => dialState = dialState.backspace());
  }

  void startCall() {
    final dialableNumber = dialState.dialableNumber;
    if (dialableNumber.isEmpty) return;

    widget.onStartCall(dialableNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ZuriColors.surface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeight = constraints.maxHeight < 720;
            final keySize = compactHeight ? 78.0 : 88.0;
            final keyGap = compactHeight ? 16.0 : 20.0;
            final rowGap = compactHeight ? 12.0 : 20.0;
            final actionGap = compactHeight ? 14.0 : 20.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                ZuriSpacing.s5,
                18,
                ZuriSpacing.s5,
                16,
              ),
              child: Column(
                children: [
                  _NumberDisplay(number: dialState.displayNumber),
                  const SizedBox(height: 10),
                  _RateRow(
                    country: dialState.country,
                    contactName: dialState.contactName,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        _DialPad(
                          keySize: keySize,
                          keyGap: keyGap,
                          rowGap: rowGap,
                          onTap: append,
                          onPlus: appendPlus,
                        ),
                        SizedBox(height: actionGap),
                        _CallActions(
                          canCall: canCall,
                          onStartCall: startCall,
                          onBackspace: backspace,
                        ),
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DialState {
  const _DialState({
    required this.country,
    required this.nationalDigits,
    required this.rawInternational,
    this.contactName,
  });

  factory _DialState.fromInitialNumber(String? initialNumber, String? name) {
    final value = initialNumber?.trim();
    if (value == null || value.isEmpty) {
      return const _DialState(
        country: _defaultCountry,
        nationalDigits: '',
        rawInternational: null,
      );
    }

    if (value.startsWith('+')) {
      final country = _countryForNumber(value);
      final digits = value.replaceAll(RegExp(r'\D'), '');
      final prefixDigits = country.prefix.replaceAll(RegExp(r'\D'), '');
      final nationalDigits = digits.startsWith(prefixDigits)
          ? digits.substring(prefixDigits.length)
          : digits;

      return _DialState(
        country: country,
        nationalDigits: nationalDigits,
        rawInternational: null,
        contactName: _cleanContactName(name),
      );
    }

    return _DialState(
      country: _defaultCountry,
      nationalDigits: value.replaceAll(RegExp(r'\D'), ''),
      rawInternational: null,
      contactName: _cleanContactName(name),
    );
  }

  final _DialCountry country;
  final String nationalDigits;
  final String? rawInternational;
  final String? contactName;

  bool get hasInput => rawInternational != null || nationalDigits.isNotEmpty;

  String get displayNumber {
    final raw = rawInternational;
    if (raw != null) {
      if (raw == '+') return raw;
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      final prefixDigits = country.prefix.replaceAll(RegExp(r'\D'), '');
      if (digits.startsWith(prefixDigits)) {
        final national = digits.substring(prefixDigits.length);
        final formattedNational = country.format(national);
        return formattedNational.isEmpty
            ? country.prefix
            : '${country.prefix} $formattedNational';
      }
      return raw;
    }
    if (nationalDigits.isEmpty) return '';

    final formattedNational = country.format(nationalDigits);
    if (formattedNational.isEmpty) return country.prefix;
    return '${country.prefix} $formattedNational';
  }

  String get dialableNumber {
    final raw = rawInternational;
    if (raw != null) return raw.length > 1 ? raw : '';
    if (nationalDigits.isEmpty) return '';
    return '${country.prefix} $nationalDigits';
  }

  _DialState append(String digit) {
    final raw = rawInternational;
    if (raw != null) {
      final nextRaw = '$raw$digit';
      return _DialState(
        country: _countryForNumber(nextRaw),
        nationalDigits: '',
        rawInternational: nextRaw,
      );
    }

    return _DialState(
      country: country,
      nationalDigits: '$nationalDigits$digit',
      rawInternational: null,
    );
  }

  _DialState appendPlus() {
    if (!hasInput) {
      return const _DialState(
        country: _defaultCountry,
        nationalDigits: '',
        rawInternational: '+',
      );
    }

    final raw = rawInternational;
    if (raw != null) {
      return _DialState(
        country: country,
        nationalDigits: '',
        rawInternational: '$raw+',
      );
    }

    return this;
  }

  _DialState backspace() {
    final raw = rawInternational;
    if (raw != null) {
      final nextRaw = raw.substring(0, raw.length - 1);
      return _DialState(
        country: _countryForNumber(nextRaw),
        nationalDigits: '',
        rawInternational: nextRaw.isEmpty ? null : nextRaw,
      );
    }

    if (nationalDigits.isEmpty) return this;

    return _DialState(
      country: country,
      nationalDigits: nationalDigits.substring(0, nationalDigits.length - 1),
      rawInternational: null,
    );
  }

  static String? _cleanContactName(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}

class _DialCountry {
  const _DialCountry({
    required this.name,
    required this.prefix,
    required this.shortCode,
    required this.placeholder,
    required this.rate,
    required this.flag,
  });

  final String name;
  final String prefix;
  final String shortCode;
  final String placeholder;
  final String rate;
  final String flag;

  String format(String nationalDigits) {
    if (nationalDigits.isEmpty) return '';
    final formatted = PhoneMaskInputFormatter(placeholder).applyMask(
      nationalDigits,
    );
    if (placeholder.startsWith('(') &&
        nationalDigits.length >= 3 &&
        !formatted.contains(')')) {
      return '$formatted)';
    }
    return formatted;
  }
}

const _defaultCountry = _DialCountry(
  name: 'United States',
  prefix: '+1',
  shortCode: 'US',
  placeholder: '(000) 000-0000',
  rate: '\$0.02 / min',
  flag: '🇺🇸',
);

final _dialCountries = <_DialCountry>[
  _defaultCountry,
  const _DialCountry(
    name: 'Ethiopia',
    prefix: '+251',
    shortCode: 'ET',
    placeholder: '00 000 0000',
    rate: '\$0.22 / min',
    flag: '🇪🇹',
  ),
  const _DialCountry(
    name: 'United Kingdom',
    prefix: '+44',
    shortCode: 'GB',
    placeholder: '0000 000000',
    rate: '\$0.03 / min',
    flag: '🇬🇧',
  ),
  const _DialCountry(
    name: 'Kenya',
    prefix: '+254',
    shortCode: 'KE',
    placeholder: '000 000000',
    rate: '\$0.16 / min',
    flag: '🇰🇪',
  ),
  const _DialCountry(
    name: 'Nigeria',
    prefix: '+234',
    shortCode: 'NG',
    placeholder: '000 000 0000',
    rate: '\$0.18 / min',
    flag: '🇳🇬',
  ),
  for (final country in countries)
    if (country.name != 'United States')
      _DialCountry(
        name: country.name,
        prefix: country.prefix,
        shortCode: _shortCodeFor(country.name),
        placeholder: country.placeholder,
        rate: '\$0.02 / min',
        flag: _flagFor(country.name),
      ),
];

_DialCountry _countryForNumber(String value) {
  final normalized = value.replaceAll(RegExp(r'\s'), '');
  final matches = _dialCountries
      .where((country) => normalized.startsWith(country.prefix))
      .toList()
    ..sort((a, b) => b.prefix.length.compareTo(a.prefix.length));
  if (matches.isNotEmpty) return matches.first;
  return _defaultCountry;
}

String _shortCodeFor(String countryName) {
  return switch (countryName) {
    'Argentina' => 'AR',
    'Australia' => 'AU',
    'Austria' => 'AT',
    'Belgium' => 'BE',
    'Brazil' => 'BR',
    'Canada' => 'CA',
    'Chile' => 'CL',
    'Colombia' => 'CO',
    'Costa Rica' => 'CR',
    'Czech Republic' => 'CZ',
    'Singapore' => 'SG',
    _ => countryName.characters.take(2).toString().toUpperCase(),
  };
}

String _flagFor(String countryName) {
  return switch (countryName) {
    'Argentina' => '🇦🇷',
    'Australia' => '🇦🇺',
    'Austria' => '🇦🇹',
    'Belgium' => '🇧🇪',
    'Brazil' => '🇧🇷',
    'Canada' => '🇨🇦',
    'Chile' => '🇨🇱',
    'Colombia' => '🇨🇴',
    'Costa Rica' => '🇨🇷',
    'Czech Republic' => '🇨🇿',
    'Singapore' => '🇸🇬',
    _ => '🌐',
  };
}

class _NumberDisplay extends StatelessWidget {
  const _NumberDisplay({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    final hasNumber = number.trim().isNotEmpty;
    return SizedBox(
      height: 38,
      child: Center(
        child: Text(
          hasNumber ? number : 'Enter number',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: hasNumber
              ? ZuriTextStyles.dialpadEntry.copyWith(color: ZuriColors.ink)
              : ZuriTextStyles.compactPageTitle
                  .copyWith(color: ZuriColors.disabled),
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.country,
    required this.contactName,
  });

  final _DialCountry country;
  final String? contactName;

  @override
  Widget build(BuildContext context) {
    if (contactName != null) {
      return Text(
        contactName!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: ZuriTextStyles.pageSubtitle.copyWith(
          color: ZuriColors.muted,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(country.flag, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              country.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZuriTextStyles.dialpadContext.copyWith(
                color: ZuriColors.muted.withValues(alpha: 0.72),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              country.rate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZuriTextStyles.dialpadRate.copyWith(
                color: ZuriColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPad extends StatelessWidget {
  const _DialPad({
    required this.keySize,
    required this.keyGap,
    required this.rowGap,
    required this.onTap,
    required this.onPlus,
  });

  final double keySize;
  final double keyGap;
  final double rowGap;
  final ValueChanged<String> onTap;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    const rows = [
      [
        ('1', null),
        ('2', 'ABC'),
        ('3', 'DEF'),
      ],
      [
        ('4', 'GHI'),
        ('5', 'JKL'),
        ('6', 'MNO'),
      ],
      [
        ('7', 'PQRS'),
        ('8', 'TUV'),
        ('9', 'WXYZ'),
      ],
      [
        ('*', null),
        ('0', '+'),
        ('#', null),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < row.length; i++) ...[
                _DialKey(
                  label: row[i].$1,
                  sublabel: row[i].$2,
                  size: keySize,
                  onTap: onTap,
                  onLongPress: row[i].$1 == '0' ? onPlus : null,
                ),
                if (i < row.length - 1) SizedBox(width: keyGap),
              ],
            ],
          ),
          if (row != rows.last) SizedBox(height: rowGap),
        ],
      ],
    );
  }
}

class _CallActions extends StatelessWidget {
  const _CallActions({
    required this.canCall,
    required this.onStartCall,
    required this.onBackspace,
  });

  final bool canCall;
  final VoidCallback onStartCall;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: ZuriDimensions.callButtonHeight,
            child: _DialCallButton(
              enabled: canCall,
              onPressed: onStartCall,
            ),
          ),
          const SizedBox(width: 16),
          ZuriCircleButton(
            onPressed: onBackspace,
            icon: ZuriIcons.backspace,
            foregroundColor: canCall
                ? ZuriColors.ink
                : ZuriColors.ink.withValues(alpha: 0.34),
            backgroundColor: ZuriColors.callSurface.withValues(
              alpha: canCall ? 1 : 0.55,
            ),
            size: ZuriDimensions.dialpadActionSize,
          ),
        ],
      ),
    );
  }
}

class _DialCallButton extends StatelessWidget {
  const _DialCallButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        enabled ? ZuriColors.surface : ZuriColors.ink.withValues(alpha: 0.38);
    return SizedBox(
      height: ZuriDimensions.callButtonHeight,
      child: TextButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(ZuriIcons.phone, size: 18),
        label: const Text('Call now'),
        style: TextButton.styleFrom(
          backgroundColor: enabled
              ? ZuriColors.primary
              : ZuriColors.callSurface.withValues(alpha: 0.55),
          disabledBackgroundColor: ZuriColors.callSurface.withValues(
            alpha: 0.55,
          ),
          foregroundColor: foregroundColor,
          disabledForegroundColor: foregroundColor,
          shape: const StadiumBorder(),
          textStyle: ZuriTextStyles.primaryButtonLabel,
        ),
      ),
    );
  }
}

class _DialKey extends StatelessWidget {
  const _DialKey({
    required this.label,
    required this.onTap,
    required this.size,
    this.sublabel,
    this.onLongPress,
  });

  final String label;
  final ValueChanged<String> onTap;
  final double size;
  final String? sublabel;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isSymbol = label == '*' || label == '#';
    final radius = BorderRadius.circular(size / 2);
    return SizedBox.square(
      dimension: size,
      child: Material(
        color: ZuriColors.card,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => onTap(label),
          onLongPress: onLongPress,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: (isSymbol
                        ? ZuriTextStyles.bodyText
                        : ZuriTextStyles.dialpadKey)
                    .copyWith(color: ZuriColors.ink),
              ),
              SizedBox(
                height: 15,
                child: Center(
                  child: Text(
                    sublabel ?? '',
                    style: ZuriTextStyles.dialpadSublabel.copyWith(
                      color: ZuriColors.subtleForestText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
