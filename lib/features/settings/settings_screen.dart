import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../../core/widgets/zuri_scaffold.dart';
import '../auth/application/auth_scope.dart';
import '../auth/application/auth_session_summary.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final sessionSummary = AuthSessionSummary.fromSession(
      authController.state.session,
    );

    return ZuriScaffold(
      title: 'Settings',
      child: ListView(
        padding: ZuriSpacing.screenCompact,
        children: [
          _ProfileHeader(sessionSummary: sessionSummary),
          const SizedBox(height: 22),
          const _SettingsRow(
              icon: Icons.account_circle_rounded, label: 'Account'),
          const _SettingsRow(
              icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
          const _SettingsRow(icon: Icons.price_check_rounded, label: 'Rates'),
          const _SettingsRow(
              icon: Icons.support_agent_rounded, label: 'Support'),
          const _SettingsRow(
              icon: Icons.privacy_tip_rounded, label: 'Privacy policy'),
          const _SettingsRow(
              icon: Icons.description_rounded, label: 'Terms of service'),
          const _SettingsRow(
              icon: Icons.emergency_rounded, label: 'Emergency calling notice'),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            destructive: true,
            onTap: authController.signOut,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.sessionSummary});

  final AuthSessionSummary sessionSummary;

  @override
  Widget build(BuildContext context) {
    return ZuriPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ZuriAvatar(
            label: sessionSummary.initials,
            color: ZuriColors.primary,
            size: 52,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessionSummary.displayName,
                  style: ZuriTextStyles.rowTitle,
                ),
                Text(
                  sessionSummary.phoneDisplay,
                  style: ZuriTextStyles.bodyLarge.copyWith(
                    color: ZuriColors.muted,
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? ZuriColors.danger : ZuriColors.ink;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: ZuriTextStyles.rowTitle.copyWith(color: color),
      ),
      trailing: destructive
          ? null
          : const Icon(Icons.chevron_right_rounded, color: ZuriColors.muted),
      onTap: onTap ?? () {},
    );
  }
}
