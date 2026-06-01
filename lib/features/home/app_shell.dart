import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
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
      ),
      DialpadScreen(
        initialNumber: dialNumber,
        contactName: dialContactName,
        onStartCall: _startDialpadCall,
      ),
      const WalletScreen(),
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
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_ic_call_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _selectTab,
        backgroundColor: ZuriColors.surface,
        indicatorColor: ZuriColors.callSurface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Recents',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: SizedBox.shrink(),
            label: 'Call',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _selectContactForCall(ContactPreview contact) {
    setState(() {
      selectedCall = null;
      dialNumber = contact.phone;
      dialContactName = contact.name;
      selectedIndex = 2;
    });
  }

  void _startDialpadCall(String number) {
    setState(() {
      selectedCall = null;
      activeCall = OutgoingCallRequest(
        phone: number,
        name: dialContactName,
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
}
