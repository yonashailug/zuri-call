import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

GoRouter createAppRouter({
  required WidgetBuilder rootBuilder,
}) {
  return GoRouter(
    initialLocation: AppRoutes.root,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        name: AppRouteNames.root,
        builder: (context, state) => rootBuilder(context),
      ),
      GoRoute(
        path: AppRoutes.authWelcome,
        name: AppRouteNames.authWelcome,
        builder: (context, state) => rootBuilder(context),
      ),
      GoRoute(
        path: AppRoutes.tabsRecents,
        name: AppRouteNames.tabsRecents,
        builder: (context, state) => rootBuilder(context),
      ),
      GoRoute(
        path: AppRoutes.tabsContacts,
        name: AppRouteNames.tabsContacts,
        builder: (context, state) => rootBuilder(context),
      ),
      GoRoute(
        path: AppRoutes.tabsDialpad,
        name: AppRouteNames.tabsDialpad,
        builder: (context, state) => rootBuilder(context),
      ),
      GoRoute(
        path: AppRoutes.tabsWallet,
        name: AppRouteNames.tabsWallet,
        builder: (context, state) => rootBuilder(context),
      ),
      GoRoute(
        path: AppRoutes.tabsSettings,
        name: AppRouteNames.tabsSettings,
        builder: (context, state) => rootBuilder(context),
      ),
    ],
    redirect: (context, state) {
      if (_isFirebaseAuthCallback(state.uri)) {
        return AppRoutes.root;
      }

      return null;
    },
    errorBuilder: (context, state) => rootBuilder(context),
  );
}

bool _isFirebaseAuthCallback(Uri uri) {
  return uri.path == '/link' &&
      (uri.queryParameters['deep_link_id'] ?? '').contains(
        '/__/auth/callback',
      );
}
