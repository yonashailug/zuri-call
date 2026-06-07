import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../../core/widgets/zuri_scaffold.dart';

class RateDestination {
  const RateDestination({
    required this.name,
    required this.phone,
  });

  final String name;
  final String phone;
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    this.onCallDestination,
    super.key,
  });

  final ValueChanged<RateDestination>? onCallDestination;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  _WalletFlow flow = _WalletFlow.overview;

  @override
  Widget build(BuildContext context) {
    switch (flow) {
      case _WalletFlow.topUp:
        return _TopUpWalletScreen(
          onBack: () => setState(() => flow = _WalletFlow.overview),
        );
      case _WalletFlow.history:
        return _TransactionHistoryScreen(
          onBack: () => setState(() => flow = _WalletFlow.overview),
        );
      case _WalletFlow.rates:
        return _RateLookupScreen(
          onBack: () => setState(() => flow = _WalletFlow.overview),
          onCallDestination: widget.onCallDestination,
        );
      case _WalletFlow.overview:
        return _WalletOverview(
          onTopUp: () => setState(() => flow = _WalletFlow.topUp),
          onSeeAll: () => setState(() => flow = _WalletFlow.history),
          onRates: () => setState(() => flow = _WalletFlow.rates),
        );
    }
  }
}

enum _WalletFlow { overview, topUp, history, rates }

class _WalletOverview extends StatelessWidget {
  const _WalletOverview({
    required this.onTopUp,
    required this.onSeeAll,
    required this.onRates,
  });

  final VoidCallback onTopUp;
  final VoidCallback onSeeAll;
  final VoidCallback onRates;

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          ZuriSpacing.s5,
          32,
          ZuriSpacing.s5,
          ZuriDimensions.navOverlayBottomPadding,
        ),
        children: [
          const _WalletHeader(),
          const SizedBox(height: 28),
          const _BalanceCard(),
          const SizedBox(height: 18),
          _WalletActions(onTopUp: onTopUp, onRates: onRates),
          const SizedBox(height: 28),
          ZuriSectionHeader(
            label: 'RECENT ACTIVITY',
            trailing: TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: ZuriColors.primary,
                padding: EdgeInsets.zero,
                textStyle: ZuriTextStyles.chipLabel,
              ),
              child: const Text('See all'),
            ),
          ),
          const SizedBox(height: 14),
          const _ActivityRow(
            icon: ZuriIcons.arrowUpRight,
            title: 'Call • Yonas Hailu',
            subtitle: 'Today • 6m 12s • Ethiopia',
            amount: '-\$0.12',
            positive: false,
          ),
          const _ActivityRow(
            icon: ZuriIcons.wallet,
            title: 'Top up',
            subtitle: 'Yesterday • Visa ••4242',
            amount: '+\$5.00',
            positive: true,
          ),
          const _ActivityRow(
            icon: ZuriIcons.arrowUpRight,
            title: 'Call • +251 91 393 9493',
            subtitle: 'Yesterday • 0m 04s • Ethiopia',
            amount: '-\$0.01',
            positive: false,
          ),
          const _ActivityRow(
            icon: ZuriIcons.arrowUpRight,
            title: 'Call • +1 206 825 2969',
            subtitle: '2 days ago • 2m 30s • USA',
            amount: '-\$0.05',
            positive: false,
          ),
          const SizedBox(height: 18),
          const _RunwayTip(),
        ],
      ),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your balance',
                style: ZuriTextStyles.pageSubtitle.copyWith(
                  color: ZuriColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Wallet',
                style: ZuriTextStyles.pageTitle.copyWith(
                  color: ZuriColors.ink,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const _HeaderIconButton(icon: ZuriIcons.recents),
      ],
    );
  }
}

