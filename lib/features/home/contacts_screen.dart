import 'package:flutter/material.dart';

import '../../core/data/phone_country_lookup.dart';
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
    this.onRecentCallDelete,
    super.key,
  });

  final ContactsMode mode;
  final ValueChanged<ContactPreview> onContactCall;
  final ValueChanged<CallRecord> onRecentCallOpen;
  final ContactsRepository? contactsRepository;
  final List<CallRecord> recentCalls;
  final VoidCallback? onOpenDialpad;
  final VoidCallback? onOpenContacts;
  final ValueChanged<CallRecord>? onRecentCallDelete;

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
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
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
                      style: ZuriTextStyles.pageSubtitle.copyWith(
                        color: ZuriColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.mode == ContactsMode.recents
                          ? sessionSummary.greetingName
                          : 'Contacts',
                      style: widget.mode == ContactsMode.recents
                          ? ZuriTextStyles.greetingTitle
                          : ZuriTextStyles.pageTitle.copyWith(height: 1),
                    ),
                  ],
                ),
              ),
              _ProfileAvatar(
                label: sessionSummary.initials,
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SearchField(
            controller: searchController,
            hintText: 'Search contacts or numbers',
          ),
          const SizedBox(height: 22),
          if (widget.mode == ContactsMode.recents) ...[
            _RecentsContent(
              recentCalls: _filteredRecentCalls,
              onContactCall: widget.onContactCall,
              onRecentCallOpen: widget.onRecentCallOpen,
              onOpenDialpad: widget.onOpenDialpad,
              onOpenContacts: widget.onOpenContacts,
              onRecentCallDelete: widget.onRecentCallDelete,
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
    this.onRecentCallDelete,
  });

  final List<CallRecord> recentCalls;
  final ValueChanged<ContactPreview> onContactCall;
  final ValueChanged<CallRecord> onRecentCallOpen;
  final VoidCallback? onOpenDialpad;
  final VoidCallback? onOpenContacts;
  final ValueChanged<CallRecord>? onRecentCallDelete;

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
        if (latestMissedCall != null) ...[
          MissedCallBanner(
            missedCount: missedCalls.length,
            call: latestMissedCall,
            onCallBack: () => onContactCall(latestMissedCall.contact),
          ),
          const SizedBox(height: 24),
        ],
        if (quickDialContacts.isNotEmpty) ...[
          _QuickDialStrip(
            contacts: quickDialContacts,
            onContactCall: onContactCall,
          ),
          const SizedBox(height: 22),
        ],
        ZuriSectionHeader(
          label: 'TODAY',
          trailing: Text(
            '${recentCalls.length} ${recentCalls.length == 1 ? 'call' : 'calls'}',
            style: ZuriTextStyles.sectionCount.copyWith(color: ZuriColors.muted),
          ),
        ),
        const SizedBox(height: 8),
        for (final call in recentCalls)
          _RecentCallRow(
            call: call,
            onTap: () => onRecentCallOpen(call),
            onCallBack: () => onContactCall(call.contact),
            onDelete: onRecentCallDelete == null
                ? null
                : () => onRecentCallDelete?.call(call),
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
      height: ZuriDimensions.searchBarHeight,
      child: TextField(
        controller: controller,
        style: ZuriTextStyles.inputText.copyWith(color: ZuriColors.ink),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          prefixIcon: const Icon(
            ZuriIcons.search,
            color: ZuriColors.searchPlaceholder,
            size: 20,
          ),
          suffixIcon: Container(
            width: ZuriDimensions.searchBarHeight,
            height: ZuriDimensions.searchBarHeight,
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ZuriColors.iconButtonBg,
              borderRadius: BorderRadius.circular(ZuriRadius.field),
            ),
            child: const Icon(
              ZuriIcons.filter,
              color: ZuriColors.searchPlaceholder,
              size: 19,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ZuriRadius.field),
            borderSide: const BorderSide(color: ZuriColors.searchBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ZuriRadius.field),
            borderSide: const BorderSide(
              color: ZuriColors.forest800,
              width: 1.5,
            ),
          ),
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
          ZuriFilterChip(label: 'All', selected: true),
          SizedBox(width: 8),
          ZuriFilterChip(label: 'On Zuri'),
          SizedBox(width: 8),
          ZuriFilterChip(label: 'Favourites'),
        ],
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
            style: ZuriTextStyles.stateTitle.copyWith(
              color: ZuriColors.ink,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Your recent calls will appear\nhere. Make your first call to get\nstarted.',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.supportingText.copyWith(
              color: ZuriColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            height: ZuriDimensions.primaryButtonHeight,
            child: FilledButton.icon(
              onPressed: onOpenDialpad,
              icon: const Icon(ZuriIcons.dialpad, size: 24),
              label: const Text('Open dial pad'),
              style: FilledButton.styleFrom(
                backgroundColor: ZuriColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: ZuriTextStyles.primaryButtonLabel,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: ZuriDimensions.secondaryButtonHeight,
            child: OutlinedButton(
              onPressed: onOpenContacts,
              style: OutlinedButton.styleFrom(
                foregroundColor: ZuriColors.muted,
                side: const BorderSide(color: ZuriColors.border, width: 1.6),
                shape: const StadiumBorder(),
                textStyle: ZuriTextStyles.chipLabel,
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
            ZuriIcons.recents,
            color: ZuriColors.emptyIcon,
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
      ..color = ZuriColors.dashedStroke
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
      height: ZuriDimensions.quickDialHeight,
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
      borderRadius: BorderRadius.circular(ZuriRadius.round),
      child: Container(
        constraints: const BoxConstraints(minWidth: 88, maxWidth: 128),
        height: ZuriDimensions.quickDialHeight,
        padding: const EdgeInsets.only(left: 5, right: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(ZuriRadius.round),
          border: selected ? null : Border.all(color: ZuriColors.callSurface),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZuriAvatar(
              label: (contact.isPhoneOnly && countryLabel != null)
                  ? countryLabel!
                  : contact.initials,
              color: contact.color,
              size: 34,
              badge: flag == null
                  ? null
                  : Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: ZuriColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Text(flag!, style: const TextStyle(fontSize: 8)),
                    ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 74),
                child: Text(
                  contact.firstDisplayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.chipLabel.copyWith(
                    color: foreground,
                    height: 1.05,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MissedCallBanner extends StatelessWidget {
  const MissedCallBanner({
    required this.missedCount,
    required this.call,
    required this.onCallBack,
    super.key,
  });

  final int missedCount;
  final CallRecord call;
  final VoidCallback onCallBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: ZuriColors.dangerBg,
        borderRadius: BorderRadius.circular(ZuriRadius.field),
        border: Border.all(
          color: ZuriColors.danger.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$missedCount missed ${missedCount == 1 ? 'call' : 'calls'}',
                  style: ZuriTextStyles.recentRowTitle.copyWith(
                    color: ZuriColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${call.name} • ${call.relativeTime}',
                  overflow: TextOverflow.ellipsis,
                  style: ZuriTextStyles.meta.copyWith(
                    color: ZuriColors.danger.withValues(alpha: 0.66),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onCallBack,
            style: TextButton.styleFrom(
              backgroundColor: ZuriColors.danger.withValues(alpha: 0.10),
              foregroundColor: ZuriColors.danger,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ZuriRadius.action),
              ),
              textStyle: ZuriTextStyles.primaryButtonLabel,
            ),
            child: const Text('Call back'),
          ),
        ],
      ),
    );
  }
}


class _RecentCallRow extends StatelessWidget {
  const _RecentCallRow({
    required this.call,
    required this.onTap,
    required this.onCallBack,
    required this.onDelete,
  });

  final CallRecord call;
  final VoidCallback onTap;
  final VoidCallback onCallBack;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final missed = call.isMissed;
    final rowColor = missed ? ZuriColors.danger : ZuriColors.ink;
    final iconColor = call.directionIconColor;
    final metaColor = missed ? ZuriColors.danger : ZuriColors.subtitleText;

    final row = InkWell(
      onTap: onTap,
      child: SizedBox(
        height: ZuriDimensions.recentRowHeight,
        child: Row(
          children: [
            ZuriAvatar(
              label: (call.contact.isPhoneOnly && call.countryAvatarLabel != null)
                  ? call.countryAvatarLabel!
                  : call.contact.initials,
              color: call.contact.color,
              size: 52,
              badge: call.countryFlag == null
                  ? null
                  : Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: ZuriColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        call.countryFlag!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: ZuriDimensions.recentRowHeight,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: ZuriColors.rowDivider),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              call.contact.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ZuriTextStyles.recentRowTitle.copyWith(
                                color: rowColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  call.directionIcon,
                                  size: 16,
                                  color: iconColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    call.recentsSubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ZuriTextStyles.recentRowSubtitle
                                        .copyWith(
                                      color: metaColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 96,
                      height: ZuriDimensions.recentRowHeight - 10,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              call.relativeTime,
                              style: ZuriTextStyles.recentRowSubtitle.copyWith(
                                color: metaColor,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ZuriCircleButton(
                              icon: ZuriIcons.phone,
                              onPressed: onCallBack,
                              foregroundColor: missed
                                  ? ZuriColors.danger
                                  : ZuriColors.forest800,
                              backgroundColor: missed
                                  ? ZuriColors.danger.withValues(alpha: 0.10)
                                  : ZuriColors.iconButtonBg,
                              size: ZuriDimensions.callBackBtnSize,
                              iconSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final onDelete = this.onDelete;
    if (onDelete == null) return row;

    return Dismissible(
      key: ValueKey('recent-${call.startedAt.toIso8601String()}-${call.phone}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        height: ZuriDimensions.recentRowHeight,
        padding: const EdgeInsets.only(right: ZuriSpacing.s4),
        alignment: Alignment.centerRight,
        decoration: const BoxDecoration(
          color: ZuriColors.dangerBg,
          border: Border(
            bottom: BorderSide(color: ZuriColors.rowDivider),
          ),
        ),
        child: const Icon(
          ZuriIcons.trash,
          color: ZuriColors.danger,
          size: 20,
        ),
      ),
      child: row,
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
      return ZuriEmptyState(
        icon: ZuriIcons.contactsBook,
        title: 'Contacts access needed',
        body: 'Allow contact access to show people you can call from Zuri.',
        actionLabel: 'Allow contacts',
        onAction: onRetry,
      );
    }

    if (status == ContactsLoadStatus.unavailable) {
      return ZuriEmptyState(
        icon: ZuriIcons.error,
        title: 'Contacts unavailable',
        body: errorMessage ?? 'Could not load contacts.',
        actionLabel: 'Try again',
        onAction: onRetry,
      );
    }

    if (contacts.isEmpty) {
      if (hasLoadedContacts) {
        return const ZuriEmptyState(
          icon: ZuriIcons.noResults,
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
            trailing: ZuriCircleButton(
              icon: ZuriIcons.phone,
              onPressed: () => onContactCall(contact),
              foregroundColor: ZuriColors.forest800,
              backgroundColor: ZuriColors.iconButtonBg,
              size: ZuriDimensions.callBackBtnSize,
              iconSize: 15,
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
            style: ZuriTextStyles.stateTitle.copyWith(
              color: ZuriColors.ink,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Sync your phone contacts or add\npeople manually to start calling for\nless.',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.supportingText.copyWith(
              color: ZuriColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            height: ZuriDimensions.primaryButtonHeight,
            child: FilledButton.icon(
              onPressed: onSyncContacts,
              icon: const Icon(ZuriIcons.contactsBook, size: 22),
              label: const Text('Sync phone contacts'),
              style: FilledButton.styleFrom(
                backgroundColor: ZuriColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: ZuriTextStyles.primaryButtonLabel,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: ZuriDimensions.secondaryButtonHeight,
            child: OutlinedButton.icon(
              onPressed: onAddManually,
              icon: const Icon(ZuriIcons.userPlus, size: 22),
              label: const Text('Add manually'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ZuriColors.muted,
                disabledForegroundColor: ZuriColors.muted.withValues(
                  alpha: 0.45,
                ),
                side: const BorderSide(color: ZuriColors.border, width: 1.6),
                shape: const StadiumBorder(),
                textStyle: ZuriTextStyles.secondaryButtonLabel,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your contacts are hashed before matching -\nnever stored on our servers.',
            textAlign: TextAlign.center,
            style: ZuriTextStyles.supportingText.copyWith(
              color: ZuriColors.muted.withValues(alpha: 0.55),
              height: 1.35,
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
                ZuriIcons.userQuestion,
                color: ZuriColors.muted.withValues(alpha: 0.38),
                size: 30,
              ),
              if (showAdd)
                Positioned(
                  right: -10,
                  bottom: -1,
                  child: Icon(
                    ZuriIcons.add,
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          ZuriAvatar(
            label: contact.initials,
            color: contact.color,
            size: 44,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: ZuriTextStyles.contactRowTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: ZuriTextStyles.contactRowSubtitle.copyWith(
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
            color: ZuriColors.profileAvatar,
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


extension on ContactPreview {
  bool get isPhoneOnly => name == phone;

  String get firstDisplayName {
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    if (parts.isEmpty) return name;
    return parts.first;
  }
}

extension on CallRecord {
  bool get isMissed =>
      direction == CallDirection.missed || status == CallStatus.missed;

  IconData get directionIcon {
    if (isMissed) return ZuriIcons.arrowDownLeft;
    if (direction == CallDirection.incoming) {
      return ZuriIcons.arrowDownLeft;
    }
    return ZuriIcons.arrowUpRight;
  }

  Color get directionIconColor {
    if (isMissed) return ZuriColors.danger;
    if (direction == CallDirection.incoming) return ZuriColors.success;
    return ZuriColors.subtitleText;
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

String? _countryFlagFor(String phone) => PhoneCountryLookup.flagFor(phone);

String? _countryLabelFor(String phone) => PhoneCountryLookup.codeFor(phone);

extension on String {
  String get shortTimeAgo {
    return replaceAll(' ago', '');
  }
}

