import 'package:auth/src/data/dto/auth_tokens_dto.dart';
import 'package:auth/src/data/dto/user_dto.dart';
import 'package:auth/src/domain/entities/auth_tokens.dart';
import 'package:auth/src/domain/entities/user.dart';

extension AuthTokensDtoMapper on AuthTokensDto {
  AuthTokens toEntity() =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}

extension UserDtoMapper on UserDto {
  User toEntity() => User(
    id: id,
    email: email,
    name: name,
    avatarUrl: (avatar == null || avatar!.isEmpty) ? null : avatar,
  );
}
