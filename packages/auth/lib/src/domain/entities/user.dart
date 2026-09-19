import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  final int id;
  final String email;
  final String name;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, email, name, avatarUrl];
}
