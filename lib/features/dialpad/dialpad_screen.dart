import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../../core/widgets/zuri_scaffold.dart';

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
    return '+1 ';
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
      if (number == '+1 ' && digit == '0') {
        number = '+';
        return;
      }
      number += digit;
    });
  }

  void backspace() {
    if (number.isEmpty) return;
    setState(() => number = number.substring(0, number.length - 1));
  }

  void startCall() {
    final trimmedNumber = number.trim();
    if (trimmedNumber.isEmpty) return;

    widget.onStartCall(trimmedNumber);
  }

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      title: 'Dial pad',
      child: Padding(
        padding: ZuriSpacing.screenCompact,
        child: Column(
          children: [
            Text(
              number.trim().isEmpty ? 'Enter number' : number,
              textAlign: TextAlign.center,
              style: ZuriTextStyles.compactTitle.copyWith(
                color: ZuriColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.contactName == null
                  ? 'United States - estimated \$0.02/min'
                  : widget.contactName!,
              style: ZuriTextStyles.bodyLarge.copyWith(
                color: ZuriColors.muted,
              ),
            ),
            const Spacer(),
            GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 14,
              children: [
                _DialKey(label: '1', onTap: append),
                _DialKey(label: '2', sublabel: 'ABC', onTap: append),
                _DialKey(label: '3', sublabel: 'DEF', onTap: append),
                _DialKey(label: '4', sublabel: 'GHI', onTap: append),
                _DialKey(label: '5', sublabel: 'JKL', onTap: append),
                _DialKey(label: '6', sublabel: 'MNO', onTap: append),
                _DialKey(label: '7', sublabel: 'PQRS', onTap: append),
                _DialKey(label: '8', sublabel: 'TUV', onTap: append),
                _DialKey(label: '9', sublabel: 'WXYZ', onTap: append),
                _DialKey(label: '*', onTap: append),
                _DialKey(label: '0', sublabel: '+', onTap: append),
                _DialKey(label: '#', onTap: append),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ZuriCircleButton(
                  onPressed: () {},
                  icon: Icons.person_add_alt_1_rounded,
                  foregroundColor: ZuriColors.muted,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ZuriPillButton(
                    label: 'Call now',
                    icon: Icons.call_rounded,
                    onPressed: canCall ? startCall : null,
                  ),
                ),
                const SizedBox(width: 12),
                ZuriCircleButton(
                  onPressed: backspace,
                  icon: Icons.backspace_rounded,
                  foregroundColor: ZuriColors.muted,
                  size: 48,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialKey extends StatelessWidget {
  const _DialKey({
    required this.label,
    required this.onTap,
    this.sublabel,
  });

  final String label;
  final ValueChanged<String> onTap;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(ZuriRadius.panel),
      onTap: () => onTap(label),
      child: Ink(
        decoration: BoxDecoration(
          color: ZuriColors.card,
          borderRadius: BorderRadius.circular(ZuriRadius.panel),
          border: Border.all(color: ZuriColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: ZuriTextStyles.compactTitle.copyWith(
                color: ZuriColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (sublabel != null)
              Text(
                sublabel!,
                style: ZuriTextStyles.eyebrow.copyWith(
                  color: ZuriColors.muted,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
