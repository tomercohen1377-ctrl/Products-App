import 'package:auth/src/presentation/login/login_bloc.dart';
import 'package:auth/src/presentation/login/login_screen.dart';
import 'package:auth/src/presentation/splash/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

abstract final class AuthRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
}

/// The auth feature's routes; the app composes them into its router.
List<RouteBase> authRoutes(GetIt getIt) => [
  GoRoute(
    path: AuthRoutes.splash,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: AuthRoutes.login,
    builder: (context, state) => BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: const LoginScreen(),
    ),
  ),
];
