import 'package:auth/auth.dart';
import 'package:auth/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylo_products/app/router/app_router.dart';

void main() {
  const unknown = SessionState.unknown();
  const signedOut = SessionState(status: SessionStatus.unauthenticated);
  const signedIn = SessionState(
    status: SessionStatus.authenticated,
    user: userFixture,
  );

  final table = <String, (SessionState, String, String?)>{
    'unknown, on products -> splash': (unknown, '/products', AuthRoutes.splash),
    'unknown, on login -> splash': (
      unknown,
      AuthRoutes.login,
      AuthRoutes.splash,
    ),
    'unknown, on splash -> stay': (unknown, AuthRoutes.splash, null),
    'signed out, on products -> login': (
      signedOut,
      '/products',
      AuthRoutes.login,
    ),
    'signed out, on splash -> login': (
      signedOut,
      AuthRoutes.splash,
      AuthRoutes.login,
    ),
    'signed out, on login -> stay': (signedOut, AuthRoutes.login, null),
    'signed in, on login -> products': (
      signedIn,
      AuthRoutes.login,
      AppRoutes.products,
    ),
    'signed in, on splash -> products': (
      signedIn,
      AuthRoutes.splash,
      AppRoutes.products,
    ),
    'signed in, on products -> stay': (signedIn, '/products', null),
    'signed in, deep link -> stay': (signedIn, '/products/42', null),
  };

  table.forEach((name, testCase) {
    test(name, () {
      final (session, location, expected) = testCase;
      expect(sessionRedirect(session, location), expected);
    });
  });
}
