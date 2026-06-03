import 'package:flutter/material.dart';

import '../theme/zuri_theme.dart';
import 'zuri_components.dart';
import 'zuri_icons.dart';
import 'zuri_tokens.dart';

// ── ZuriInfoRow ───────────────────────────────────────────────────────────────
//
// A horizontal label / value row used in detail panels, call summaries, and
// top-up preview cards.
//
// compact: false (default) — both label and value use body (16sp SemiBold).
//   Maps to: _DetailsRow (call_details_screen)
//
// compact: true — label uses meta (14sp Medium), value uses body (16sp SemiBold).
//   Maps to: _SummaryRow (in_call_screen), _PreviewRow (wallet_screen)
//
// strong: true — value weight is raised to w700.
//   Maps to: _PreviewRow 'New balance' line.

class ZuriInfoRow extends StatelessWidget {
  const ZuriInfoRow({
    required this.label,
    required this.value,
    this.compact = false,
    this.strong = false,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    super.key,
  });

  final String label;
  final String value;

  /// true → label uses meta (14sp), false → label uses body (16sp).
  final bool compact;

  /// true → value rendered at w700, false → value at default weight.
  final bool strong;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final labelStyle = (compact ? ZuriTextStyles.meta : ZuriTextStyles.body)
        .copyWith(color: ZuriColors.muted);

    final valueStyle = ZuriTextStyles.body.copyWith(
      color: ZuriColors.ink,
      fontWeight: strong ? FontWeight.w700 : null,
    );

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: labelStyle),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: valueStyle,
          ),
        ],
      ),
    );
  }
}

// ── ZuriMetricTile ────────────────────────────────────────────────────────────
//
// A stacked label + value tile used in summary cards, balance cards, and rate
// calculation displays.
//
// Defaults to center alignment with compactTitle for the value — the in-call
// summary card pattern. Pass valueStyle and alignment overrides for other uses:
//
//   _SummaryMetric  → ZuriMetricTile(label, value, labelColor: muted)
//   _BalanceMetric  → ZuriMetricTile(..., valueStyle: metricLabel,
//                       valueColor: Colors.white.withValues(alpha: 0.86),
//                       alignment: CrossAxisAlignment.start)
//   _RateMinuteCalc → ZuriMetricTile(label: '$minutes min', value: amount,
//                       valueStyle: metricLabel, valueColor: Colors.white,
//                       labelColor: cardMuted)

class ZuriMetricTile extends StatelessWidget {
  const ZuriMetricTile({
    required this.label,
    required this.value,
    this.valueStyle,
    this.labelColor,
    this.valueColor,
    this.alignment = CrossAxisAlignment.center,
    super.key,
  });

  final String label;
  final String value;

  /// Defaults to ZuriTextStyles.compactTitle.
  final TextStyle? valueStyle;

  /// Defaults to ZuriColors.muted.
  final Color? labelColor;

  /// Defaults to ZuriColors.ink.
  final Color? valueColor;

  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: ZuriTextStyles.metadataStrong.copyWith(
            color: labelColor ?? ZuriColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: (valueStyle ?? ZuriTextStyles.compactTitle).copyWith(
            color: valueColor ?? ZuriColors.ink,
          ),
        ),
      ],
    );
  }
}

// ── ZuriFilterChip ────────────────────────────────────────────────────────────
//
// A pill-shaped toggle chip for filter rows.
// Selected state: primary fill, white text.
// Unselected: transparent fill, border + muted text.
//
// Replaces: _ContactFilterChip (contacts_screen), _HistoryFilterPill (wallet)

class ZuriFilterChip extends StatelessWidget {
  const ZuriFilterChip({
    required this.label,
    this.selected = false,
    this.onTap,
    this.height = 40.0,
    this.horizontalPadding = 16.0,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Fixed height. Pass null to let padding drive the height.
  final double? height;

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    Widget chip = GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: selected ? ZuriColors.primary : Colors.transparent,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? ZuriColors.primary : ZuriColors.border,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: ZuriTextStyles.chipLabel.copyWith(
            color: selected ? Colors.white : ZuriColors.muted,
          ),
        ),
      ),
    );

    return chip;
  }
}

// ── ZuriSectionHeader ─────────────────────────────────────────────────────────
//
// An eyebrow-style section header row: uppercase label on the left, optional
// trailing widget on the right.
//
// Replaces: _RecentSectionHeader (contacts_screen), _ActivityHeader (wallet)
//
// Usage:
//   ZuriSectionHeader(label: 'TODAY',
//     trailing: Text('5 calls', style: ZuriTextStyles.sectionCount...))
//
//   ZuriSectionHeader(label: 'RECENT ACTIVITY',
//     trailing: TextButton(onPressed: ..., child: Text('See all')))

class ZuriSectionHeader extends StatelessWidget {
  const ZuriSectionHeader({
    required this.label,
    this.trailing,
    super.key,
  });

  final String label;

  /// Optional right-aligned content (count label, action button, etc.).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: ZuriTextStyles.sectionHeader.copyWith(
              color: ZuriColors.muted,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── ZuriMenuRow ───────────────────────────────────────────────────────────────
//
// A ListTile-based menu / action row with an icon, label, optional chevron, and
// destructive coloring.
//
// Replaces: _SettingsRow (settings_screen), _DetailsAction (call_details_screen)
//
// showChevron defaults to true. Pass false for action rows that don't navigate
// (e.g. 'Delete', 'Copy number').

class ZuriMenuRow extends StatelessWidget {
  const ZuriMenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.showChevron = true,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 2),
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  /// Whether to show a trailing chevron. Defaults to true.
  /// Automatically hidden when destructive = true.
  final bool showChevron;

  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? ZuriColors.danger : ZuriColors.ink;
    final showTrailing = showChevron && !destructive;

    return ListTile(
      contentPadding: contentPadding,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: ZuriTextStyles.rowPrimary.copyWith(color: color),
      ),
      trailing: showTrailing
          ? const Icon(ZuriIcons.chevronRight, color: ZuriColors.muted)
          : null,
      onTap: onTap,
    );
  }
}

// ── ZuriEmptyState ────────────────────────────────────────────────────────────
//
// A panel-wrapped empty state with icon, title, body text, and an optional
// single CTA button.
//
// Promoted from _EmptyState in contacts_screen.dart.

class ZuriEmptyState extends StatelessWidget {
  const ZuriEmptyState({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ZuriPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(icon, color: ZuriColors.primary, size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.cardTitle,
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.cardSubtitle.copyWith(
              color: ZuriColors.muted,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  backgroundColor: ZuriColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  textStyle: ZuriTextStyles.secondaryButtonLabel,
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
