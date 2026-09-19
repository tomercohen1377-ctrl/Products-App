/// Default for a nullable `copyWith` parameter, so passing `null` can mean
/// "clear the value" while omitting it means "keep the current one".
///
/// ```dart
/// State copyWith({Object? failure = keep}) =>
///     State(failure: valueOrKeep(failure, this.failure));
/// ```
const Object keep = Object();

/// Resolves a `copyWith` argument that defaults to [keep].
T? valueOrKeep<T>(Object? argument, T? current) =>
    identical(argument, keep) ? current : argument as T?;
