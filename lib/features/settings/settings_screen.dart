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
          const _SettingsRow(icon: ZuriIcons.account, label: 'Account'),
          const _SettingsRow(icon: ZuriIcons.wallet, label: 'Wallet'),
          const _SettingsRow(icon: ZuriIcons.world, label: 'Rates'),
          const _SettingsRow(icon: ZuriIcons.support, label: 'Support'),
          const _SettingsRow(icon: ZuriIcons.privacy, label: 'Privacy policy'),
          const _SettingsRow(
              icon: ZuriIcons.document, label: 'Terms of service'),
          const _SettingsRow(
              icon: ZuriIcons.emergency, label: 'Emergency calling notice'),
          const SizedBox(height: 12),
          _SettingsRow(
            icon: ZuriIcons.logout,
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
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessionSummary.displayName,
                  style: ZuriTextStyles.contactName,
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
        style: ZuriTextStyles.contactName.copyWith(color: color),
      ),
      trailing: destructive
          ? null
          : const Icon(ZuriIcons.chevronRight, color: ZuriColors.muted),
      onTap: onTap ?? () {},
    );
  }
}
