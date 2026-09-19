import 'package:auth/src/data/mappers/auth_mappers.dart';
import 'package:auth/src/data/sources/auth_remote_source.dart';
import 'package:auth/src/data/storage/token_store.dart';
import 'package:auth/src/domain/entities/user.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:core/core.dart';
import 'package:network/network.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokens);

  final AuthRemoteSource _remote;
  final TokenStore _tokens;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    final login = await guardApi(
      () => _remote.login(email: email, password: password),
    );
    if (login case Failed(:final failure)) return Failed(failure);

    await _tokens.save(login.valueOrNull!.toEntity());

    final profile = await currentUser();
    if (profile is Failed<User>) {
      // Don't leave a half-signed-in device behind.
      await _tokens.clear();
    }
    return profile;
  }

  @override
  Future<Result<User>> currentUser() async {
    final result = await guardApi(_remote.profile);
    return result.map((dto) => dto.toEntity());
  }

  @override
  Future<bool> hasSession() async => await _tokens.read() != null;

  @override
  Future<void> logout() => _tokens.clear();
}
