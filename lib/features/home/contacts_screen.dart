import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../../core/widgets/zuri_scaffold.dart';
import '../auth/application/auth_scope.dart';
import '../auth/application/auth_session_summary.dart';
import 'call_record.dart';
import 'contact_preview.dart';
import 'device_contacts_repository.dart';

enum ContactsMode { recents, contacts }

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({
    required this.mode,
    required this.onContactCall,
    this.contactsRepository,
    this.recentCalls = const [],
    super.key,
  });

  final ContactsMode mode;
  final ValueChanged<ContactPreview> onContactCall;
  final ContactsRepository? contactsRepository;
  final List<CallRecord> recentCalls;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late final ContactsRepository contactsRepository =
      widget.contactsRepository ?? DeviceContactsRepository();
  final searchController = TextEditingController();

  ContactsLoadStatus? status;
  List<ContactPreview> contacts = const [];
  String? errorMessage;
  bool isLoading = false;
  String query = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_handleSearchChanged);
    if (widget.mode == ContactsMode.contacts) {
      _loadContacts();
    }
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final sessionSummary = AuthSessionSummary.fromSession(
      authController.state.session,
    );

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
                      sessionSummary.greetingName,
                      style: ZuriTextStyles.screenTitle.copyWith(
                        fontSize: 38,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              ZuriAvatar(
                label: sessionSummary.initials,
                color: ZuriColors.primary,
                size: 42,
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SearchField(controller: searchController),
          const SizedBox(height: 28),
          if (widget.mode == ContactsMode.recents) ...[
            const _SectionTitle('Recent calls'),
            const SizedBox(height: 10),
            _RecentsContent(
              recentCalls: _filteredRecentCalls,
              onContactCall: widget.onContactCall,
            ),
          ] else ...[
            const _SectionTitle('All contacts'),
            const SizedBox(height: 10),
            _ContactsContent(
              contacts: _filteredContacts,
              status: status,
              isLoading: isLoading,
              errorMessage: errorMessage,
              onRetry: _loadContacts,
              onContactCall: widget.onContactCall,
            ),
          ],
        ],
      ),
    );
  }

  List<ContactPreview> get _filteredContacts {
    return contacts.where((contact) => contact.matches(query)).toList();
  }

  List<CallRecord> get _filteredRecentCalls {
    return widget.recentCalls
        .where((call) => call.contact.matches(query))
        .toList();
  }

  Future<void> _loadContacts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await contactsRepository.loadContacts();
    if (!mounted) return;

    setState(() {
      isLoading = false;
      status = result.status;
      contacts = result.contacts;
      errorMessage = result.message;
    });
  }

  void _handleSearchChanged() {
    setState(() {
      query = searchController.text;
    });
  }
}

class _RecentsContent extends StatelessWidget {
  const _RecentsContent({
    required this.recentCalls,
    required this.onContactCall,
  });

  final List<CallRecord> recentCalls;
  final ValueChanged<ContactPreview> onContactCall;

  @override
  Widget build(BuildContext context) {
    if (recentCalls.isEmpty) {
      return const _EmptyState(
        icon: Icons.history_rounded,
        title: 'No recent calls yet',
        body: 'Calls you make from Zuri will appear here.',
      );
    }

    return Column(
      children: [
        for (final call in recentCalls)
          _ContactRow(
            contact: call.contact,
            subtitle: '${call.relativeTime} • ${call.metadata}',
            trailing: IconButton(
              onPressed: () => onContactCall(call.contact),
              icon: const Icon(Icons.call_made_rounded),
              color: ZuriColors.primary,
            ),
          ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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

class _ContactsContent extends StatelessWidget {
  const _ContactsContent({
    required this.contacts,
    required this.status,
    required this.isLoading,
    required this.onRetry,
    required this.onContactCall,
    this.errorMessage,
  });

  final List<ContactPreview> contacts;
  final ContactsLoadStatus? status;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<ContactPreview> onContactCall;

  @override
  Widget build(BuildContext context) {
    if (isLoading || status == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (status == ContactsLoadStatus.denied) {
      return _EmptyState(
        icon: Icons.contacts_rounded,
        title: 'Contacts access needed',
        body: 'Allow contact access to show people you can call from Zuri.',
        actionLabel: 'Allow contacts',
        onAction: onRetry,
      );
    }

    if (status == ContactsLoadStatus.unavailable) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Contacts unavailable',
        body: errorMessage ?? 'Could not load contacts.',
        actionLabel: 'Try again',
        onAction: onRetry,
      );
    }

    if (contacts.isEmpty) {
      return const _EmptyState(
        icon: Icons.person_search_rounded,
        title: 'No contacts found',
        body: 'Try a different search or add contacts on your phone.',
      );
    }

    return Column(
      children: [
        for (final contact in contacts)
          _ContactRow(
            contact: contact,
            trailing: IconButton(
              onPressed: () => onContactCall(contact),
              icon: const Icon(Icons.call_rounded),
              color: ZuriColors.primary,
            ),
          ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  _ContactRow({
    required this.contact,
    required this.trailing,
    String? subtitle,
  }) : subtitle = subtitle ?? contact.phone;

  final ContactPreview contact;
  final Widget trailing;
  final String subtitle;

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
                  subtitle,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ZuriPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(icon, color: ZuriColors.primary, size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.rowTitle,
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: ZuriTextStyles.rowMeta.copyWith(color: ZuriColors.muted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  backgroundColor: ZuriColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  textStyle: ZuriTextStyles.label,
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