class _TopUpWalletScreen extends StatefulWidget {
  const _TopUpWalletScreen({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_TopUpWalletScreen> createState() => _TopUpWalletScreenState();
}

class _TopUpWalletScreenState extends State<_TopUpWalletScreen> {
  static const currentBalance = 4.88;
  double selectedAmount = 10;

  double get newBalance => currentBalance + selectedAmount;

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          ZuriSpacing.s5,
          32,
          ZuriSpacing.s5,
          ZuriDimensions.navOverlayBottomPadding,
        ),
        children: [
          _TopUpHeader(onBack: widget.onBack),
          const SizedBox(height: 34),
          Center(
            child: Column(
              children: [
                Text(
                  'Current balance',
                  style: ZuriTextStyles.topUpBalanceLabel.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '\$${currentBalance.toStringAsFixed(2)}',
                  style: ZuriTextStyles.topUpBalanceValue.copyWith(
                    color: ZuriColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const _WalletSectionLabel('CHOOSE AMOUNT'),
          const SizedBox(height: 16),
          _PresetAmountGrid(
            selectedAmount: selectedAmount,
            onSelected: (amount) => setState(() => selectedAmount = amount),
          ),
          const SizedBox(height: 14),
          const _CustomAmountField(),
          const SizedBox(height: 24),
          const _WalletSectionLabel('PAY WITH'),
          const SizedBox(height: 14),
          const _PaymentMethodCard(),
          const SizedBox(height: 12),
          const _AddPaymentMethodCard(),
          const SizedBox(height: 20),
          _TopUpPreviewCard(
            amount: selectedAmount,
            newBalance: newBalance,
          ),
          const SizedBox(height: 22),
          _SecurePayButton(amount: selectedAmount),
        ],
      ),
    );
  }
}

class _TopUpHeader extends StatelessWidget {
  const _TopUpHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ZuriBackButton(onPressed: onBack),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            'Top up wallet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ZuriTextStyles.topUpTitle.copyWith(
              color: ZuriColors.ink,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionHistoryScreen extends StatelessWidget {
  const _TransactionHistoryScreen({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          ZuriSpacing.s5,
          32,
          ZuriSpacing.s5,
          ZuriDimensions.navOverlayBottomPadding,
        ),
        children: [
          _HistoryHeader(onBack: onBack),
          const SizedBox(height: 24),
          const _HistorySummaryCards(),
          const SizedBox(height: 18),
          const _HistoryFilters(),
          const SizedBox(height: 20),
          const _HistoryDateGroup(
            label: 'TODAY',
            netAmount: '-\$0.12',
            positive: false,
            rows: [
              _HistoryTransactionRow(
                icon: ZuriIcons.arrowUpRight,
                title: 'Yonas Hailu',
                details: '6m 12s  •  \$0.02/min  •',
                chip: 'ET',
                amount: '-\$0.12',
                positive: false,
              ),
            ],
          ),
          const _HistoryDateGroup(
            label: 'YESTERDAY',
            netAmount: '+\$4.99',
            positive: true,
            rows: [
              _HistoryTransactionRow(
                icon: ZuriIcons.wallet,
                title: 'Top-up • Visa •••4242',
                details: '2:14 PM • Ref #ZW8847',
                amount: '+\$5.00',
                positive: true,
              ),
              _HistoryTransactionRow(
                icon: ZuriIcons.arrowUpRight,
                title: '+251 91 393 9493',
                details: '4s  •  \$0.02/min  •',
                chip: 'ET',
                amount: '-\$0.01',
                positive: false,
              ),
              _HistoryTransactionRow(
                icon: ZuriIcons.arrowUpRight,
                title: 'Maya Kim • +1 206',
                details: '2m 30s  •  \$0.02/min  •',
                chip: 'US',
                amount: '-\$0.05',
                positive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ZuriBackButton(onPressed: onBack),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'History',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ZuriTextStyles.pageTitle.copyWith(
              color: ZuriColors.ink,
              height: 1,
            ),
          ),
        ),
        const _HistoryToolButton(
          icon: ZuriIcons.filter,
          label: 'Filter',
        ),
        const SizedBox(width: 10),
        const _HistoryToolButton(
          icon: ZuriIcons.download,
          label: 'Export',
        ),
      ],
    );
  }
}

class _HistoryToolButton extends StatelessWidget {
  const _HistoryToolButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 19),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: ZuriColors.muted,
          backgroundColor: ZuriColors.card,
          side: const BorderSide(color: _WalletColors.border, width: 1.1),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          textStyle: ZuriTextStyles.emphasisText,
        ),
      ),
    );
  }
}

class _HistorySummaryCards extends StatelessWidget {
  const _HistorySummaryCards();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _HistorySummaryCard(
            label: 'Total spent',
            value: '\$2.14',
            subtitle: 'June 2026',
            dark: true,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _HistorySummaryCard(
            label: 'Total topped up',
            value: '\$7.00',
            subtitle: '2 transactions',
          ),
        ),
      ],
    );
  }
}

