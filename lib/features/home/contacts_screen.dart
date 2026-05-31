import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/widgets/zuri_scaffold.dart';

enum ContactsMode { recents, contacts }

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({required this.mode, super.key});

  final ContactsMode mode;

  @override
  Widget build(BuildContext context) {
    return ZuriScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning',
                      style: TextStyle(color: ZuriColors.muted, fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Alex',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 42,
                width: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: ZuriGradients.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'AJ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SearchField(),
          const SizedBox(height: 22),
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
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded),
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
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sampleContacts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final contact = sampleContacts[index];
          return SizedBox(
            width: 62,
            child: Column(
              children: [
                _Avatar(contact: contact, size: 54),
                const SizedBox(height: 6),
                Text(
                  contact.shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          _Avatar(contact: contact, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: const TextStyle(color: ZuriColors.tertiary),
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
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: contact.gradient,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Text(
        contact.initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
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
      style: const TextStyle(
        color: ZuriColors.tertiary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class ContactPreview {
  const ContactPreview({
    required this.name,
    required this.phone,
    required this.initials,
    required this.gradient,
    this.wasMissed = false,
  });

  final String name;
  final String phone;
  final String initials;
  final Gradient gradient;
  final bool wasMissed;

  String get shortName => name.split(' ').first;
}

const sampleContacts = [
  ContactPreview(
    name: 'Maya Kim',
    phone: '+1 (206) 555-0142',
    initials: 'MK',
    gradient: ZuriGradients.primary,
  ),
  ContactPreview(
    name: 'Jordan Rivera',
    phone: '+1 (503) 555-0278',
    initials: 'JR',
    gradient: LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0891B2)]),
  ),
  ContactPreview(
    name: 'Sara Lindqvist',
    phone: '+46 70 123 4567',
    initials: 'SL',
    gradient: LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)]),
  ),
  ContactPreview(
    name: 'Tom Chen',
    phone: '+1 (415) 555-0198',
    initials: 'TC',
    gradient: LinearGradient(colors: [Color(0xFFDC2626), Color(0xFF9F1239)]),
    wasMissed: true,
  ),
];
