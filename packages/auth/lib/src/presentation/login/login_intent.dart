import 'package:equatable/equatable.dart';

sealed class LoginIntent extends Equatable {
  const LoginIntent();

  @override
  List<Object?> get props => const [];
}

final class LoginEmailChanged extends LoginIntent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class LoginPasswordChanged extends LoginIntent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object?> get props => [password];
}

final class LoginSubmitted extends LoginIntent {
  const LoginSubmitted();
}
