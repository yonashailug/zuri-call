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
        home: AnimatedBuilder(
          animation: authController,
          builder: (context, _) {
            final session = authController.state.session;
            if (session != null) return const AppShell();
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}
