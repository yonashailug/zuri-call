import 'package:flutter/material.dart';

import '../../app/di/app_dependencies.dart';
import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../calling/call_service.dart';
import '../calling/in_call_screen.dart';
import '../dialpad/dialpad_screen.dart';
import '../settings/settings_screen.dart';
import '../wallet/wallet_screen.dart';
import 'application/recent_calls_controller.dart';
import 'call_details_screen.dart';
import 'call_record.dart';
import 'contact_preview.dart';
import 'contacts_screen.dart';
import 'device_contacts_repository.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 1;
  RecentCallsController? recentCallsController;
  List<ContactPreview> suggestionContacts = const [];
  bool isLoadingSuggestionContacts = false;
  String? dialNumber;
  String? dialContactName;
  OutgoingCallRequest? activeCall;
  CallRecord? selectedCall;
  bool selectedCallIsRecent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (recentCallsController != null) return;

    final dependencies = AppDependenciesScope.of(context);
    final controller = RecentCallsController(
      repository: dependencies.callHistoryRepository,
    );
    recentCallsController = controller;
    controller.restore();
    _loadSuggestionContacts(dependencies);
  }

  @override
  void dispose() {
    recentCallsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentCallsController = this.recentCallsController;
    if (recentCallsController == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: recentCallsController,
      builder: (context, _) => _buildShell(
        context,
        recentCallsController,
        AppDependenciesScope.of(context),
      ),
    );
  }

  Widget _buildShell(
    BuildContext context,
    RecentCallsController recentCallsController,
    AppDependencies dependencies,
  ) {
    final activeCall = this.activeCall;
    if (activeCall != null) {
      return InCallScreen(
        request: activeCall,
        callService: dependencies.callService,
        onCallEnded: _recordCompletedCall,
        onCallBackAfterEnded: _recordCompletedCallAndCallBack,
      );
    }
    final screens = [
      ContactsScreen(
        mode: ContactsMode.recents,
        contactsRepository: dependencies.contactsRepository,
        recentCalls: recentCallsController.calls,
        onContactCall: _selectContactForCall,
        onContactOpen: _openContactDetails,
        onRecentCallOpen: _openCallDetails,
        onRecentCallDelete: _deleteRecentCall,
        onOpenDialpad: () => _selectTab(2),
        onOpenContacts: () => _selectTab(1),
      ),
      ContactsScreen(
        mode: ContactsMode.contacts,
        contactsRepository: dependencies.contactsRepository,
        onContactCall: _selectContactForCall,
        onContactOpen: _openContactDetails,
        onRecentCallOpen: _openCallDetails,
        onOpenDialpad: () => _selectTab(2),
      ),
      DialpadScreen(
        initialNumber: dialNumber,
        contactName: dialContactName,
        suggestionContacts: _dialpadSuggestionContacts(
          recentCallsController.calls,
        ),
        onStartCall: _startDialpadCall,
      ),
      WalletScreen(onCallDestination: _startRateDestinationCall),
      const SettingsScreen(),
    ];

    final selectedCall = this.selectedCall;
    final body = selectedCall == null
        ? IndexedStack(
            index: selectedIndex,
            children: screens,
          )
        : CallDetailsScreen(
            call: selectedCall,
            onBack: _closeCallDetails,
            onCallBack: _selectContactForCall,
            showSaveContact:
                selectedCallIsRecent && _callLooksUnsaved(selectedCall),
            onDelete: selectedCallIsRecent ? _deleteRecentCall : null,
          );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ZuriBottomNav(
              selectedIndex: selectedIndex,
              onSelected: _selectTab,
            ),
          ),
        ],
      ),
    );
  }

  void _selectContactForCall(ContactPreview contact) {
    setState(() {
      selectedCall = null;
      selectedCallIsRecent = false;
      dialNumber = null;
      dialContactName = null;
      activeCall = OutgoingCallRequest(
        phone: contact.phone,
        name: contact.name,
        startedAt: DateTime.now(),
      );
    });
  }

  void _startDialpadCall(String number) {
    final matchingPrefilledContact =
        dialNumber != null && _sameDialableNumber(dialNumber!, number);
    setState(() {
      selectedCall = null;
      selectedCallIsRecent = false;
      activeCall = OutgoingCallRequest(
        phone: number,
        name: matchingPrefilledContact ? dialContactName : null,
        startedAt: DateTime.now(),
      );
    });
  }

  void _startRateDestinationCall(RateDestination destination) {
    setState(() {
      selectedCall = null;
      selectedCallIsRecent = false;
      dialNumber = null;
      dialContactName = null;
      activeCall = OutgoingCallRequest(
        phone: destination.phone,
        name: destination.name,
        startedAt: DateTime.now(),
      );
    });
  }

  void _recordCompletedCall(CallRecord call) {
    setState(() {
      activeCall = null;
      selectedCallIsRecent = false;
      selectedIndex = 0;
    });

    recentCallsController?.record(call);
  }

  void _recordCompletedCallAndCallBack(CallRecord call) {
    setState(() {
      activeCall = null;
      selectedCall = null;
      selectedCallIsRecent = false;
      dialNumber = call.phone;
      dialContactName = call.name;
      selectedIndex = 2;
    });

    recentCallsController?.record(call);
  }

  void _openCallDetails(CallRecord call) {
    setState(() {
      selectedCall = call;
      selectedCallIsRecent = true;
      selectedIndex = 0;
    });
  }

  void _openContactDetails(ContactPreview contact) {
    setState(() {
      selectedCall = CallRecord.fromContact(contact, DateTime.now());
      selectedCallIsRecent = false;
    });
  }

  void _closeCallDetails() {
    setState(() {
      final returnIndex = selectedCallIsRecent ? 0 : selectedIndex;
      selectedCall = null;
      selectedCallIsRecent = false;
      selectedIndex = returnIndex;
    });
  }

  void _deleteRecentCall(CallRecord call) {
    setState(() {
      selectedCall = null;
      selectedCallIsRecent = false;
      selectedIndex = 0;
    });

    recentCallsController?.delete(call);
  }

  void _selectTab(int index) {
    if (index == 1 || index == 2) {
      _loadSuggestionContacts(AppDependenciesScope.of(context));
    }

    setState(() {
      selectedCall = null;
      selectedCallIsRecent = false;
      selectedIndex = index;
    });
  }

  Future<void> _loadSuggestionContacts(AppDependencies dependencies) async {
    if (isLoadingSuggestionContacts || suggestionContacts.isNotEmpty) return;

    isLoadingSuggestionContacts = true;
    final result = await dependencies.contactsRepository.loadContacts();
    if (!mounted) return;

    setState(() {
      isLoadingSuggestionContacts = false;
      suggestionContacts = result.status == ContactsLoadStatus.loaded
          ? result.contacts
          : const [];
    });
  }

  List<ContactPreview> _dialpadSuggestionContacts(List<CallRecord> calls) {
    final contacts = <ContactPreview>[];
    final seenPhones = <String>{};

    void addContact(ContactPreview contact) {
      final phoneKey = _normalizedPhone(contact.phone);
      if (phoneKey.isEmpty || !seenPhones.add(phoneKey)) return;
      contacts.add(contact);
    }

    for (final call in calls) {
      addContact(call.contact);
    }

    for (final contact in suggestionContacts) {
      addContact(contact);
    }

    return contacts;
  }

  String _normalizedPhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  bool _callLooksUnsaved(CallRecord call) {
    return _normalizedPhone(call.name) == _normalizedPhone(call.phone);
  }

  bool _sameDialableNumber(String left, String right) {
    return left.replaceAll(RegExp(r'\D'), '') ==
        right.replaceAll(RegExp(r'\D'), '');
  }
}

