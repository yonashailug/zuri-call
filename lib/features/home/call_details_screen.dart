import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/phone_country_lookup.dart';
import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../../core/widgets/zuri_scaffold.dart';
import 'call_record.dart';
import 'contact_preview.dart';

class CallDetailsScreen extends StatelessWidget {
  const CallDetailsScreen({
    required this.call,
    required this.onBack,
    required this.onCallBack,
    this.showSaveContact = false,
    this.onDelete,
    super.key,
  });

  final CallRecord call;
  final VoidCallback onBack;
  final ValueChanged<ContactPreview> onCallBack;
  final bool showSaveContact;
  final ValueChanged<CallRecord>? onDelete;

  @override
  Widget build(BuildContext context) {
    final contact = call.contact;
    final connected = call.isConnected;
    final statusColor = connected ? ZuriColors.success : ZuriColors.danger;

    return ZuriScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ZuriBackButton(onPressed: onBack),
          ),
          const SizedBox(height: 42),
          _HeroAvatar(call: call),
          const SizedBox(height: 24),
          Text(
            call.name,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.compactPageTitle.copyWith(
              color: ZuriColors.ink,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            call.phone,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.bodyText.copyWith(color: ZuriColors.muted),
          ),
          const SizedBox(height: 14),
          _RateLine(call: call),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.center,
            child: _StatusPill(
              label: '${call.direction.label} · ${call.resultLabel}',
              color: statusColor,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: _CallBackButton(
                    onPressed: () => onCallBack(contact),
                  ),
                ),
              ),
              if (showSaveContact) ...[
                const SizedBox(width: 14),
                ZuriCircleButton(
                  icon: ZuriIcons.userPlus,
                  onPressed: () {},
                  foregroundColor: ZuriColors.ink,
                  backgroundColor: ZuriColors.endedCallPill,
                  size: 56,
                  iconSize: 22,
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _DetailsCard(call: call),
          const SizedBox(height: 18),
          _ActionsCard(
            call: call,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({required this.call});

  final CallRecord call;

  @override
  Widget build(BuildContext context) {
    final contact = call.contact;
    final connected = call.isConnected;
    final ringColor = connected
        ? ZuriColors.success.withValues(alpha: 0.34)
        : ZuriColors.danger.withValues(alpha: 0.22);
    final flag = call.countryFlag;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: 3),
        ),
        child: ZuriAvatar(
          label: contact.initials,
          color: contact.color,
          size: 96,
          badge: flag == null
              ? null
              : Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: ZuriColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(flag, style: const TextStyle(fontSize: 14)),
                ),
        ),
      ),
    );
  }
}

class _RateLine extends StatelessWidget {
  const _RateLine({required this.call});

  final CallRecord call;

