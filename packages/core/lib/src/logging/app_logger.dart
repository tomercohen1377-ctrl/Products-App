import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Minimal logging seam. Injected (never a global) so tests can silence or
/// capture it, and so nothing logs secrets by accident in one central place.
abstract interface class AppLogger {
  void debug(String message);
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Writes to the developer console; silent in release builds.
class DeveloperLogger implements AppLogger {
  const DeveloperLogger({this.name = 'mylo'});

  final String name;

  @override
  void debug(String message) {
    if (kReleaseMode) return;
    developer.log(message, name: name);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kReleaseMode) return;
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
