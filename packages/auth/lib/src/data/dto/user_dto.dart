import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable(createToJson: false)
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final int id;
  final String email;
  final String name;
  final String? avatar;
}
