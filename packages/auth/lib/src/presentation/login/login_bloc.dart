import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/login/login_effect.dart';
import 'package:auth/src/presentation/login/login_intent.dart';
import 'package:auth/src/presentation/login/login_state.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Emitter;

/// Credentials pre-filled on the login form (dev builds only).
class LoginPrefill {
  const LoginPrefill({required this.email, required this.password});

  final String email;
  final String password;
}

class LoginBloc extends MviBloc<LoginIntent, LoginState, LoginEffect> {
  LoginBloc(this._repository, {LoginPrefill? prefill})
    : super(
        LoginState(
          email: prefill?.email ?? '',
          password: prefill?.password ?? '',
        ),
      ) {
    on<LoginEmailChanged>(
      (intent, emit) =>
          emit(state.copyWith(email: intent.email, status: const LoginIdle())),
    );
    on<LoginPasswordChanged>(
      (intent, emit) => emit(
        state.copyWith(password: intent.password, status: const LoginIdle()),
      ),
    );
    // Droppable: a double tap must not fire two logins.
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AuthRepository _repository;

  Future<void> _onSubmitted(
    LoginSubmitted intent,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }

    emit(state.copyWith(status: const LoginSubmitting(), showErrors: true));
    final result = await _repository.login(
      email: state.email.trim(),
      password: state.password,
    );

    switch (result) {
      case Success(:final value):
        emit(state.copyWith(status: const LoginIdle()));
        emitEffect(LoginSucceeded(value));
      case Failed(:final failure):
        emit(state.copyWith(status: LoginFailed(failure)));
    }
  }
}
