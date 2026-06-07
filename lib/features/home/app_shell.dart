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

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 1;
  RecentCallsController? recentCallsController;
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
        suggestionContacts:
            recentCallsController.calls.map((call) => call.contact).toList(),
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
            onDelete: selectedCallIsRecent ? _deleteRecentCall : null,
          );

    return Scaffold(
      body: body,
      floatingActionButton: selectedIndex == 2
          ? null
          : FloatingActionButton(
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
    setState(() {
      selectedCall = null;
      selectedCallIsRecent = false;
      selectedIndex = index;
    });
  }

  bool _sameDialableNumber(String left, String right) {
    return left.replaceAll(RegExp(r'\D'), '') ==
        right.replaceAll(RegExp(r'\D'), '');
  }
}
