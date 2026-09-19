import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A photo the user chose, ready to upload.
class PickedPhoto extends Equatable {
  const PickedPhoto({required this.bytes, required this.name});

  final Uint8List bytes;

  /// The original file name, including its extension.
  final String name;

  @override
  List<Object?> get props => [bytes, name];
}
