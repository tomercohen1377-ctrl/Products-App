import 'package:auth/src/presentation/login/login_bloc.dart';
import 'package:auth/src/presentation/login/login_content.dart';
import 'package:auth/src/presentation/login/login_effect.dart';
import 'package:auth/src/presentation/login/login_state.dart';
import 'package:auth/src/presentation/session/session_bloc.dart';
import 'package:auth/src/presentation/session/session_intent.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Container: needs a [LoginBloc] and a [SessionBloc] above it.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expired = context.select<SessionBloc, bool>(
      (bloc) => bloc.state.expired,
    );
    return Scaffold(
      body: SafeArea(
        child: MviView<LoginBloc, LoginState, LoginEffect>(
          onEffect: (context, effect) => switch (effect) {
            LoginSucceeded(:final user) => context.read<SessionBloc>().add(
              SessionSignedIn(user),
            ),
          },
          builder: (context, state) => LoginContent(
            state: state,
            sessionExpired: expired,
            onIntent: context.read<LoginBloc>().add,
          ),
        ),
      ),
    );
  }
}
