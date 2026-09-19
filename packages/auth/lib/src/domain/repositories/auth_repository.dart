import 'package:auth/src/domain/entities/user.dart';
import 'package:core/core.dart';

abstract interface class AuthRepository {
  /// Signs in and persists the session. Bad credentials fail with
  /// [UnauthorizedFailure]; nothing is stored unless the profile also loads.
  Future<Result<User>> login({required String email, required String password});

  /// The signed-in user (`GET /auth/profile`).
  Future<Result<User>> currentUser();

  /// Whether tokens are stored on this device.
  Future<bool> hasSession();

  /// Clears the stored session.
  Future<void> logout();
}