class _HistorySummaryCard extends StatelessWidget {
  const _HistorySummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    this.dark = false,
  });

  final String label;
  final String value;
  final String subtitle;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : ZuriColors.ink;
    final muted = dark ? _WalletColors.cardMuted : ZuriColors.muted;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: dark ? ZuriColors.primary : ZuriColors.card,
        borderRadius: BorderRadius.circular(ZuriRadius.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ZuriTextStyles.metadataStrong.copyWith(color: muted),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: ZuriTextStyles.metricValue.copyWith(color: foreground),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: ZuriTextStyles.metadataStrong.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ZuriFilterChip(
            height: null, horizontalPadding: 18, label: 'All', selected: true),
        SizedBox(width: 10),
        ZuriFilterChip(height: null, horizontalPadding: 18, label: 'Calls'),
        SizedBox(width: 10),
        ZuriFilterChip(height: null, horizontalPadding: 18, label: 'Top-ups'),
      ],
    );
  }
}

class _HistoryDateGroup extends StatelessWidget {
  const _HistoryDateGroup({
    required this.label,
    required this.netAmount,
    required this.positive,
    required this.rows,
  });

  final String label;
  final String netAmount;
  final bool positive;
  final List<_HistoryTransactionRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: ZuriTextStyles.supportingText.copyWith(
                  color: ZuriColors.muted,
                ),
              ),
            ),
            Text(
              netAmount,
              style: ZuriTextStyles.emphasisText.copyWith(
                color: positive ? ZuriColors.success : ZuriColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...rows,
        const SizedBox(height: 18),
      ],
    );
  }
}

class _HistoryTransactionRow extends StatelessWidget {
  const _HistoryTransactionRow({
    required this.icon,
    required this.title,
    required this.details,
    required this.amount,
    required this.positive,
    this.chip,
  });

