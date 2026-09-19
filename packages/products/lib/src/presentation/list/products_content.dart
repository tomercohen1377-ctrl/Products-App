import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_state.dart';
import 'package:products/src/presentation/widgets/product_tile.dart';
import 'package:products/testing.dart';

/// The paged list. Pure: renders [state] and reports [onIntent].
class ProductsContent extends StatelessWidget {
  const ProductsContent({
    required this.state,
    required this.onIntent,
    this.onRefresh = _noRefresh,
    super.key,
  });

  final ProductsState state;
  final void Function(ProductsIntent intent) onIntent;

  /// Completes when a pull-to-refresh has finished (drives the spinner).
  final Future<void> Function() onRefresh;

  static Future<void> _noRefresh() async {}

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AsyncContent(
      isLoading: state.isInitialLoading,
      failure: state.blockingFailure,
      isEmpty: state.isEmpty,
      onRetry: () => onIntent(const ProductsStarted()),
      empty: EmptyView(
        title: l10n.productsEmptyTitle,
        message: l10n.productsEmptyMessage,
        action: AppButton(
          label: l10n.refresh,
          variant: AppButtonVariant.secondary,
          expand: false,
          onPressed: () => onIntent(const ProductsStarted()),
        ),
      ),
      child: PaginatedList(
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final product = state.items[index];
          return ProductTile(
            product: product,
            onTap: () => onIntent(ProductSelected(product)),
          );
        },
        onLoadMore: () => onIntent(const ProductsNextPageRequested()),
        hasReachedEnd: state.hasReachedEnd,
        isLoadingMore: state.isLoadingMore,
        loadMoreFailure: state.loadMoreFailure,
        onRefresh: onRefresh,
        // Bottom room so the add button never hides the last product.
        padding: const EdgeInsetsDirectional.only(
          start: DSSpacing.m,
          end: DSSpacing.m,
          top: DSSpacing.m,
          bottom: DSDimensions.buttonHeight + DSSpacing.xxl,
        ),
      ),
    );
  }
}

ProductsState _ready({
  List<Product>? items,
  bool hasReachedEnd = false,
  bool isLoadingMore = false,
  Failure? loadMoreFailure,
}) {
  final list = items ?? productFixtures;
  return ProductsState(
    phase: ProductsPhase.ready,
    items: list,
    nextOffset: list.length,
    hasReachedEnd: hasReachedEnd,
    isLoadingMore: isLoadingMore,
    loadMoreFailure: loadMoreFailure,
  );
}

Widget _content(ProductsState state) => SizedBox(
  height: 560,
  child: ProductsContent(state: state, onIntent: (_) {}),
);

@AppPreviews('ProductsContent: loading')
Widget productsContentLoadingPreview() => _content(const ProductsState());

@AppPreviews('ProductsContent: loaded')
Widget productsContentLoadedPreview() => _content(_ready(hasReachedEnd: true));

@AppPreviews('ProductsContent: loading more')
Widget productsContentLoadingMorePreview() =>
    _content(_ready(isLoadingMore: true));

@AppPreviews('ProductsContent: next page failed')
Widget productsContentLoadMoreFailedPreview() =>
    _content(_ready(loadMoreFailure: const NetworkFailure()));

@AppPreviews('ProductsContent: empty')
Widget productsContentEmptyPreview() =>
    _content(_ready(items: const [], hasReachedEnd: true));

@AppPreviews('ProductsContent: first load failed')
Widget productsContentFailedPreview() => _content(
  const ProductsState(
    phase: ProductsPhase.failure,
    failure: ServerFailure(statusCode: 503),
  ),
);