  @override
  Widget build(BuildContext context) {
    final flag = call.countryFlag;
    final country = call.countryName;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (flag != null) ...[
              Text(flag, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                country == null
                    ? call.rateLabel
                    : '$country · ${call.rateLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZuriTextStyles.dialpadContext.copyWith(
                  color: ZuriColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color.withValues(alpha: 0.10),
          shape: StadiumBorder(
            side: BorderSide(color: color.withValues(alpha: 0.28)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(ZuriIcons.arrowUpRight, size: 14, color: color),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.chipLabel.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallBackButton extends StatelessWidget {
  const _CallBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(ZuriIcons.phone, size: 22),
      label: const Text('Call back'),
      style: TextButton.styleFrom(
        backgroundColor: ZuriColors.primary,
        foregroundColor: ZuriColors.surface,
        shape: const StadiumBorder(),
        textStyle: ZuriTextStyles.primaryButtonLabel.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.call});

  final CallRecord call;

  @override
  Widget build(BuildContext context) {
    final connected = call.isConnected;

    return _GroupedCard(
      children: [
        _DetailRow(
          label: 'Call result',
          value: call.resultLabel,
          icon: connected ? ZuriIcons.check : ZuriIcons.close,
          valueColor: connected ? ZuriColors.success : ZuriColors.danger,
        ),
        _DetailRow(
          label: 'You called',
          value: call.direction.label,
          icon: ZuriIcons.arrowUpRight,
        ),
        _DetailRow(
          label: 'Duration',
          value: call.readableDurationLabel,
          valueColor: connected ? ZuriColors.ink : ZuriColors.muted,
        ),
        _DetailRow(
          label: 'Cost',
          value: call.costLabel,
          valueColor: connected ? ZuriColors.danger : ZuriColors.success,
        ),
        _DetailRow(label: 'Time', value: call.readableStartedAtLabel),
        _DetailRow(
          label: 'Rate',
          value: '${call.countryFlag ?? ''} ${call.rateLabel}'.trim(),
        ),
      ],
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.call,
    required this.onDelete,
  });

  final CallRecord call;
  final ValueChanged<CallRecord>? onDelete;

  @override
  Widget build(BuildContext context) {
    return _GroupedCard(
      children: [
        _ActionRow(
          icon: ZuriIcons.copy,
          label: 'Copy number',
          onTap: () {
            Clipboard.setData(ClipboardData(text: call.phone));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Number copied'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        _ActionRow(
          icon: ZuriIcons.document,
          label: 'Share number',
          onTap: () {
            Clipboard.setData(ClipboardData(text: call.phone));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Number copied'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        if (onDelete != null)
          _ActionRow(
            icon: ZuriIcons.trash,
            label: 'Delete from recents',
            destructive: true,
            onTap: () => onDelete!(call),
          ),
      ],
    );
  }
}

class _GroupedCard extends StatelessWidget {
  const _GroupedCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dividerColor = ZuriColors.rowDivider.withValues(alpha: 0.55);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZuriColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: dividerColor,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? ZuriColors.ink;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: ZuriTextStyles.bodyText.copyWith(
                color: ZuriColors.muted,
              ),
            ),
          ),
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: ZuriTextStyles.bodyText.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? ZuriColors.danger : ZuriColors.ink;
    final background = destructive ? ZuriColors.dangerBg : ZuriColors.neutralBg;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 40,
                child: Icon(icon, size: 18, color: color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: ZuriTextStyles.bodyText.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              ZuriIcons.chevronRight,
              size: 18,
              color: ZuriColors.disabled,
            ),
          ],
        ),
      ),
    );
  }
}

extension on CallRecord {
  bool get isConnected => status == CallStatus.completed && durationSeconds > 0;

  String get resultLabel {
    if (isConnected) return 'Connected';
    return "Didn't connect";
  }

  String get readableDurationLabel {
    if (!isConnected) return "Didn't connect";
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) return '$seconds sec';
    if (seconds == 0) return '$minutes min';
    return '$minutes min $seconds sec';
  }

  String get readableStartedAtLabel {
    final local = startedAt.toLocal();
    final now = DateTime.now();
    final datePrefix = _sameDate(local, now)
        ? 'Today'
        : _sameDate(local, now.subtract(const Duration(days: 1)))
            ? 'Yesterday'
            : '${local.month}/${local.day}/${local.year}';
    return '$datePrefix, ${_timeLabel(local)}';
  }

  String get costLabel {
    if (!isConnected) return r'$0.00 · No charge';
    final cost = _estimatedCost;
    return '\$${cost.toStringAsFixed(2)} charged';
  }

  double get _estimatedCost {
    final minutes = durationSeconds / 60;
    return minutes * ratePerMinute;
  }

  double get ratePerMinute {
    final code = PhoneCountryLookup.codeFor(phone);
    return switch (code) {
      'ET' => 0.02,
      'KE' => 0.16,
      'NG' => 0.18,
      'GB' => 0.03,
      _ => 0.02,
    };
  }

  String get rateLabel => '\$${ratePerMinute.toStringAsFixed(2)} / min';

  String? get countryFlag => PhoneCountryLookup.flagFor(phone);

  String? get countryName {
    final code = PhoneCountryLookup.codeFor(phone);
    return switch (code) {
      'ET' => 'Ethiopia',
      'KE' => 'Kenya',
      'NG' => 'Nigeria',
      'GB' => 'United Kingdom',
      'US' => 'United States',
      _ => null,
    };
  }

  bool _sameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _timeLabel(DateTime value) {
    final hour = value.hour == 0
        ? 12
        : value.hour > 12
            ? value.hour - 12
            : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