  final IconData icon;
  final String title;
  final String details;
  final String amount;
  final bool positive;
  final String? chip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _WalletColors.rowDivider),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: positive
                  ? ZuriColors.success.withValues(alpha: 0.10)
                  : ZuriColors.neutralBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: positive ? ZuriColors.success : ZuriColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.cardTitle.copyWith(
                    color: ZuriColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            ZuriTextStyles.walletTransactionSubtitle.copyWith(
                          color: ZuriColors.muted,
                        ),
                      ),
                    ),
                    if (chip != null) ...[
                      const SizedBox(width: 8),
                      _CountryChip(label: chip!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: ZuriTextStyles.walletTransactionAmount.copyWith(
              color: positive ? ZuriColors.success : _WalletColors.debit,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateLookupScreen extends StatefulWidget {
  const _RateLookupScreen({
    required this.onBack,
    required this.onCallDestination,
  });

  final VoidCallback onBack;
  final ValueChanged<RateDestination>? onCallDestination;

  @override
  State<_RateLookupScreen> createState() => _RateLookupScreenState();
}

class _RateLookupScreenState extends State<_RateLookupScreen> {
  late final TextEditingController searchController =
      TextEditingController(text: 'Ethiopia');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const destination = RateDestination(
      name: 'Ethiopia',
      phone: '+251',
    );

    return ZuriScaffold(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                28,
                34,
                28,
                ZuriDimensions.navOverlayBottomPadding,
              ),
              children: [
                _RateLookupHeader(onBack: widget.onBack),
                const SizedBox(height: 26),
                _RateSearchField(
                  controller: searchController,
                  onClear: () => setState(searchController.clear),
                ),
                const SizedBox(height: 20),
                const _FeaturedRateCard(),
                const SizedBox(height: 26),
                const _WalletSectionLabel('FREQUENTLY CALLED'),
                const SizedBox(height: 18),
                const _RateDestinationRow(
                  flag: '🇪🇹',
                  name: 'Ethiopia',
                  subtitle: 'Mobile • +251',
                  rate: '\$0.02/min',
                  note: 'your top destination',
                ),
                const _RateDestinationRow(
                  flag: '🇺🇸',
                  name: 'United States',
                  subtitle: 'Mobile & landline • +1',
                  rate: '\$0.02/min',
                ),
                const _RateDestinationRow(
                  flag: '🇬🇧',
                  name: 'United Kingdom',
                  subtitle: 'Mobile • +44',
                  rate: '\$0.03/min',
                ),
                const _RateDestinationRow(
                  flag: '🇸🇦',
                  name: 'Saudi Arabia',
                  subtitle: 'Mobile • +966',
                  rate: '\$0.04/min',
                  showDivider: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              28,
              12,
              28,
              ZuriDimensions.navOverlayBottomPadding,
            ),
            child: SizedBox(
              height: 66,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => widget.onCallDestination?.call(destination),
                icon: const Icon(ZuriIcons.phone),
                label: const Text('Call Ethiopia now'),
                style: FilledButton.styleFrom(
                  backgroundColor: ZuriColors.primary,
                  foregroundColor: ZuriColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ZuriRadius.pill),
                  ),
                  textStyle: ZuriTextStyles.primaryButtonLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateLookupHeader extends StatelessWidget {
  const _RateLookupHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ZuriBackButton(onPressed: onBack),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            'Call rates',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ZuriTextStyles.pageTitle.copyWith(
              color: ZuriColors.ink,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _RateSearchField extends StatelessWidget {
  const _RateSearchField({
    required this.controller,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ZuriDimensions.searchBarHeight,
      child: TextField(
        controller: controller,
        autofocus: true,
        style: ZuriTextStyles.metadata.copyWith(
          color: ZuriColors.ink,
        ),
        decoration: InputDecoration(
          hintText: 'Search country or code',
          prefixIcon: const Icon(
            ZuriIcons.search,
            color: ZuriColors.searchPlaceholder,
            size: 15,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton.filledTonal(
              onPressed: onClear,
              icon: const Icon(ZuriIcons.close),
              color: ZuriColors.muted,
              style: IconButton.styleFrom(
                backgroundColor: ZuriColors.neutralBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ZuriRadius.small),
                ),
              ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ZuriRadius.field),
            borderSide: const BorderSide(color: ZuriColors.searchBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ZuriRadius.field),
            borderSide: const BorderSide(color: ZuriColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _FeaturedRateCard extends StatelessWidget {
  const _FeaturedRateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: ZuriColors.primary,
        borderRadius: BorderRadius.circular(ZuriRadius.field),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Text('🇪🇹', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ethiopia',
                      style: ZuriTextStyles.pageTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '+251 • East Africa',
                      style: ZuriTextStyles.emphasisText.copyWith(
                        color: _WalletColors.cardMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$0.02',
                    style: ZuriTextStyles.metricValue.copyWith(
                      color: Colors.white,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'per minute',
                    style: ZuriTextStyles.metadataStrong.copyWith(
                      color: _WalletColors.cardMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: _WalletColors.cardDivider, height: 1),
          const SizedBox(height: 22),
          const Row(
            children: [
              Expanded(
                child: ZuriMetricTile(
                  label: '50 min',
                  value: '\$1.00',
                  valueStyle: ZuriTextStyles.metricLabel,
                  valueColor: Colors.white,
                  labelColor: _WalletColors.cardMuted,
                ),
              ),
              _RateCalcDivider(),
              Expanded(
                child: ZuriMetricTile(
                  label: '250 min',
                  value: '\$5.00',
                  valueStyle: ZuriTextStyles.metricLabel,
                  valueColor: Colors.white,
                  labelColor: _WalletColors.cardMuted,
                ),
              ),
              _RateCalcDivider(),
              Expanded(
                child: ZuriMetricTile(
                  label: '500 min',
                  value: '\$10.00',
                  valueStyle: ZuriTextStyles.metricLabel,
                  valueColor: Colors.white,
                  labelColor: _WalletColors.cardMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateCalcDivider extends StatelessWidget {
  const _RateCalcDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 54,
      color: _WalletColors.cardDivider,
    );
  }
}

class _RateDestinationRow extends StatelessWidget {
  const _RateDestinationRow({
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.rate,
    this.note,
    this.showDivider = true,
  });

  final String flag;
  final String name;
  final String subtitle;
  final String rate;
  final String? note;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: _WalletColors.rowDivider),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(flag, style: const TextStyle(fontSize: 26)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.metricLabel.copyWith(
                    color: ZuriColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: ZuriTextStyles.bodyText.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rate,
                style: ZuriTextStyles.rowTitle.copyWith(
                  color: ZuriColors.ink,
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: 4),
                Text(
                  note!,
                  style: ZuriTextStyles.metadata.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: ZuriColors.callSurface,
        borderRadius: BorderRadius.circular(ZuriRadius.compact),
      ),
      child: Text(
        label,
        style: ZuriTextStyles.pageSubtitle.copyWith(
          color: ZuriColors.muted,
        ),
      ),
    );
  }
}

class _WalletSectionLabel extends StatelessWidget {
  const _WalletSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: ZuriTextStyles.supportingText.copyWith(
        color: ZuriColors.muted,
      ),
    );
  }
}

class _PresetAmountGrid extends StatelessWidget {
  const _PresetAmountGrid({
    required this.selectedAmount,
    required this.onSelected,
  });

  final double selectedAmount;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    const options = [
      _TopUpOption(amount: 5, minutes: 41),
      _TopUpOption(amount: 10, minutes: 83, popular: true),
      _TopUpOption(amount: 20, minutes: 166),
      _TopUpOption(amount: 50, minutes: 416),
    ];

    return GridView.builder(
      itemCount: options.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.82,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        return _PresetAmountCard(
          option: option,
          selected: selectedAmount == option.amount,
          onTap: () => onSelected(option.amount),
        );
      },
    );
  }
}

class _TopUpOption {
  const _TopUpOption({
    required this.amount,
    required this.minutes,
    this.popular = false,
  });

  final double amount;
  final int minutes;
  final bool popular;
}

class _PresetAmountCard extends StatelessWidget {
  const _PresetAmountCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _TopUpOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : ZuriColors.ink;
    final muted = selected ? _WalletColors.cardMuted : ZuriColors.muted;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(ZuriRadius.surface),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? ZuriColors.primary : ZuriColors.card,
                borderRadius: BorderRadius.circular(ZuriRadius.surface),
                border: Border.all(
                  color: selected ? ZuriColors.primary : _WalletColors.border,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${option.amount.toInt()}',
                    style: ZuriTextStyles.topUpOptionAmount.copyWith(
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '~${option.minutes} min to ET',
                    style: ZuriTextStyles.topUpOptionMinutes.copyWith(
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (option.popular)
          Positioned(
            top: -12,
            left: 34,
            right: 34,
            child: Container(
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _WalletColors.popular,
                borderRadius: BorderRadius.circular(ZuriRadius.field),
              ),
              child: Text(
                'Most popular',
                style: ZuriTextStyles.topUpBadge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CustomAmountField extends StatelessWidget {
  const _CustomAmountField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: ZuriColors.card,
        borderRadius: BorderRadius.circular(ZuriRadius.surface),
        border: Border.all(color: _WalletColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(ZuriIcons.edit, color: ZuriColors.muted, size: 22),
          const SizedBox(width: 14),
          Text(
            'Custom amount',
            style: ZuriTextStyles.topUpFieldText.copyWith(
              color: ZuriColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: ZuriColors.card,
        borderRadius: BorderRadius.circular(ZuriRadius.tile),
        border: Border.all(color: ZuriColors.primary, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ZuriColors.primary,
              borderRadius: BorderRadius.circular(ZuriRadius.compact),
            ),
            child: const Icon(
              ZuriIcons.creditCard,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visa •••4242',
                  style: ZuriTextStyles.topUpPaymentTitle.copyWith(
                    color: ZuriColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires 08/27',
                  style: ZuriTextStyles.topUpPaymentSubtitle.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: ZuriColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              ZuriIcons.check,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPaymentMethodCard extends StatelessWidget {
  const _AddPaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ZuriRadius.surface),
        border: Border.all(
          color: _WalletColors.border,
          width: 1.4,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ZuriColors.callSurface,
              borderRadius: BorderRadius.circular(ZuriRadius.compact),
            ),
            child: const Icon(ZuriIcons.add, color: ZuriColors.muted),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Add payment method',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZuriTextStyles.topUpFieldText.copyWith(
                color: ZuriColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopUpPreviewCard extends StatelessWidget {
  const _TopUpPreviewCard({
    required this.amount,
    required this.newBalance,
  });

  final double amount;
  final double newBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: BoxDecoration(
        color: ZuriColors.card,
        borderRadius: BorderRadius.circular(ZuriRadius.tile),
      ),
      child: Column(
        children: [
          ZuriInfoRow(
            compact: true,
            label: 'Top-up amount',
            value: '\$${amount.toStringAsFixed(2)}',
          ),
          const Divider(color: _WalletColors.rowDivider, height: 22),
          ZuriInfoRow(
            compact: true,
            label: 'New balance',
            value: '\$${newBalance.toStringAsFixed(2)}',
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _SecurePayButton extends StatelessWidget {
  const _SecurePayButton({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(ZuriIcons.lock, size: 22),
        label: Text('Pay \$${amount.toStringAsFixed(2)} securely'),
        style: FilledButton.styleFrom(
          backgroundColor: ZuriColors.primary,
          foregroundColor: ZuriColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZuriRadius.pill),
          ),
          textStyle: ZuriTextStyles.buttonStrong,
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 36,
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, size: 17),
        color: ZuriColors.primary,
        style: IconButton.styleFrom(
          backgroundColor: ZuriColors.neutralBg,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
      decoration: BoxDecoration(
        color: ZuriColors.primary,
        borderRadius: BorderRadius.circular(ZuriRadius.callAv),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Available balance',
                  style: ZuriTextStyles.emphasisText.copyWith(
                    color: _WalletColors.cardMuted,
                  ),
                ),
              ),
              const _ActiveBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$4.88',
            style: ZuriTextStyles.metricHero.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 26),
          const Divider(color: _WalletColors.cardDivider, height: 1),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: ZuriMetricTile(
                  label: 'This month',
                  value: '\$2.14 spent',
                  valueStyle: ZuriTextStyles.metricLabel,
                  valueColor: Colors.white.withValues(alpha: 0.86),
                  labelColor: _WalletColors.cardMuted,
                  alignment: CrossAxisAlignment.start,
                ),
              ),
              Expanded(
                child: ZuriMetricTile(
                  label: 'Avg. per call',
                  value: '\$0.08',
                  valueStyle: ZuriTextStyles.metricLabel,
                  valueColor: Colors.white.withValues(alpha: 0.86),
                  labelColor: _WalletColors.cardMuted,
                  alignment: CrossAxisAlignment.start,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _WalletColors.activeSoft,
        borderRadius: BorderRadius.circular(ZuriRadius.round),
        border: Border.all(color: _WalletColors.activeBorder, width: 1.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(ZuriIcons.check, color: ZuriColors.accent, size: 9),
          const SizedBox(width: 8),
          Text(
            'Active',
            style: ZuriTextStyles.supportingText.copyWith(
              color: _WalletColors.activeText,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletActions extends StatelessWidget {
  const _WalletActions({
    required this.onTopUp,
    required this.onRates,
  });

  final VoidCallback onTopUp;
  final VoidCallback onRates;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 66,
            child: FilledButton.icon(
              onPressed: onTopUp,
              icon: const Icon(ZuriIcons.add, size: 27),
              label: const Text('Top up'),
              style: FilledButton.styleFrom(
                backgroundColor: ZuriColors.primary,
                foregroundColor: ZuriColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ZuriRadius.pill),
                ),
                textStyle: ZuriTextStyles.primaryButtonLabel,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 66,
            child: OutlinedButton.icon(
              onPressed: onRates,
              icon: const Icon(ZuriIcons.world, size: 24),
              label: const Text('Rates'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ZuriColors.muted,
                side: const BorderSide(color: _WalletColors.border, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ZuriRadius.pill),
                ),
                textStyle: ZuriTextStyles.strongButtonLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.positive,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _WalletColors.rowDivider),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: positive
                  ? ZuriColors.success.withValues(alpha: 0.10)
                  : ZuriColors.neutralBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: positive ? ZuriColors.success : ZuriColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.primaryButtonLabel.copyWith(
                    color: ZuriColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.walletTransactionSubtitle.copyWith(
                    color: ZuriColors.muted,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: ZuriTextStyles.walletTransactionAmount.copyWith(
              color: positive ? ZuriColors.success : _WalletColors.debit,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunwayTip extends StatelessWidget {
  const _RunwayTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: _WalletColors.tipBackground,
        borderRadius: BorderRadius.circular(ZuriRadius.tile),
        border: Border.all(color: _WalletColors.tipBorder, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            ZuriIcons.bulb,
            color: _WalletColors.tipText,
            size: 25,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'At this rate your balance covers ~40 more minutes of calls to Ethiopia.',
              style: ZuriTextStyles.emphasisText.copyWith(
                color: _WalletColors.tipText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletColors {
  const _WalletColors._();

  static const cardMuted = ZuriColors.walletCardMuted;
  static const cardDivider = ZuriColors.walletCardDivider;
  static const activeSoft = ZuriColors.walletActiveSoft;
  static const activeBorder = ZuriColors.walletActiveBorder;
  static const activeText = ZuriColors.walletActiveText;
  static const border = ZuriColors.walletBorder;
  static const rowDivider = ZuriColors.walletRowDivider;
  static const debit = ZuriColors.walletDebit;
  static const popular = ZuriColors.walletPopular;
  static const tipBackground = ZuriColors.walletTipBackground;
  static const tipBorder = ZuriColors.walletTipBorder;
  static const tipText = ZuriColors.walletTipText;
}
