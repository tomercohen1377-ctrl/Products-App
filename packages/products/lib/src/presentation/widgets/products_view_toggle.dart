import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:products/src/presentation/list/products_state.dart';

/// Switches between the list and the deck.
class ProductsViewToggle extends StatelessWidget {
  const ProductsViewToggle({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final ProductsViewMode mode;
  final ValueChanged<ProductsViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<ProductsViewMode>(
      showSelectedIcon: false,
      selected: {mode},
      onSelectionChanged: (selection) => onChanged(selection.first),
      segments: [
        ButtonSegment(
          value: ProductsViewMode.list,
          icon: const Icon(Icons.view_list_rounded),
          label: Text(l10n.productsViewList),
        ),
        ButtonSegment(
          value: ProductsViewMode.deck,
          icon: const Icon(Icons.style_rounded),
          label: Text(l10n.productsViewDeck),
        ),
      ],
    );
  }
}

@AppPreviews('ProductsViewToggle')
Widget productsViewTogglePreview() => Column(
  spacing: DSSpacing.m,
  children: [
    ProductsViewToggle(mode: ProductsViewMode.list, onChanged: (_) {}),
    ProductsViewToggle(mode: ProductsViewMode.deck, onChanged: (_) {}),
  ],
);
