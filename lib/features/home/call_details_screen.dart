import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    required this.onDelete,
    super.key,
  });

  final CallRecord call;
  final VoidCallback onBack;
  final ValueChanged<ContactPreview> onCallBack;
  final ValueChanged<CallRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    final contact = call.contact;

    return ZuriScaffold(
      child: ListView(
        padding: ZuriSpacing.screen,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ZuriCircleButton(
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
              size: 46,
              foregroundColor: ZuriColors.ink,
              backgroundColor: ZuriColors.callSurface,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ZuriAvatar(
              label: contact.initials,
              color: contact.color,
              size: 84,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            call.name,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.compactTitle.copyWith(
              color: ZuriColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            call.phone,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.bodyLarge.copyWith(color: ZuriColors.muted),
          ),
          const SizedBox(height: 26),
          ZuriPillButton(
            label: 'Call back',
            icon: Icons.call_rounded,
            onPressed: () => onCallBack(contact),
          ),
          const SizedBox(height: 24),
          _DetailsPanel(call: call),
          const SizedBox(height: 18),
          _DetailsAction(
            icon: Icons.content_copy_rounded,
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
          _DetailsAction(
            icon: Icons.delete_outline_rounded,
            label: 'Delete from recents',
            destructive: true,
            onTap: () => onDelete(call),
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.call});

  final CallRecord call;

  @override
  Widget build(BuildContext context) {
    return ZuriPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _DetailsRow(label: 'Status', value: call.status.label),
          _DetailsRow(label: 'Direction', value: call.direction.label),
          _DetailsRow(label: 'Duration', value: call.durationLabel),
          _DetailsRow(label: 'Started', value: call.startedAtLabel),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: ZuriTextStyles.bodyLarge.copyWith(color: ZuriColors.muted),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: ZuriTextStyles.bodyLarge.copyWith(color: ZuriColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsAction extends StatelessWidget {
  const _DetailsAction({
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: ZuriTextStyles.rowTitle.copyWith(color: color),
      ),
      onTap: onTap,
    );
  }
}
