import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/di/app_dependencies.dart';
import 'app/routing/app_router.dart';
import 'app/routing/app_routes.dart';
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
    this.disposeDependencies = true,
    super.key,
  });

  final AppDependencies? dependencies;
  final AuthRepository? authRepository;
  final bool disposeDependencies;

  @override
  State<ZuriApp> createState() => _ZuriAppState();
}

class _ZuriAppState extends State<ZuriApp> {
  late final AppDependencies dependencies;
  late final AuthController authController;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    dependencies = widget.dependencies ??
        AppDependencies.defaults(authRepository: widget.authRepository);
    authController = AuthController(
      repository: dependencies.authRepository,
    );
    router = createAppRouter(
      rootBuilder: (_, state) => _AuthRoot(
        authController: authController,
        initialTabIndex: _tabIndexForLocation(state.uri.path),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.restoreSession();
    });
  }

  @override
  void dispose() {
    router.dispose();
    authController.dispose();
    if (widget.disposeDependencies) {
      unawaited(dependencies.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDependenciesScope(
      dependencies: dependencies,
      child: AuthScope(
        controller: authController,
        child: MaterialApp.router(
          title: 'Zuri',
          debugShowCheckedModeBanner: false,
          theme: ZuriTheme.light(),
          routerConfig: router,
        ),
      ),
    );
  }
}

class _AuthRoot extends StatelessWidget {
  const _AuthRoot({
    required this.authController,
    required this.initialTabIndex,
  });

  final AuthController authController;
  final int initialTabIndex;

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
          return AppShell(initialTabIndex: initialTabIndex);
        }
        return const WelcomeScreen();
      },
    );
  }
}

int _tabIndexForLocation(String location) {
  return switch (location) {
    AppRoutes.tabsRecents => 0,
    AppRoutes.tabsContacts => 1,
    AppRoutes.tabsDialpad => 2,
    AppRoutes.tabsWallet => 3,
    AppRoutes.tabsSettings => 4,
    _ => 1,
  };
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
