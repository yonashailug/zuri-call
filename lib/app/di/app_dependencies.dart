import 'package:flutter/widgets.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/fake_auth_repository.dart';
import '../../features/calling/call_service.dart';
import '../../features/home/call_history_repository.dart';
import '../../features/home/device_contacts_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.contactsRepository,
    required this.callHistoryRepository,
    required this.callService,
  });

  factory AppDependencies.defaults({
    AuthRepository? authRepository,
    ContactsRepository? contactsRepository,
    CallHistoryRepository? callHistoryRepository,
    CallService? callService,
  }) {
    return AppDependencies(
      authRepository: authRepository ?? FakeAuthRepository(),
      contactsRepository: contactsRepository ?? DeviceContactsRepository(),
      callHistoryRepository:
          callHistoryRepository ?? LocalCallHistoryRepository(),
      callService: callService ?? const MockCallService(),
    );
  }

  final AuthRepository authRepository;
  final ContactsRepository contactsRepository;
  final CallHistoryRepository callHistoryRepository;
  final CallService callService;
}

class AppDependenciesScope extends InheritedWidget {
  const AppDependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppDependenciesScope>();
    assert(scope != null, 'No AppDependenciesScope found in context.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppDependenciesScope oldWidget) {
    return dependencies != oldWidget.dependencies;
  }
}
