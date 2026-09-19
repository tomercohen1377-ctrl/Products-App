import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows its message with a tone-specific icon', (tester) async {
    await tester.pumpApp(
      const Column(
        children: [
          AppBanner(message: 'info text'),
          AppBanner(message: 'error text', tone: AppBannerTone.error),
        ],
      ),
    );

    expect(find.text('info text'), findsOneWidget);
    expect(find.text('error text'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('is announced as a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const AppBanner(message: 'saved'));

    expect(
      tester.getSemantics(find.text('saved')),
      matchesSemantics(label: 'saved', isLiveRegion: true),
    );
    handle.dispose();
  });
}
