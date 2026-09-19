import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens_dto.g.dart';

@JsonSerializable(createToJson: false)
class AuthTokensDto {
  const AuthTokensDto({required this.accessToken, required this.refreshToken});

  factory AuthTokensDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensDtoFromJson(json);

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;
}
