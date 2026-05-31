import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../../core/widgets/zuri_scaffold.dart';

enum ContactsMode { recents, contacts }

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({required this.mode, super.key});

  final ContactsMode mode;

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      child: ListView(
        padding: ZuriSpacing.screen,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning',
                      style: ZuriTextStyles.bodyLarge.copyWith(
                        color: ZuriColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Alex',
                      style: ZuriTextStyles.screenTitle.copyWith(
                        fontSize: 38,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const ZuriAvatar(
                label: 'AJ',
                color: ZuriColors.primary,
                size: 42,
              ),
            ],
          ),
          const SizedBox(height: 26),
          const _SearchField(),
          const SizedBox(height: 28),
          if (mode == ContactsMode.recents) ...[
            const _SectionTitle('Recent calls'),
            const SizedBox(height: 10),
            ...sampleContacts.map(
              (contact) => _ContactRow(
                contact: contact,
                trailing: contact.wasMissed
                    ? const Icon(Icons.call_missed_rounded, color: Colors.red)
                    : const Icon(Icons.call_made_rounded),
              ),
            ),
          ] else ...[
            const _SectionTitle('Recent'),
            const SizedBox(height: 10),
            const _RecentStrip(),
            const SizedBox(height: 22),
            const _SectionTitle('All contacts'),
            const SizedBox(height: 4),
            ...sampleContacts.map(
              (contact) => _ContactRow(
                contact: contact,
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.call_rounded),
                  color: ZuriColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search contacts',
        prefixIcon: const Icon(Icons.search_rounded, color: ZuriColors.muted),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded),
          color: ZuriColors.ink,
        ),
      ),
    );
  }
}

class _RecentStrip extends StatelessWidget {
  const _RecentStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sampleContacts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final contact = sampleContacts[index];
          return SizedBox(
            width: 70,
            child: Column(
              children: [
                _Avatar(contact: contact, size: 60),
                const SizedBox(height: 6),
                Text(
                  contact.shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.rowMeta.copyWith(
                    color: ZuriColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact, required this.trailing});

  final ContactPreview contact;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _Avatar(contact: contact, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: ZuriTextStyles.rowTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: ZuriTextStyles.rowMeta.copyWith(
                    color: ZuriColors.muted,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.contact, required this.size});

  final ContactPreview contact;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ZuriAvatar(
      label: contact.initials,
      color: contact.color,
      size: size,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: ZuriTextStyles.eyebrow.copyWith(
        color: ZuriColors.muted,
      ),
    );
  }
}

class ContactPreview {
  const ContactPreview({
    required this.name,
    required this.phone,
    required this.initials,
    required this.color,
    this.wasMissed = false,
  });

  final String name;
  final String phone;
  final String initials;
  final Color color;
  final bool wasMissed;

  String get shortName => name.split(' ').first;
}

const sampleContacts = [
  ContactPreview(
    name: 'Maya Kim',
    phone: '+1 (206) 555-0142',
    initials: 'MK',
    color: ZuriColors.primary,
  ),
  ContactPreview(
    name: 'Jordan Rivera',
    phone: '+1 (503) 555-0278',
    initials: 'JR',
    color: Color(0xFF0E9F6E),
  ),
  ContactPreview(
    name: 'Sara Lindqvist',
    phone: '+46 70 123 4567',
    initials: 'SL',
    color: Color(0xFFD97706),
  ),
  ContactPreview(
    name: 'Tom Chen',
    phone: '+1 (415) 555-0198',
    initials: 'TC',
    color: ZuriColors.danger,
    wasMissed: true,
  ),
];
