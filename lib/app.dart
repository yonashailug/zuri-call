import 'package:flutter/material.dart';

import 'core/theme/zuri_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/application/auth_scope.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/fake_auth_repository.dart';
import 'features/auth/welcome_screen.dart';
import 'features/calling/call_service.dart';
import 'features/home/call_history_repository.dart';
import 'features/home/app_shell.dart';
import 'features/home/device_contacts_repository.dart';

class ZuriApp extends StatefulWidget {
  const ZuriApp({
    this.authRepository,
    this.contactsRepository,
    this.callHistoryRepository,
    this.callService = const MockCallService(),
    super.key,
  });

  final AuthRepository? authRepository;
  final ContactsRepository? contactsRepository;
  final CallHistoryRepository? callHistoryRepository;
  final CallService callService;

  @override
  State<ZuriApp> createState() => _ZuriAppState();
}

class _ZuriAppState extends State<ZuriApp> {
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = AuthController(
      repository: widget.authRepository ?? FakeAuthRepository(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.restoreSession();
    });
  }

  @override
  void dispose() {
    authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: authController,
      child: MaterialApp(
        title: 'Zuri',
        debugShowCheckedModeBanner: false,
        theme: ZuriTheme.light(),
        home: _AuthRoot(
          authController: authController,
          contactsRepository: widget.contactsRepository,
          callHistoryRepository: widget.callHistoryRepository,
          callService: widget.callService,
        ),
        onGenerateRoute: (settings) {
          if (_isFirebaseAuthCallback(settings.name)) {
            return _rootRoute(settings);
          }

          return null;
        },
        onUnknownRoute: _rootRoute,
      ),
    );
  }

  MaterialPageRoute<void> _rootRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _AuthRoot(
        authController: authController,
        contactsRepository: widget.contactsRepository,
        callHistoryRepository: widget.callHistoryRepository,
        callService: widget.callService,
      ),
    );
  }
}

bool _isFirebaseAuthCallback(String? routeName) {
  if (routeName == null) return false;

  final uri = Uri.tryParse(routeName);
  return uri?.path == '/link' &&
      (uri?.queryParameters['deep_link_id'] ?? '').contains(
        '/__/auth/callback',
      );
}

class _AuthRoot extends StatelessWidget {
  const _AuthRoot({
    required this.authController,
    required this.contactsRepository,
    required this.callHistoryRepository,
    required this.callService,
  });

  final AuthController authController;
  final ContactsRepository? contactsRepository;
  final CallHistoryRepository? callHistoryRepository;
  final CallService callService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        if (authController.state.step == AuthStep.restoring) {
          return const _RestoreSessionScreen();
        }
        final session = authController.state.session;
        if (session != null) {
          return AppShell(
            contactsRepository: contactsRepository,
            callHistoryRepository: callHistoryRepository,
            callService: callService,
          );
        }
        return const WelcomeScreen();
      },
    );
  }
}

class _RestoreSessionScreen extends StatelessWidget {
  const _RestoreSessionScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ColoredBox(
        color: ZuriColors.surface,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
