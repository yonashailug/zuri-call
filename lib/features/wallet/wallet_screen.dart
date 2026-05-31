import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/zuri_scaffold.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      title: 'Wallet',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: ZuriColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available credit',
                  style: TextStyle(color: ZuriColors.muted),
                ),
                SizedBox(height: 8),
                Text(
                  '$12.40',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'About 620 minutes to United States numbers',
                  style: TextStyle(color: ZuriColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: 'Add credits',
            icon: Icons.add_card_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 26),
          const Text(
            'Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const _TransactionRow(
            title: 'Credit purchase',
            subtitle: 'Today - Visa ending 4242',
            amount: '+$10.00',
            positive: true,
          ),
          const _TransactionRow(
            title: 'Call to Maya Kim',
            subtitle: 'Yesterday - 4m 23s',
            amount: '-$0.09',
            positive: false,
          ),
          const _TransactionRow(
            title: 'Call to Sweden',
            subtitle: 'May 28 - 12m 04s',
            amount: '-$0.72',
            positive: false,
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.positive,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: positive
                  ? ZuriColors.success.withOpacity(0.08)
                  : ZuriColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              positive ? Icons.add_rounded : Icons.call_made_rounded,
              color: positive ? ZuriColors.success : ZuriColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: ZuriColors.tertiary),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: positive ? ZuriColors.success : ZuriColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
