import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylo_products/app/app.dart';
import 'package:mylo_products/app/bootstrap.dart';

/// Helpers for tests that run the real app on a device against the live API.

/// Pumps real time until [finder] matches, or fails after [timeout].
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

/// Starts a fresh app instance over the real keychain (a "cold start").
Future<void> launchApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(MyloApp(getIt: bootstrap(devTools: true)));
}

/// Clears whatever session a previous run left in the keychain.
Future<void> clearSession() async {
  final getIt = bootstrap(devTools: true);
  await getIt<AuthRepository>().logout();
}
