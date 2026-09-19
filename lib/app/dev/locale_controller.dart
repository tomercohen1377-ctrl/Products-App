import 'package:flutter/widgets.dart';

/// The locale override used by the developer tools to demonstrate Hebrew and
/// RTL. `null` follows the device.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);
}
