import 'package:core/core.dart';
import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/tokens/ds_padding.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:design_system/src/widgets/app_loader.dart';
import 'package:design_system/src/widgets/error_view.dart';
import 'package:flutter/material.dart';

/// A vertical list that asks for the next page as the user nears the end.
///
/// Stateless on purpose: the bloc owns `isLoadingMore`, `hasReachedEnd` and
/// `loadMoreFailure`; this widget only reports scroll position through
/// [onLoadMore]. It also fires when the content is too short to scroll, so a
/// small first page still pulls the next one. After a failed page it stops
/// auto-loading and shows a retry footer that calls [onLoadMore] again.
class PaginatedList extends StatelessWidget {
  const PaginatedList({
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.loadMoreFailure,
    this.onRefresh,
    this.padding = DSPadding.screen,
    this.spacing = DSSpacing.s,
    this.loadMoreThreshold = 400,
    super.key,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback onLoadMore;
  final bool hasReachedEnd;
  final bool isLoadingMore;
  final Failure? loadMoreFailure;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry padding;
  final double spacing;

  /// Distance from the end (in logical pixels) at which the next page loads.
  final double loadMoreThreshold;

  bool get _hasFooter => isLoadingMore || loadMoreFailure != null;

  bool _onNotification(Notification notification) {
    final metrics = switch (notification) {
      ScrollNotification(:final metrics) => metrics,
      ScrollMetricsNotification(:final metrics) => metrics,
      _ => null,
    };
    if (metrics != null &&
        metrics.axis == Axis.vertical &&
        metrics.extentAfter < loadMoreThreshold &&
        !hasReachedEnd &&
        !isLoadingMore &&
        loadMoreFailure == null) {
      onLoadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final failure = loadMoreFailure;
    final list = NotificationListener<Notification>(
      onNotification: _onNotification,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount + (_hasFooter ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: spacing),
        itemBuilder: (context, index) {
          if (index < itemCount) return itemBuilder(context, index);
          return failure != null
              ? ErrorView(failure: failure, onRetry: onLoadMore, compact: true)
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: DSSpacing.m),
                  child: Center(child: AppLoader.small()),
                );
        },
      ),
    );
    final onRefresh = this.onRefresh;
    return onRefresh == null
        ? list
        : RefreshIndicator(onRefresh: onRefresh, child: list);
  }
}

@AppPreviews('PaginatedList')
Widget paginatedListPreview() => SizedBox(
  height: 320,
  child: PaginatedList(
    itemCount: 4,
    isLoadingMore: true,
    hasReachedEnd: false,
    onLoadMore: () {},
    itemBuilder: (context, index) =>
        Card(child: ListTile(title: Text('Item ${index + 1}'))),
  ),
);
