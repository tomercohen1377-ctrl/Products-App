import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget list({
    required int count,
    required VoidCallback onLoadMore,
    bool hasReachedEnd = false,
    bool isLoadingMore = false,
    Failure? failure,
  }) => PaginatedList(
    itemCount: count,
    onLoadMore: onLoadMore,
    hasReachedEnd: hasReachedEnd,
    isLoadingMore: isLoadingMore,
    loadMoreFailure: failure,
    itemBuilder: (_, i) => SizedBox(height: 100, child: Text('item $i')),
  );

  testWidgets('loads more when the content is too short to scroll', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpApp(list(count: 3, onLoadMore: () => loads++));
    await tester.pump();

    expect(loads, greaterThan(0));
  });

  testWidgets('loads more when scrolled near the end', (tester) async {
    var loads = 0;
    await tester.pumpApp(list(count: 40, onLoadMore: () => loads++));
    await tester.pump();
    expect(loads, 0);

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pump();
    expect(loads, greaterThan(0));
  });

  testWidgets('does not ask again while loading or at the end', (tester) async {
    var loads = 0;
    await tester.pumpApp(
      list(count: 3, isLoadingMore: true, onLoadMore: () => loads++),
    );
    await tester.pump();
    expect(loads, 0);

    await tester.pumpApp(
      list(count: 3, hasReachedEnd: true, onLoadMore: () => loads++),
    );
    await tester.pump();
    expect(loads, 0);
  });

  testWidgets('a failed page shows a retry footer instead of looping', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpApp(
      list(
        count: 3,
        failure: const NetworkFailure(),
        onLoadMore: () => loads++,
      ),
    );
    await tester.pump();
    expect(loads, 0);

    await tester.tap(find.text('Try again'));
    expect(loads, 1);
  });

  testWidgets('pull to refresh calls onRefresh', (tester) async {
    var refreshed = false;
    await tester.pumpApp(
      PaginatedList(
        itemCount: 3,
        hasReachedEnd: true,
        onLoadMore: () {},
        onRefresh: () async => refreshed = true,
        itemBuilder: (_, i) => SizedBox(height: 100, child: Text('item $i')),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(refreshed, isTrue);
  });
}
