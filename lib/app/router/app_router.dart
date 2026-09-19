import 'package:auth/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mylo_products/app/home/home_placeholder.dart';
import 'package:mylo_products/app/router/stream_listenable.dart';

abstract final class AppRoutes {
  static const String products = '/products';
}

/// Where the user should be for a given session and current location, or null
/// to stay put. One rule for the whole app: unknown -> splash, signed out ->
/// login, signed in -> never on splash/login.
String? sessionRedirect(SessionState session, String location) {
  final onSplash = location == AuthRoutes.splash;
  final onLogin = location == AuthRoutes.login;

  if (!session.isKnown) return onSplash ? null : AuthRoutes.splash;
  if (!session.isAuthenticated) return onLogin ? null : AuthRoutes.login;
  return (onSplash || onLogin) ? AppRoutes.products : null;
}

GoRouter createRouter({
  required SessionBloc session,
  required GetIt getIt,
  required GlobalKey<NavigatorState> navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AuthRoutes.splash,
    refreshListenable: StreamListenable(session.stream),
    redirect: (context, state) =>
        sessionRedirect(session.state, state.matchedLocation),
    routes: [
      ...authRoutes(getIt),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) => const HomePlaceholder(),
      ),
    ],
  );
}
