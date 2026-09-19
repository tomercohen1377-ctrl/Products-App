import 'package:equatable/equatable.dart';

/// A typed, UI-agnostic description of why an operation failed.
///
/// Failures carry no user-facing text; the presentation layer maps each
/// subtype to a localized message in exactly one place.
sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => const [];
}

/// The device could not reach the server.
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// The server did not answer in time.
final class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

/// The credentials or session were rejected (HTTP 401/403).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

/// The server rejected the payload (HTTP 400/422) with validation messages.
final class ValidationFailure extends Failure {
  const ValidationFailure({this.messages = const []});

  final List<String> messages;

  @override
  List<Object?> get props => [messages];
}

/// Any other non-success HTTP response.
final class ServerFailure extends Failure {
  const ServerFailure({required this.statusCode, this.message});

  final int statusCode;
  final String? message;

  @override
  List<Object?> get props => [statusCode, message];
}

/// Anything unexpected; keeps the original error for logging.
final class UnknownFailure extends Failure {
  const UnknownFailure({this.cause});

  final Object? cause;

  @override
  List<Object?> get props => [cause];
}
