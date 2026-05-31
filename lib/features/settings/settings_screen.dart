import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/widgets/zuri_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: const [
          _ProfileHeader(),
          SizedBox(height: 18),
          _SettingsRow(icon: Icons.account_circle_rounded, label: 'Account'),
          _SettingsRow(
              icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
          _SettingsRow(icon: Icons.price_check_rounded, label: 'Rates'),
          _SettingsRow(icon: Icons.support_agent_rounded, label: 'Support'),
          _SettingsRow(
              icon: Icons.privacy_tip_rounded, label: 'Privacy policy'),
          _SettingsRow(
              icon: Icons.description_rounded, label: 'Terms of service'),
          _SettingsRow(
              icon: Icons.emergency_rounded, label: 'Emergency calling notice'),
          SizedBox(height: 12),
          _SettingsRow(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ZuriColors.border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: ZuriColors.primary,
            child: Text(
              'AJ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alex Johnson',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  '+1 (206) 555-0100',
                  style: TextStyle(color: ZuriColors.muted),
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
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? ZuriColors.danger : ZuriColors.ink;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
      trailing: destructive
          ? null
          : const Icon(Icons.chevron_right_rounded, color: ZuriColors.tertiary),
      onTap: () {},
    );
  }
}
