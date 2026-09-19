import 'package:auth/src/data/dto/auth_tokens_dto.dart';
import 'package:auth/src/data/dto/user_dto.dart';
import 'package:network/network.dart';

/// Login and profile, over the authenticated API client.
class AuthRemoteSource {
  const AuthRemoteSource(this._dio);

  final Dio _dio;

  Future<AuthTokensDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: ApiExtras.noAuth,
    );
    return AuthTokensDto.fromJson(response.data!);
  }

  Future<UserDto> profile() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/profile');
    return UserDto.fromJson(response.data!);
  }
}
