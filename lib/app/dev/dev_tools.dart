import 'package:flutter/foundation.dart';

abstract final class DevTools {
  /// On in debug builds, or in any build with `--dart-define=DEV_TOOLS=true`
  /// (so the refresh demo also works in a profile/release build).
  static const bool enabled = kDebugMode || bool.fromEnvironment('DEV_TOOLS');
}
