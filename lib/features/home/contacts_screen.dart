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
    required this.onRecentCallOpen,
    this.contactsRepository,
    this.recentCalls = const [],
    this.onOpenDialpad,
    this.onOpenContacts,
    super.key,
  });

  final ContactsMode mode;
  final ValueChanged<ContactPreview> onContactCall;
  final ValueChanged<CallRecord> onRecentCallOpen;
  final ContactsRepository? contactsRepository;
  final List<CallRecord> recentCalls;
  final VoidCallback? onOpenDialpad;
  final VoidCallback? onOpenContacts;

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
                      widget.mode == ContactsMode.recents
                          ? 'Good morning'
                          : 'Your network',
                      style: ZuriTextStyles.bodyLarge.copyWith(
                        color: ZuriColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.mode == ContactsMode.recents
                          ? sessionSummary.greetingName
                          : 'Contacts',
                      style: ZuriTextStyles.screenTitle.copyWith(
                        fontSize: 38,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              _ProfileAvatar(
                label: sessionSummary.initials,
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SearchField(
            controller: searchController,
            hintText: 'Search contacts or numbers',
          ),
          const SizedBox(height: 18),
          if (widget.mode == ContactsMode.recents) ...[
            _RecentsContent(
              recentCalls: _filteredRecentCalls,
              onContactCall: widget.onContactCall,
              onRecentCallOpen: widget.onRecentCallOpen,
              onOpenDialpad: widget.onOpenDialpad,
              onOpenContacts: widget.onOpenContacts,
            ),
          ] else ...[
            const _ContactsFilterTabs(),
            const SizedBox(height: 24),
            _ContactsContent(
              contacts: _filteredContacts,
              hasLoadedContacts: contacts.isNotEmpty,
              status: status,
              isLoading: isLoading,
              errorMessage: errorMessage,
              onRetry: _loadContacts,
              onContactCall: widget.onContactCall,
              onAddManually: widget.onOpenDialpad,
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
    required this.onRecentCallOpen,
    this.onOpenDialpad,
    this.onOpenContacts,
  });

  final List<CallRecord> recentCalls;
  final ValueChanged<ContactPreview> onContactCall;
  final ValueChanged<CallRecord> onRecentCallOpen;
  final VoidCallback? onOpenDialpad;
  final VoidCallback? onOpenContacts;

  @override
  Widget build(BuildContext context) {
    if (recentCalls.isEmpty) {
      return _EmptyRecentsState(
        onOpenDialpad: onOpenDialpad,
        onOpenContacts: onOpenContacts,
      );
    }

    final missedCalls = recentCalls.where((call) => call.isMissed).toList();
    final latestMissedCall = missedCalls.firstOrNull;
    final quickDialContacts = _quickDialContacts(recentCalls);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quickDialContacts.isNotEmpty) ...[
          _QuickDialStrip(
            contacts: quickDialContacts,
            onContactCall: onContactCall,
          ),
          const SizedBox(height: 18),
        ],
        if (latestMissedCall != null) ...[
          _MissedCallBanner(
            missedCount: missedCalls.length,
            call: latestMissedCall,
            onCallBack: () => onContactCall(latestMissedCall.contact),
          ),
          const SizedBox(height: 26),
        ],
        _RecentSectionHeader(count: recentCalls.length),
        const SizedBox(height: 10),
        for (final call in recentCalls)
          _RecentCallRow(
            call: call,
            onTap: () => onRecentCallOpen(call),
            onCallBack: () => onContactCall(call.contact),
          ),
      ],
    );
  }

  List<ContactPreview> _quickDialContacts(List<CallRecord> calls) {
    final contacts = <ContactPreview>[];
    final seenPhones = <String>{};

    for (final call in calls) {
      final normalizedPhone = call.phone.replaceAll(RegExp(r'\D'), '');
      if (normalizedPhone.isEmpty || !seenPhones.add(normalizedPhone)) {
        continue;
      }

      contacts.add(call.contact);
      if (contacts.length == 3) break;
    }

    return contacts;
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        style: ZuriTextStyles.bodyLarge.copyWith(color: ZuriColors.ink),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: ZuriColors.muted),
        ),
      ),
    );
  }
}

