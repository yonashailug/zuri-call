import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/zuri_scaffold.dart';

class DialpadScreen extends StatefulWidget {
  const DialpadScreen({super.key});

  @override
  State<DialpadScreen> createState() => _DialpadScreenState();
}

class _DialpadScreenState extends State<DialpadScreen> {
  String number = '+1 ';

  void append(String digit) {
    setState(() => number += digit);
  }

  void backspace() {
    if (number.isEmpty) return;
    setState(() => number = number.substring(0, number.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      title: 'Dial pad',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              number.trim().isEmpty ? 'Enter number' : number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'United States - estimated $0.02/min',
              style: TextStyle(color: ZuriColors.muted),
            ),
            const Spacer(),
            GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.25,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 12,
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  color: ZuriColors.muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Call now',
                    icon: Icons.call_rounded,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: backspace,
                  icon: const Icon(Icons.backspace_rounded),
                  color: ZuriColors.muted,
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
      borderRadius: BorderRadius.circular(18),
      onTap: () => onTap(label),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZuriColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (sublabel != null)
              Text(
                sublabel!,
                style: const TextStyle(
                  color: ZuriColors.tertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
