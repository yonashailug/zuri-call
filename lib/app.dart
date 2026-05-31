import 'package:flutter/material.dart';

import 'core/theme/zuri_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/application/auth_scope.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/fake_auth_repository.dart';
import 'features/auth/welcome_screen.dart';
import 'features/home/app_shell.dart';

class ZuriApp extends StatefulWidget {
  const ZuriApp({
    this.authRepository,
    super.key,
  });

  final AuthRepository? authRepository;

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
        home: _AuthRoot(authController: authController),
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
      builder: (_) => _AuthRoot(authController: authController),
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
  const _AuthRoot({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        final session = authController.state.session;
        if (session != null) return const AppShell();
        return const WelcomeScreen();
      },
    );
  }
}