class _ContactsFilterTabs extends StatelessWidget {
  const _ContactsFilterTabs();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ContactFilterChip(label: 'All', selected: true),
          SizedBox(width: 8),
          _ContactFilterChip(label: 'On Zuri'),
          SizedBox(width: 8),
          _ContactFilterChip(label: 'Favourites'),
        ],
      ),
    );
  }
}

class _ContactFilterChip extends StatelessWidget {
  const _ContactFilterChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: selected ? ZuriColors.primary : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? ZuriColors.primary : const Color(0xFFD8D0C7),
            width: 1.5,
          ),
        ),
      ),
      child: Text(
        label,
        style: ZuriTextStyles.label.copyWith(
          color: selected ? Colors.white : ZuriColors.muted,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyRecentsState extends StatelessWidget {
  const _EmptyRecentsState({
    required this.onOpenDialpad,
    required this.onOpenContacts,
  });

  final VoidCallback? onOpenDialpad;
  final VoidCallback? onOpenContacts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 42, 18, 0),
      child: Column(
        children: [
          const _DashedCircleIcon(),
          const SizedBox(height: 34),
          Text(
            'No calls yet',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.compactTitle.copyWith(
              color: ZuriColors.ink,
              fontSize: 27,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Your recent calls will appear\nhere. Make your first call to get\nstarted.',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.bodyLarge.copyWith(
              color: ZuriColors.muted,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: FilledButton.icon(
              onPressed: onOpenDialpad,
              icon: const Icon(Icons.dialpad_rounded, size: 24),
              label: const Text('Open dial pad'),
              style: FilledButton.styleFrom(
                backgroundColor: ZuriColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: ZuriTextStyles.label.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: onOpenContacts,
              style: OutlinedButton.styleFrom(
                foregroundColor: ZuriColors.muted,
                side: const BorderSide(color: Color(0xFFD8D0C7), width: 1.6),
                shape: const StadiumBorder(),
                textStyle: ZuriTextStyles.label.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Import contacts'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCircleIcon extends StatelessWidget {
  const _DashedCircleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(),
      child: const SizedBox.square(
        dimension: 112,
        child: Center(
          child: Icon(
            Icons.history_rounded,
            color: Color(0xFFB7BBB0),
            size: 44,
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9C9C0)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final radius = size.width / 2 - paint.strokeWidth;
    const dashCount = 38;
    const gapRadians = 0.055;
    const dashRadians = (2 * 3.141592653589793 / dashCount) - gapRadians;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    for (var i = 0; i < dashCount; i += 1) {
      final start = i * (dashRadians + gapRadians);
      canvas.drawArc(rect, start, dashRadians, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickDialStrip extends StatelessWidget {
  const _QuickDialStrip({
    required this.contacts,
    required this.onContactCall,
  });

  final List<ContactPreview> contacts;
  final ValueChanged<ContactPreview> onContactCall;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final selected = index == 0;
          return _QuickDialPill(
            contact: contact,
            flag: _countryFlagFor(contact.phone),
            countryLabel: _countryLabelFor(contact.phone),
            selected: selected,
            onTap: () => onContactCall(contact),
          );
        },
      ),
    );
  }
}

class _QuickDialPill extends StatelessWidget {
  const _QuickDialPill({
    required this.contact,
    required this.flag,
    required this.countryLabel,
    required this.selected,
    required this.onTap,
  });

  final ContactPreview contact;
  final String? flag;
  final String? countryLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? ZuriColors.primary : ZuriColors.card;
    final foreground = selected ? Colors.white : ZuriColors.ink;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: selected ? 126 : 118,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(28),
          border: selected ? null : Border.all(color: ZuriColors.callSurface),
        ),
        child: Row(
          children: [
            _Avatar(
              contact: contact,
              size: 34,
              flag: flag,
              labelOverride: contact.isPhoneOnly ? countryLabel : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected ? contact.shortDisplayName : contact.compactLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ZuriTextStyles.rowMeta.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissedCallBanner extends StatelessWidget {
  const _MissedCallBanner({
    required this.missedCount,
    required this.call,
    required this.onCallBack,
  });

  final int missedCount;
  final CallRecord call;
  final VoidCallback onCallBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7DF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2BFB2), width: 1.4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$missedCount missed ${missedCount == 1 ? 'call' : 'calls'}',
                  style: ZuriTextStyles.bodyLarge.copyWith(
                    color: ZuriColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${call.phone} • ${call.relativeTime}',
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.rowMeta.copyWith(
                    color: const Color(0xFFD76D5D),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onCallBack,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF4CCC4),
              foregroundColor: const Color(0xFFB9382E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: ZuriTextStyles.rowMeta.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Text('Call back'),
          ),
        ],
      ),
    );
  }
}

class _RecentSectionHeader extends StatelessWidget {
  const _RecentSectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Today',
            style: ZuriTextStyles.label.copyWith(
              color: ZuriColors.muted,
              fontSize: 15,
              letterSpacing: 0,
            ),
          ),
        ),
        Text(
          '$count ${count == 1 ? 'call' : 'calls'}',
          style: ZuriTextStyles.rowMeta.copyWith(
            color: ZuriColors.muted,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _RecentCallRow extends StatelessWidget {
  const _RecentCallRow({
    required this.call,
    required this.onTap,
    required this.onCallBack,
  });

  final CallRecord call;
  final VoidCallback onTap;
  final VoidCallback onCallBack;

  @override
  Widget build(BuildContext context) {
    final missed = call.isMissed;
    final rowColor = missed ? ZuriColors.danger : ZuriColors.ink;
    final metaColor = missed ? ZuriColors.danger : ZuriColors.muted;
    final actionBackground =
        missed ? const Color(0xFFF7DCD5) : ZuriColors.callSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ZuriRadius.field),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE7DED4)),
          ),
        ),
        child: Row(
          children: [
            _Avatar(
              contact: call.contact,
              size: 60,
              flag: call.countryFlag,
              labelOverride:
                  call.contact.isPhoneOnly ? call.countryAvatarLabel : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.contact.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZuriTextStyles.rowTitle.copyWith(
                      color: rowColor,
                      fontFamily: call.contact.isPhoneOnly ? 'Georgia' : null,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        call.typeIcon,
                        size: 17,
                        color: metaColor,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          call.recentsSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ZuriTextStyles.rowMeta.copyWith(
                            color: metaColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  call.relativeTime,
                  style: ZuriTextStyles.rowMeta.copyWith(
                    color: metaColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                ZuriCircleButton(
                  icon: missed
                      ? Icons.phone_missed_rounded
                      : Icons.phone_in_talk_rounded,
                  onPressed: onCallBack,
                  foregroundColor: missed ? ZuriColors.danger : ZuriColors.ink,
                  backgroundColor: actionBackground,
                  size: 46,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactsContent extends StatelessWidget {
  const _ContactsContent({
    required this.contacts,
    required this.hasLoadedContacts,
    required this.status,
    required this.isLoading,
    required this.onRetry,
    required this.onContactCall,
    this.onAddManually,
    this.errorMessage,
  });

  final List<ContactPreview> contacts;
  final bool hasLoadedContacts;
  final ContactsLoadStatus? status;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<ContactPreview> onContactCall;
  final VoidCallback? onAddManually;

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
      if (hasLoadedContacts) {
        return const _EmptyState(
          icon: Icons.person_search_rounded,
          title: 'No contacts found',
          body: 'Try a different search.',
        );
      }

      return _EmptyContactsState(
        onSyncContacts: onRetry,
        onAddManually: onAddManually,
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

class _EmptyContactsState extends StatelessWidget {
  const _EmptyContactsState({
    required this.onSyncContacts,
    required this.onAddManually,
  });

  final VoidCallback onSyncContacts;
  final VoidCallback? onAddManually;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 0),
      child: Column(
        children: [
          const _GhostAvatarTrio(),
          const SizedBox(height: 28),
          Text(
            'Build your network',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.compactTitle.copyWith(
              color: ZuriColors.ink,
              fontSize: 27,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Sync your phone contacts or add\npeople manually to start calling for\nless.',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.bodyLarge.copyWith(
              color: ZuriColors.muted,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: FilledButton.icon(
              onPressed: onSyncContacts,
              icon: const Icon(Icons.contacts_rounded, size: 22),
              label: const Text('Sync phone contacts'),
              style: FilledButton.styleFrom(
                backgroundColor: ZuriColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: ZuriTextStyles.label.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onAddManually,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
              label: const Text('Add manually'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ZuriColors.muted,
                disabledForegroundColor: ZuriColors.muted.withValues(
                  alpha: 0.45,
                ),
                side: const BorderSide(color: Color(0xFFD8D0C7), width: 1.6),
                shape: const StadiumBorder(),
                textStyle: ZuriTextStyles.label.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your contacts are hashed before matching -\nnever stored on our servers.',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.rowMeta.copyWith(
              color: ZuriColors.muted.withValues(alpha: 0.55),
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostAvatarTrio extends StatelessWidget {
  const _GhostAvatarTrio();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 72,
      width: 172,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 18,
            child: _GhostAvatar(),
          ),
          _GhostAvatar(),
          Positioned(
            right: 18,
            child: _GhostAvatar(dashed: true, showAdd: true),
          ),
        ],
      ),
    );
  }
}

class _GhostAvatar extends StatelessWidget {
  const _GhostAvatar({
    this.dashed = false,
    this.showAdd = false,
  });

  final bool dashed;
  final bool showAdd;

  @override
  Widget build(BuildContext context) {
    final avatar = SizedBox.square(
      dimension: 66,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dashed ? Colors.transparent : ZuriColors.callSurface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: ZuriColors.muted.withValues(alpha: 0.38),
                size: 30,
              ),
              if (showAdd)
                Positioned(
                  right: -10,
                  bottom: -1,
                  child: Icon(
                    Icons.add_rounded,
                    color: ZuriColors.muted.withValues(alpha: 0.46),
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!dashed) return avatar;

    return CustomPaint(
      painter: _DashedCirclePainter(),
      child: avatar,
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Stack(
        children: [
          ZuriAvatar(
            label: label,
            color: ZuriColors.primary,
            size: 42,
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: ZuriColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: ZuriColors.surface, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.contact,
    required this.size,
    this.flag,
    this.labelOverride,
  });

  final ContactPreview contact;
  final double size;
  final String? flag;
  final String? labelOverride;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ZuriAvatar(
            label: labelOverride ?? contact.initials,
            color: contact.color,
            size: size,
          ),
          if (flag != null)
            Positioned(
              right: -2,
              bottom: 3,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: ZuriColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  flag!,
                  style: TextStyle(fontSize: size * 0.24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension on ContactPreview {
  bool get isPhoneOnly => name == phone;

  String get shortDisplayName {
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    if (parts.length <= 1) return name;
    return '${parts.first} ${parts.skip(1).first[0]}.';
  }

  String get compactLabel {
    if (!isPhoneOnly) return shortDisplayName;
    return phone.length <= 8 ? phone : '${phone.substring(0, 5)}...';
  }
}

extension on CallRecord {
  bool get isMissed =>
      direction == CallDirection.missed || status == CallStatus.missed;

  IconData get typeIcon {
    if (isMissed) return Icons.phone_missed_rounded;
    if (direction == CallDirection.incoming) {
      return Icons.south_west_rounded;
    }
    return Icons.north_east_rounded;
  }

  String get recentsSubtitle {
    if (isMissed) return 'Missed • ${relativeTime.shortTimeAgo}';
    final parts = [
      direction.label,
      if (status != CallStatus.completed) status.label,
      if (durationSeconds > 0) durationLabel,
    ];
    return parts.join(' • ');
  }

  String? get countryFlag {
    return _countryFlagFor(phone);
  }

  String? get countryAvatarLabel {
    return _countryLabelFor(phone);
  }
}

String? _countryFlagFor(String phone) {
  final normalized = phone.replaceAll(RegExp(r'\s'), '');
  if (normalized.startsWith('+251')) return '🇪🇹';
  if (normalized.startsWith('+1')) return '🇺🇸';
  if (normalized.startsWith('+44')) return '🇬🇧';
  if (normalized.startsWith('+254')) return '🇰🇪';
  if (normalized.startsWith('+234')) return '🇳🇬';
  return null;
}

String? _countryLabelFor(String phone) {
  final normalized = phone.replaceAll(RegExp(r'\s'), '');
  if (normalized.startsWith('+251')) return 'ET';
  if (normalized.startsWith('+1')) return 'US';
  if (normalized.startsWith('+44')) return 'GB';
  if (normalized.startsWith('+254')) return 'KE';
  if (normalized.startsWith('+234')) return 'NG';
  return null;
}

extension on String {
  String get shortTimeAgo {
    return replaceAll(' ago', '');
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
