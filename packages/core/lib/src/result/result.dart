import 'package:core/src/failure/failure.dart';
import 'package:equatable/equatable.dart';

/// The outcome of an operation that can fail with a typed [Failure].
///
/// Repositories return this instead of throwing, so callers `switch`
/// exhaustively and never need a `try/catch`.
sealed class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failed<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failed<T>(:final failure) => failure,
  };

  /// Collapses both branches into one value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    Failed<T>(:final failure) => onFailure(failure),
  };

  /// Transforms the success value, leaving a failure untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success<T>(:final value) => Success(transform(value)),
    Failed<T>(:final failure) => Failed(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
