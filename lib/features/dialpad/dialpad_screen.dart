import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';

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
  late String number = _initialNumber;

  String get _initialNumber {
    final value = widget.initialNumber?.trim();
    if (value != null && value.isNotEmpty) return value;
    return '';
  }

  bool get canCall => number.replaceAll(RegExp(r'\D'), '').isNotEmpty;

  @override
  void didUpdateWidget(DialpadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNumber != oldWidget.initialNumber) {
      number = _initialNumber;
    }
  }

  void append(String digit) {
    setState(() {
      number += digit;
    });
  }

  void appendPlus() {
    setState(() {
      if (number.isEmpty) {
        number = '+';
      } else {
        number += '+';
      }
    });
  }

  void backspace() {
    if (number.isEmpty) return;
    setState(() => number = number.substring(0, number.length - 1));
  }

  void startCall() {
    final trimmedNumber = number.trim();
    if (trimmedNumber.isEmpty) return;

    final dialableNumber =
        trimmedNumber.startsWith('+') ? trimmedNumber : '+1 $trimmedNumber';
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
            final horizontalPadding = constraints.maxWidth < 380 ? 24.0 : 28.0;
            final padWidth = constraints.maxWidth * 0.76;
            final keyGap = constraints.maxWidth * 0.055;
            final keyWidth =
                ((padWidth - keyGap * 2) / 3).clamp(78.0, 94.0).toDouble();
            final keyHeight = (keyWidth * 0.91).clamp(70.0, 84.0).toDouble();
            final rowGap = compactHeight ? 10.0 : 12.0;
            final topGap = compactHeight ? 14.0 : 18.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                16,
              ),
              child: Column(
                children: [
                  const _DialHeader(),
                  SizedBox(height: topGap),
                  _NumberDisplay(number: number),
                  const SizedBox(height: 12),
                  _RateRow(
                    contactName:
                        number.trim().isEmpty ? null : widget.contactName,
                  ),
                  SizedBox(height: compactHeight ? 16 : 22),
                  _DialPad(
                    keyWidth: keyWidth,
                    keyHeight: keyHeight,
                    rowGap: rowGap,
                    keyGap: keyGap,
                    onTap: append,
                    onPlus: appendPlus,
                  ),
                  const Spacer(),
                  _CallActions(
                    canCall: canCall,
                    onStartCall: startCall,
                    onBackspace: backspace,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DialHeader extends StatelessWidget {
  const _DialHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Dial',
          style: ZuriTextStyles.screenTitle.copyWith(
            color: ZuriColors.ink,
            fontSize: 30,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const ShapeDecoration(
            color: ZuriColors.primary,
            shape: StadiumBorder(),
          ),
          child: Text(
            'US +1',
            style: ZuriTextStyles.eyebrow.copyWith(
              color: ZuriColors.surface,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
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
          style: (hasNumber
                  ? ZuriTextStyles.control.copyWith(
                      color: ZuriColors.ink,
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    )
                  : ZuriTextStyles.bodyLarge.copyWith(
                      color: ZuriColors.disabled,
                      fontWeight: FontWeight.w500,
                      fontSize: 22,
                    ))
              .copyWith(letterSpacing: 0),
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({required this.contactName});

  final String? contactName;

  @override
  Widget build(BuildContext context) {
    if (contactName != null) {
      return Text(
        contactName!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: ZuriTextStyles.bodyLarge.copyWith(
          color: ZuriColors.muted,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇺🇸', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'United States',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZuriTextStyles.bodyLarge.copyWith(
                color: ZuriColors.muted.withValues(alpha: 0.72),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              '\$0.02 / min',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZuriTextStyles.bodyLarge.copyWith(
                color: ZuriColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 15,
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
    required this.keyWidth,
    required this.keyHeight,
    required this.rowGap,
    required this.keyGap,
    required this.onTap,
    required this.onPlus,
  });

  final double keyWidth;
  final double keyHeight;
  final double rowGap;
  final double keyGap;
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
              for (final item in row) ...[
                _DialKey(
                  label: item.$1,
                  sublabel: item.$2,
                  width: keyWidth,
                  height: keyHeight,
                  onTap: onTap,
                  onLongPress: item.$1 == '0' ? onPlus : null,
                ),
                if (item != row.last) SizedBox(width: keyGap),
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
        children: [
          ZuriCircleButton(
            onPressed: () {},
            icon: Icons.person_add_alt_1_rounded,
            foregroundColor: ZuriColors.ink,
            backgroundColor: ZuriColors.callSurface,
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _DialCallButton(
              enabled: canCall,
              onPressed: onStartCall,
            ),
          ),
          const SizedBox(width: 14),
          ZuriCircleButton(
            onPressed: onBackspace,
            icon: Icons.backspace_outlined,
            foregroundColor: ZuriColors.ink,
            backgroundColor: ZuriColors.callSurface,
            size: 52,
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
      height: 52,
      child: TextButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.call_outlined, size: 20),
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
          textStyle: ZuriTextStyles.control.copyWith(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DialKey extends StatelessWidget {
  const _DialKey({
    required this.label,
    required this.onTap,
    required this.width,
    required this.height,
    this.sublabel,
    this.onLongPress,
  });

  final String label;
  final ValueChanged<String> onTap;
  final double width;
  final double height;
  final String? sublabel;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isSymbol = label == '*' || label == '#';
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: ZuriColors.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTap(label),
          onLongPress: onLongPress,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: ZuriColors.ink.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: (isSymbol
                          ? ZuriTextStyles.control.copyWith(
                              fontWeight: FontWeight.w400,
                            )
                          : ZuriTextStyles.compactTitle.copyWith(
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                            ))
                      .copyWith(color: ZuriColors.ink),
                ),
                SizedBox(
                  height: 16,
                  child: Center(
                    child: Text(
                      sublabel ?? '',
                      style: ZuriTextStyles.eyebrow.copyWith(
                        color: ZuriColors.muted.withValues(alpha: 0.62),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
