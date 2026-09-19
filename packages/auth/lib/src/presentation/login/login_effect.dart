import 'package:auth/src/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

sealed class LoginEffect extends Equatable {
  const LoginEffect();

  @override
  List<Object?> get props => const [];
}

final class LoginSucceeded extends LoginEffect {
  const LoginSucceeded(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}
