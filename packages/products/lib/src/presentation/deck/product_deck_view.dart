import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/presentation/list/products_intent.dart';
import 'package:products/src/presentation/list/products_state.dart';
import 'package:products/src/presentation/widgets/product_deck_card.dart';
import 'package:products/src/presentation/widgets/swipe_stamp.dart';
import 'package:products/testing.dart';

/// The swipeable deck of products. Renders [state] and reports [onIntent]; it
/// only owns the controller that lets the Like and Skip buttons throw the top
/// card, which is ephemeral UI state.
class ProductDeckView extends StatefulWidget {
  const ProductDeckView({
    required this.state,
    required this.onIntent,
    super.key,
  });

  final ProductsState state;
  final void Function(ProductsIntent intent) onIntent;

  @override
  State<ProductDeckView> createState() => _ProductDeckViewState();
}

class _ProductDeckViewState extends State<ProductDeckView> {
  final SwipeDeckController _controller = SwipeDeckController();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.dsColors;
    final state = widget.state;
    final items = state.deckItems;

    if (state.isDeckExhausted) {
      return EmptyView(
        icon: Icons.style_outlined,
        title: l10n.deckEmptyTitle,
        message: l10n.deckEmptyMessage,
        action: AppButton(
          label: l10n.deckStartOver,
          expand: false,
          onPressed: () => widget.onIntent(const ProductsDeckRestarted()),
        ),
      );
    }
    // Everything loaded has been swiped; the next page is on its way.
    if (items.isEmpty) return const AppLoader();

    return Column(
      children: [
        _LikedCounter(count: state.likedIds.length),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DSSpacing.l,
              vertical: DSSpacing.s,
            ),
            child: SwipeDeck<Product>(
              items: items,
              keyOf: (product) => product.id,
              controller: _controller,
              itemBuilder: (context, product) =>
                  ProductDeckCard(product: product),
              leftOverlay: SwipeStamp(
                label: l10n.deckSkip,
                color: colors.error,
                tilt: 0.2,
              ),
              rightOverlay: SwipeStamp(
                label: l10n.deckLike,
                color: colors.success,
              ),
              leftActionLabel: l10n.deckSkip,
              rightActionLabel: l10n.deckLike,
              onSwiped: (product, direction) =>
                  widget.onIntent(ProductSwiped(product, direction)),
              onTap: (product) => widget.onIntent(ProductSelected(product)),
              onEndReached: () =>
                  widget.onIntent(const ProductsNextPageRequested()),
            ),
          ),
        ),
        if (state.loadMoreFailure case final failure?)
          ErrorView(
            failure: failure,
            compact: true,
            onRetry: () => widget.onIntent(const ProductsNextPageRequested()),
          ),
        // Physical order on purpose: Skip is on the left and Like on the
        // right, matching the direction of each swipe in any locale.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: DSSpacing.s,
              bottom: DSSpacing.l,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: DSSpacing.xl,
              children: [
                _ActionButton(
                  tooltip: l10n.deckSkip,
                  icon: Icons.close_rounded,
                  color: colors.error,
                  onPressed: () => _controller.swipe(SwipeDirection.left),
                ),
                _ActionButton(
                  tooltip: l10n.deckLike,
                  icon: Icons.favorite_rounded,
                  color: colors.success,
                  onPressed: () => _controller.swipe(SwipeDirection.right),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LikedCounter extends StatelessWidget {
  const _LikedCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: DSSpacing.s),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: DSSpacing.xs,
      children: [
        Icon(
          Icons.favorite_rounded,
          size: DSDimensions.iconS,
          color: context.dsColors.success,
        ),
        Text(
          context.l10n.deckLikedCount(count),
          style: context.dsTypography.small(
            color: context.dsColors.txtSecondary,
          ),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
    tooltip: tooltip,
    iconSize: DSDimensions.iconL,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      minimumSize: const Size.square(64),
      foregroundColor: color,
      backgroundColor: context.dsColors.bgSecondary,
      side: BorderSide(color: color, width: 2),
    ),
    icon: Icon(icon),
  );
}

ProductsState _deck({
  int liked = 0,
  int dismissed = 0,
  bool reachedEnd = false,
  Failure? loadMoreFailure,
}) => ProductsState(
  phase: ProductsPhase.ready,
  items: productFixtures,
  nextOffset: productFixtures.length,
  hasReachedEnd: reachedEnd,
  viewMode: ProductsViewMode.deck,
  likedIds: {for (final p in productFixtures.take(liked)) p.id},
  dismissedIds: {for (final p in productFixtures.take(dismissed)) p.id},
  loadMoreFailure: loadMoreFailure,
);

Widget _view(ProductsState state) => SizedBox(
  height: 640,
  child: ProductDeckView(state: state, onIntent: (_) {}),
);

@AppPreviews('ProductDeckView')
Widget productDeckViewPreview() => _view(_deck(liked: 2, dismissed: 3));

@AppPreviews('ProductDeckView: no likes yet')
Widget productDeckViewFreshPreview() => _view(_deck());

@AppPreviews('ProductDeckView: next page failed')
Widget productDeckViewFailedPreview() =>
    _view(_deck(loadMoreFailure: const NetworkFailure()));

@AppPreviews('ProductDeckView: seen everything')
Widget productDeckViewExhaustedPreview() =>
    _view(_deck(liked: 4, dismissed: productFixtures.length, reachedEnd: true));

@AppPreviews('ProductDeckView: waiting for more')
Widget productDeckViewWaitingPreview() =>
    _view(_deck(dismissed: productFixtures.length));
