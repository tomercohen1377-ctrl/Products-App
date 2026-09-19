import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('formats whole and fractional prices', (tester) async {
    await tester.pumpApp(
      const Column(children: [PriceLabel(10), PriceLabel(79.5)]),
    );

    expect(find.text(r'$10'), findsOneWidget);
    expect(find.text(r'$79.50'), findsOneWidget);
  });
}
