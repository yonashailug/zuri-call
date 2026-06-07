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
    this.onDelete,
    super.key,
  });

  final CallRecord call;
  final VoidCallback onBack;
  final ValueChanged<ContactPreview> onCallBack;
  final ValueChanged<CallRecord>? onDelete;

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
              icon: ZuriIcons.back,
              onPressed: onBack,
              size: 36,
              foregroundColor: ZuriColors.ink,
              backgroundColor: ZuriColors.neutralBg,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ZuriAvatar(
              label: contact.initials,
              size: 84,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            call.name,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.compactPageTitle.copyWith(
              color: ZuriColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            call.phone,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.bodyText.copyWith(color: ZuriColors.muted),
          ),
          const SizedBox(height: 26),
          ZuriPillButton(
            label: 'Call back',
            icon: ZuriIcons.phone,
            onPressed: () => onCallBack(contact),
          ),
          const SizedBox(height: 24),
          ZuriPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ZuriInfoRow(label: 'Status', value: call.status.label),
                ZuriInfoRow(label: 'Direction', value: call.direction.label),
                ZuriInfoRow(label: 'Duration', value: call.durationLabel),
                ZuriInfoRow(label: 'Started', value: call.startedAtLabel),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ZuriMenuRow(
            icon: ZuriIcons.copy,
            label: 'Copy number',
            showChevron: false,
            contentPadding: EdgeInsets.zero,
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
            ZuriMenuRow(
              icon: ZuriIcons.trash,
              label: 'Delete from recents',
              destructive: true,
              contentPadding: EdgeInsets.zero,
              onTap: () => onDelete!(call),
            ),
        ],
      ),
    );
  }
}
