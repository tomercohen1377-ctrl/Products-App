import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

sealed class LoginStatus extends Equatable {
  const LoginStatus();

  @override
  List<Object?> get props => const [];
}

final class LoginIdle extends LoginStatus {
  const LoginIdle();
}

final class LoginSubmitting extends LoginStatus {
  const LoginSubmitting();
}

final class LoginFailed extends LoginStatus {
  const LoginFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.showErrors = false,
    this.status = const LoginIdle(),
  });

  final String email;
  final String password;

  /// Field errors stay hidden until the first submit attempt.
  final bool showErrors;
  final LoginStatus status;

  FieldError? get emailError => showErrors ? Validators.email(email) : null;
  FieldError? get passwordError =>
      showErrors ? Validators.required(password) : null;

  bool get isValid =>
      Validators.email(email) == null && Validators.required(password) == null;
  bool get isSubmitting => status is LoginSubmitting;
  Failure? get failure => switch (status) {
    LoginFailed(:final failure) => failure,
    _ => null,
  };

  LoginState copyWith({
    String? email,
    String? password,
    bool? showErrors,
    LoginStatus? status,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    showErrors: showErrors ?? this.showErrors,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [email, password, showErrors, status];
}
