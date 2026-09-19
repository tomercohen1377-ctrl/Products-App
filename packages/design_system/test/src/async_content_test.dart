import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  const content = Text('content');

  Future<void> pumpContent(
    WidgetTester tester, {
    bool isLoading = false,
    Failure? failure,
    bool isEmpty = false,
    VoidCallback? onRetry,
  }) async {
    await tester.pumpApp(
      AsyncContent(
        isLoading: isLoading,
        failure: failure,
        isEmpty: isEmpty,
        onRetry: onRetry,
        child: content,
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('shows content by default', (tester) async {
    await pumpContent(tester);
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('shows a loader while loading', (tester) async {
    await pumpContent(tester, isLoading: true);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('content'), findsNothing);
  });

  testWidgets('shows the empty view when empty', (tester) async {
    await pumpContent(tester, isEmpty: true);
    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('content'), findsNothing);
  });

  testWidgets('failure wins over loading and empty, and retries', (
    tester,
  ) async {
    var retries = 0;
    await pumpContent(
      tester,
      isLoading: true,
      isEmpty: true,
      failure: const NetworkFailure(),
      onRetry: () => retries++,
    );

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('loading wins over empty', (tester) async {
    await pumpContent(tester, isLoading: true, isEmpty: true);
    expect(find.byType(EmptyView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
