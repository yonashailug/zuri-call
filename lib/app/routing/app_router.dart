import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/code_verification_screen.dart';
import '../../features/auth/phone_entry_screen.dart';
import '../../features/auth/profile_name_screen.dart';
import '../../features/auth/welcome_screen.dart';
import 'app_routes.dart';

typedef AppRouteBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);

GoRouter createAppRouter({
  required AppRouteBuilder rootBuilder,
}) {
  return GoRouter(
    initialLocation: AppRoutes.root,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        name: AppRouteNames.root,
        builder: rootBuilder,
      ),
      GoRoute(
        path: AppRoutes.authWelcome,
        name: AppRouteNames.authWelcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.authPhone,
        name: AppRouteNames.authPhone,
        builder: (context, state) => const PhoneEntryScreen(),
      ),
      GoRoute(
        path: AppRoutes.authVerify,
        name: AppRouteNames.authVerify,
        builder: (context, state) => const CodeVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.authProfile,
        name: AppRouteNames.authProfile,
        builder: (context, state) => const ProfileNameScreen(),
      ),
      GoRoute(
        path: AppRoutes.tabsRecents,
        name: AppRouteNames.tabsRecents,
        builder: rootBuilder,
      ),
      GoRoute(
        path: AppRoutes.tabsContacts,
        name: AppRouteNames.tabsContacts,
        builder: rootBuilder,
      ),
      GoRoute(
        path: AppRoutes.tabsDialpad,
        name: AppRouteNames.tabsDialpad,
        builder: rootBuilder,
      ),
      GoRoute(
        path: AppRoutes.tabsWallet,
        name: AppRouteNames.tabsWallet,
        builder: rootBuilder,
      ),
      GoRoute(
        path: AppRoutes.tabsSettings,
        name: AppRouteNames.tabsSettings,
        builder: rootBuilder,
      ),
    ],
    redirect: (context, state) {
      if (_isFirebaseAuthCallback(state.uri)) {
        return AppRoutes.root;
      }

      return null;
    },
    errorBuilder: rootBuilder,
  );
}

bool _isFirebaseAuthCallback(Uri uri) {
  return uri.path == '/link' &&
      (uri.queryParameters['deep_link_id'] ?? '').contains(
        '/__/auth/callback',
      );
}
