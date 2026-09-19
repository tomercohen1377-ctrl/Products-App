import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns a stream into a [Listenable] so `GoRouter` re-evaluates its
/// redirect whenever the session changes.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
