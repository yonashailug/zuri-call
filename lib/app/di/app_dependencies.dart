import 'package:flutter/widgets.dart';

import '../../core/storage/zuri_database.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/fake_auth_repository.dart';
import '../../features/calling/call_service.dart';
import '../../features/home/call_history_repository.dart';
import '../../features/home/device_contacts_repository.dart';
import '../../features/profile/data/firestore_user_profile_repository.dart';
import '../../features/profile/data/user_profile_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.database,
    required this.authRepository,
    required this.userProfileRepository,
    required this.contactsRepository,
    required this.callHistoryRepository,
    required this.callService,
  });

  factory AppDependencies.defaults({
    ZuriDatabase? database,
    AuthRepository? authRepository,
    UserProfileRepository? userProfileRepository,
    ContactsRepository? contactsRepository,
    CallHistoryRepository? callHistoryRepository,
    CallService? callService,
  }) {
    final resolvedDatabase = database ?? ZuriDatabase.production();
    return AppDependencies(
      database: resolvedDatabase,
      authRepository: authRepository ?? FakeAuthRepository(),
      userProfileRepository:
          userProfileRepository ?? FirestoreUserProfileRepository(),
      contactsRepository: contactsRepository ??
          DeviceContactsRepository(database: resolvedDatabase),
      callHistoryRepository: callHistoryRepository ??
          LocalCallHistoryRepository(database: resolvedDatabase),
      callService: callService ?? const MockCallService(),
    );
  }

  final ZuriDatabase database;
  final AuthRepository authRepository;
  final UserProfileRepository userProfileRepository;
  final ContactsRepository contactsRepository;
  final CallHistoryRepository callHistoryRepository;
  final CallService callService;

  Future<void> dispose() {
    return database.close();
  }
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
