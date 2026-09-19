import 'package:auth/src/data/dto/auth_tokens_dto.dart';
import 'package:network/network.dart';

/// `POST /auth/refresh-token`, over the **bare** client (no auth interceptor),
/// so refreshing can never trigger another refresh.
class RefreshRemoteSource {
  const RefreshRemoteSource(this._bareDio);

  final Dio _bareDio;

  Future<AuthTokensDto> refresh(String refreshToken) async {
    final response = await _bareDio.post<Map<String, dynamic>>(
      '/auth/refresh-token',
      data: {'refreshToken': refreshToken},
    );
    return AuthTokensDto.fromJson(response.data!);
  }
}
