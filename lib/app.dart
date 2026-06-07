import 'package:flutter/material.dart';

import 'app/di/app_dependencies.dart';
import 'core/theme/zuri_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/application/auth_scope.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/welcome_screen.dart';
import 'features/home/app_shell.dart';

class ZuriApp extends StatefulWidget {
  const ZuriApp({
    this.dependencies,
    this.authRepository,
    super.key,
  });

  final AppDependencies? dependencies;
  final AuthRepository? authRepository;

  @override
  State<ZuriApp> createState() => _ZuriAppState();
}

class _ZuriAppState extends State<ZuriApp> {
  late final AppDependencies dependencies;
  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    dependencies = widget.dependencies ??
        AppDependencies.defaults(authRepository: widget.authRepository);
    authController = AuthController(
      repository: dependencies.authRepository,
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
    return AppDependenciesScope(
      dependencies: dependencies,
      child: AuthScope(
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
  const _AuthRoot({
    required this.authController,
  });

  final AuthController authController;

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
          return const AppShell();
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