class _ZuriBottomNav extends StatelessWidget {
  const _ZuriBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    _ZuriBottomNavItem(ZuriIcons.recents, 'Recents'),
    _ZuriBottomNavItem(ZuriIcons.contactsBook, 'Contacts'),
    _ZuriBottomNavItem(ZuriIcons.phonePlus, 'Call'),
    _ZuriBottomNavItem(ZuriIcons.wallet, 'Wallet'),
    _ZuriBottomNavItem(ZuriIcons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final surfaceHeight = ZuriDimensions.navHeight + bottomInset;
    final totalHeight = surfaceHeight + 24;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: surfaceHeight,
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: BoxDecoration(
                color: ZuriColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ZuriColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var index = 0; index < _items.length; index += 1)
                    Expanded(
                      child: index == 2
                          ? _ZuriCallNavSlot(
                              isSelected: selectedIndex == index,
                              onTap: () => onSelected(index),
                            )
                          : _ZuriTabNavSlot(
                              item: _items[index],
                              isSelected: selectedIndex == index,
                              onTap: () => onSelected(index),
                            ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: _ZuriCallFab(
              isSelected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZuriBottomNavItem {
  const _ZuriBottomNavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ZuriTabNavSlot extends StatelessWidget {
  const _ZuriTabNavSlot({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _ZuriBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? ZuriColors.forest800 : ZuriColors.navIconInactive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const RoundedRectangleBorder(),
        child: SizedBox.expand(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 22, color: color),
                  const SizedBox(height: ZuriSpacing.s1),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: ZuriTextStyles.navItemLabel.copyWith(
                      color: color,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZuriCallNavSlot extends StatelessWidget {
  const _ZuriCallNavSlot({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const RoundedRectangleBorder(),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              'Call',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: ZuriTextStyles.navItemLabel.copyWith(
                color: ZuriColors.forest800,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZuriCallFab extends StatelessWidget {
  const _ZuriCallFab({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = isSelected ? 1.04 : 1.0;
    final shadows = isSelected
        ? [
            BoxShadow(
              color: ZuriColors.primary.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: ZuriColors.primary.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ]
        : [
            BoxShadow(
              color: ZuriColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: ZuriColors.primary.withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ];

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ZuriColors.primary,
              shape: BoxShape.circle,
              boxShadow: shadows,
            ),
            child: const Icon(
              ZuriIcons.phonePlus,
              size: 22,
              color: ZuriColors.surface,
            ),
          ),
        ),
      ),
    );
  }
}
