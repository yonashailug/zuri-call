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
        padding: const EdgeInsets.fromLTRB(
          ZuriSpacing.s5,
          12,
          ZuriSpacing.s5,
          ZuriDimensions.navOverlayBottomPadding,
        ),
        children: [
          _ProfileHeader(sessionSummary: sessionSummary),
          const SizedBox(height: 22),
          ZuriMenuRow(icon: ZuriIcons.account, label: 'Account', onTap: () {}),
          ZuriMenuRow(icon: ZuriIcons.wallet, label: 'Wallet', onTap: () {}),
          ZuriMenuRow(icon: ZuriIcons.world, label: 'Rates', onTap: () {}),
          ZuriMenuRow(icon: ZuriIcons.support, label: 'Support', onTap: () {}),
          ZuriMenuRow(
              icon: ZuriIcons.privacy, label: 'Privacy policy', onTap: () {}),
          ZuriMenuRow(
              icon: ZuriIcons.document,
              label: 'Terms of service',
              onTap: () {}),
          ZuriMenuRow(
              icon: ZuriIcons.emergency,
              label: 'Emergency calling notice',
              onTap: () {}),
          const SizedBox(height: 12),
          ZuriMenuRow(
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
                  style: ZuriTextStyles.settingsRowTitle,
                ),
                Text(
                  sessionSummary.phoneDisplay,
                  style: ZuriTextStyles.bodyText.copyWith(
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
