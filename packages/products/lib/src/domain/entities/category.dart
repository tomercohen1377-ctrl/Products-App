import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({required this.id, required this.name, this.imageUrl});

  final int id;
  final String name;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];
}
