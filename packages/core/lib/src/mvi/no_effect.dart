import 'package:equatable/equatable.dart';

/// The effect type for screens that never emit one-shot effects.
final class NoEffect extends Equatable {
  const NoEffect._();

  @override
  List<Object?> get props => const [];
}
