import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../calling/call_service.dart';
import '../calling/in_call_screen.dart';
import '../dialpad/dialpad_screen.dart';
import '../settings/settings_screen.dart';
import '../wallet/wallet_screen.dart';
import 'call_details_screen.dart';
import 'call_history_repository.dart';
import 'call_record.dart';
import 'contact_preview.dart';
import 'contacts_screen.dart';
import 'device_contacts_repository.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    this.contactsRepository,
    this.callHistoryRepository,
    this.callService = const MockCallService(),
    super.key,
  });

  final ContactsRepository? contactsRepository;
  final CallHistoryRepository? callHistoryRepository;
  final CallService callService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 1;
  late final CallHistoryRepository callHistoryRepository =
      widget.callHistoryRepository ?? LocalCallHistoryRepository();
  String? dialNumber;
  String? dialContactName;
  OutgoingCallRequest? activeCall;
  CallRecord? selectedCall;
  final recentCalls = <CallRecord>[];

  @override
  void initState() {
    super.initState();
    _restoreRecentCalls();
  }

  @override
  Widget build(BuildContext context) {
    final activeCall = this.activeCall;
    if (activeCall != null) {
      return InCallScreen(
        request: activeCall,
        callService: widget.callService,
        onCallEnded: _recordCompletedCall,
        onCallBackAfterEnded: _recordCompletedCallAndCallBack,
        onSaveContactAfterEnded: _recordCompletedCallAndOpenContacts,
      );
    }
    final screens = [
      ContactsScreen(
        mode: ContactsMode.recents,
        contactsRepository: widget.contactsRepository,
        recentCalls: recentCalls,
        onContactCall: _selectContactForCall,
        onRecentCallOpen: _openCallDetails,
        onOpenDialpad: () => _selectTab(2),
        onOpenContacts: () => _selectTab(1),
      ),
      ContactsScreen(
        mode: ContactsMode.contacts,
        contactsRepository: widget.contactsRepository,
        onContactCall: _selectContactForCall,
        onRecentCallOpen: _openCallDetails,
        onOpenDialpad: () => _selectTab(2),
      ),
      DialpadScreen(
        initialNumber: dialNumber,
        contactName: dialContactName,
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
            onDelete: _deleteRecentCall,
          );

    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectTab(2),
        backgroundColor: ZuriColors.primary,
        foregroundColor: ZuriColors.surface,
        shape: const CircleBorder(),
        child: const Icon(ZuriIcons.phonePlus, size: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: ZuriColors.navBorderTop),
          ),
        ),
        child: NavigationBar(
          height: 56,
          selectedIndex: selectedIndex,
          onDestinationSelected: _selectTab,
          backgroundColor: ZuriColors.surface,
          indicatorColor: Colors.transparent,
          destinations: const [
            NavigationDestination(
              icon: Icon(ZuriIcons.recents),
              selectedIcon: Icon(ZuriIcons.recents),
              label: 'Recents',
            ),
            NavigationDestination(
              icon: Icon(ZuriIcons.contacts),
              selectedIcon: Icon(ZuriIcons.contacts),
              label: 'Contacts',
            ),
            NavigationDestination(
              icon: SizedBox.shrink(),
              label: 'Call',
            ),
            NavigationDestination(
              icon: Icon(ZuriIcons.wallet),
              selectedIcon: Icon(ZuriIcons.wallet),
              label: 'Wallet',
            ),
            NavigationDestination(
              icon: Icon(ZuriIcons.settings),
              selectedIcon: Icon(ZuriIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _selectContactForCall(ContactPreview contact) {
    setState(() {
      selectedCall = null;
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
      selectedIndex = 0;
      recentCalls.insert(0, call);
    });

    _saveRecentCalls();
  }

  void _recordCompletedCallAndCallBack(CallRecord call) {
    setState(() {
      activeCall = null;
      selectedCall = null;
      dialNumber = call.phone;
      dialContactName = call.name;
      selectedIndex = 2;
      recentCalls.insert(0, call);
    });

    _saveRecentCalls();
  }

  void _recordCompletedCallAndOpenContacts(CallRecord call) {
    setState(() {
      activeCall = null;
      selectedCall = null;
      selectedIndex = 1;
      recentCalls.insert(0, call);
    });

    _saveRecentCalls();
  }

  void _openCallDetails(CallRecord call) {
    setState(() {
      selectedCall = call;
      selectedIndex = 0;
    });
  }

  void _closeCallDetails() {
    setState(() {
      selectedCall = null;
      selectedIndex = 0;
    });
  }

  void _deleteRecentCall(CallRecord call) {
    setState(() {
      selectedCall = null;
      recentCalls.remove(call);
      selectedIndex = 0;
    });

    _saveRecentCalls();
  }

  void _selectTab(int index) {
    setState(() {
      selectedCall = null;
      selectedIndex = index;
    });
  }

  Future<void> _restoreRecentCalls() async {
    final restoredCalls = await callHistoryRepository.loadRecentCalls();
    if (!mounted) return;

    setState(() {
      recentCalls
        ..clear()
        ..addAll(restoredCalls);
    });
  }

  Future<void> _saveRecentCalls() {
    return callHistoryRepository.saveRecentCalls(recentCalls);
  }

  bool _sameDialableNumber(String left, String right) {
    return left.replaceAll(RegExp(r'\D'), '') ==
        right.replaceAll(RegExp(r'\D'), '');
  }
}
