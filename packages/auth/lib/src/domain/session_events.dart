import 'dart:async';

/// App-wide session notifications. The network layer reports an unrecoverable
/// session here; the session bloc listens and routes the user to login.
class SessionEvents {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  /// Emits when refreshing failed for good and the session is over.
  Stream<void> get expired => _expired.stream;

  void notifyExpired() {
    if (!_expired.isClosed) _expired.add(null);
  }

  Future<void> dispose() => _expired.close();
}
