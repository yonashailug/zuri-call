import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../calling/call_service.dart';
import '../calling/in_call_screen.dart';
import '../dialpad/dialpad_screen.dart';
import '../settings/settings_screen.dart';
import '../wallet/wallet_screen.dart';
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
      ),
      ContactsScreen(
        mode: ContactsMode.contacts,
        contactsRepository: widget.contactsRepository,
        onContactCall: _selectContactForCall,
      ),
      DialpadScreen(
        initialNumber: dialNumber,
        contactName: dialContactName,
        onStartCall: _startDialpadCall,
      ),
      const WalletScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => selectedIndex = 2),
        backgroundColor: ZuriColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_ic_call_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
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
      dialNumber = contact.phone;
      dialContactName = contact.name;
      selectedIndex = 2;
    });
  }

  void _startDialpadCall(String number) {
    setState(() {
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
