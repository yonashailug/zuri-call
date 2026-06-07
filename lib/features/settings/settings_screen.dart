import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../../core/widgets/zuri_scaffold.dart';
import '../auth/application/auth_scope.dart';
import '../auth/application/auth_session_summary.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final sessionSummary = AuthSessionSummary.fromSession(
      authController.state.session,
    );

    return ZuriScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          ZuriSpacing.s5,
          32,
          ZuriSpacing.s5,
          ZuriDimensions.navOverlayBottomPadding,
        ),
        children: [
          Text(
            'Settings',
            style: ZuriTextStyles.pageTitle.copyWith(
              color: ZuriColors.ink,
              height: 1,
            ),
          ),
          const SizedBox(height: 26),
          _SettingsProfileCard(sessionSummary: sessionSummary),
          const SizedBox(height: 26),
          _SettingsSection(
            label: 'ACCOUNT & CALLING',
            rows: [
              _SettingsRow(
                icon: ZuriIcons.account,
                iconColor: ZuriColors.forest800,
                iconBackground: ZuriColors.iconButtonBg,
                title: 'Account',
                subtitle: _joinContext([
                  sessionSummary.greetingName,
                  sessionSummary.phoneDisplay,
                ]),
                onTap: () {},
              ),
              const _SettingsRow(
                icon: ZuriIcons.wallet,
                iconColor: ZuriColors.warning,
                iconBackground: ZuriColors.walletTipBackground,
                title: 'Wallet',
                subtitle: 'Balance & top-up',
                trailingValue: '\$4.88',
                trailingColor: ZuriColors.success,
              ),
              const _SettingsRow(
                icon: ZuriIcons.world,
                iconColor: ZuriColors.forest600,
                iconBackground: ZuriColors.forest50,
                title: 'Call rates',
                subtitle: 'View all destinations',
                trailingValue: '🇪🇹  \$0.02/min',
              ),
              const _SettingsRow(
                icon: ZuriIcons.language,
                iconColor: ZuriColors.forest600,
                iconBackground: ZuriColors.forest50,
                title: 'Default country',
                subtitle: 'Auto-added when dialling',
                trailingValue: '🇪🇹  +251',
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SettingsSection(
            label: 'PREFERENCES',
            rows: [
              _SettingsRow(
                icon: ZuriIcons.bulb,
                iconColor: ZuriColors.walletActiveBorder,
                iconBackground: ZuriColors.forest50,
                title: 'Notifications',
                subtitle: 'Incoming calls & alerts',
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() => notificationsEnabled = value);
                  },
                ),
              ),
              const _SettingsRow(
                icon: ZuriIcons.speaker,
                iconColor: ZuriColors.forest800,
                iconBackground: ZuriColors.iconButtonBg,
                title: 'Audio & call quality',
                subtitle: 'Codec, network settings',
              ),
            ],
          ),
          const SizedBox(height: 26),
          const _SettingsSection(
            label: 'SUPPORT',
            rows: [
              _SettingsRow(
                icon: ZuriIcons.support,
                iconColor: ZuriColors.forest600,
                iconBackground: ZuriColors.forest50,
                title: 'Help & support',
                subtitle: 'Contact us, FAQs',
              ),
              _SettingsRow(
                icon: ZuriIcons.star,
                iconColor: ZuriColors.warning,
                iconBackground: ZuriColors.walletTipBackground,
                title: 'Rate Zuri',
                subtitle: 'Leave a review on the App Store',
              ),
            ],
          ),
          const SizedBox(height: 26),
          const _SettingsSection(
            label: 'LEGAL',
            rows: [
              _SettingsRow(
                icon: ZuriIcons.privacy,
                iconColor: ZuriColors.disabled,
                iconBackground: ZuriColors.iconButtonBg,
                title: 'Privacy policy',
              ),
              _SettingsRow(
                icon: ZuriIcons.document,
                iconColor: ZuriColors.disabled,
                iconBackground: ZuriColors.iconButtonBg,
                title: 'Terms of service',
              ),
              _SettingsRow(
                icon: ZuriIcons.emergency,
                iconColor: ZuriColors.disabled,
                iconBackground: ZuriColors.iconButtonBg,
                title: 'Emergency calling',
                subtitle: 'Limitations notice',
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SettingsSection(
            label: 'ACCOUNT',
            labelColor: ZuriColors.danger.withValues(alpha: 0.65),
            rows: [
              _SettingsRow(
                icon: ZuriIcons.logout,
                iconColor: ZuriColors.danger,
                iconBackground: ZuriColors.dangerBg,
                title: 'Sign out',
                titleColor: ZuriColors.danger,
                showChevron: false,
                onTap: authController.signOut,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Zuri v1.0.0 · Built with care for the diaspora\ncommunity',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.rowSecondary.copyWith(
              color: ZuriColors.muted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  static String _joinContext(List<String> values) {
    return values.where((value) => value.trim().isNotEmpty).join(' · ');
  }
}

class _SettingsProfileCard extends StatelessWidget {
  const _SettingsProfileCard({required this.sessionSummary});

  final AuthSessionSummary sessionSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ZuriColors.primary,
        borderRadius: BorderRadius.circular(ZuriRadius.surface),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 70,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ZuriAvatar(
                  label: sessionSummary.initials,
                  color: ZuriColors.profileAvatar,
                  size: 66,
                ),
                Positioned(
                  right: 2,
                  bottom: 5,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: ZuriColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: ZuriColors.primary, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sessionSummary.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.rowTitle.copyWith(
                    color: ZuriColors.surface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sessionSummary.phoneDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.rowSecondary.copyWith(
                    color: ZuriColors.overlayOnForest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ZuriColors.forest900.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$4.88',
                  style: ZuriTextStyles.metricLabel.copyWith(
                    color: ZuriColors.surface,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'balance',
                  style: ZuriTextStyles.rowSecondary.copyWith(
                    color: ZuriColors.overlayOnForest,
                    fontSize: 13,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.label,
    required this.rows,
    this.labelColor = ZuriColors.muted,
  });

  final String label;
  final List<_SettingsRow> rows;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ZuriTextStyles.sectionLabel.copyWith(color: labelColor),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(ZuriRadius.surface),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ZuriColors.card,
              borderRadius: BorderRadius.circular(ZuriRadius.surface),
              border: Border.all(
                color: ZuriColors.rowDivider.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                for (var index = 0; index < rows.length; index += 1) ...[
                  rows[index],
                  if (index < rows.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: ZuriColors.rowDivider.withValues(alpha: 0.55),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingValue,
    this.trailingColor,
    this.titleColor,
    this.showChevron = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? trailingValue;
  final Color? trailingColor;
  final Color? titleColor;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        _SettingsIconBadge(
          icon: icon,
          color: iconColor,
          backgroundColor: iconBackground,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZuriTextStyles.rowTitle.copyWith(
                  color: titleColor ?? ZuriColors.ink,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.rowSecondary.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else ...[
          if (trailingValue != null) ...[
            const SizedBox(width: 12),
            Text(
              trailingValue!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ZuriTextStyles.rowPrimary.copyWith(
                color: trailingColor ?? ZuriColors.ink,
              ),
            ),
          ],
          if (showChevron) ...[
            const SizedBox(width: 10),
            const Icon(
              ZuriIcons.chevronRight,
              color: ZuriColors.disabled,
              size: 18,
            ),
          ],
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _SettingsIconBadge extends StatelessWidget {
  const _SettingsIconBadge({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ZuriRadius.surface),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}
