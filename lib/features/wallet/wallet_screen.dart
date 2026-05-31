import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../../core/widgets/zuri_scaffold.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      title: 'Wallet',
      child: ListView(
        padding: ZuriSpacing.screenCompact,
        children: [
          ZuriPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available credit',
                  style: ZuriTextStyles.label.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$12.40',
                  style: ZuriTextStyles.display,
                ),
                const SizedBox(height: 10),
                Text(
                  'About 620 minutes to United States numbers',
                  style: ZuriTextStyles.bodyLarge.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ZuriPillButton(
            label: 'Add credits',
            icon: Icons.add_card_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 30),
          const Text(
            'Transactions',
            style: ZuriTextStyles.sectionTitle,
          ),
          const SizedBox(height: 12),
          const _TransactionRow(
            title: 'Credit purchase',
            subtitle: 'Today - Visa ending 4242',
            amount: '+\$10.00',
            positive: true,
          ),
          const _TransactionRow(
            title: 'Call to Maya Kim',
            subtitle: 'Yesterday - 4m 23s',
            amount: '-\$0.09',
            positive: false,
          ),
          const _TransactionRow(
            title: 'Call to Sweden',
            subtitle: 'May 28 - 12m 04s',
            amount: '-\$0.72',
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
                  ? ZuriColors.success.withValues(alpha: 0.08)
                  : ZuriColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(ZuriRadius.panel),
            ),
            child: Icon(
              positive ? Icons.add_rounded : Icons.call_made_rounded,
              color: positive ? ZuriColors.success : ZuriColors.ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ZuriTextStyles.rowTitle.copyWith(fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: ZuriTextStyles.rowMeta.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: ZuriTextStyles.rowTitle.copyWith(
              color: positive ? ZuriColors.success : ZuriColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
